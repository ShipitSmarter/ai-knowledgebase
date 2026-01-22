#!/bin/bash
#
# setup.sh - Set up ShipitSmarter AI Knowledgebase for OpenCode
#
# This script:
# 1. Clones ai-knowledgebase to ~/.shipitsmarter/ai-knowledgebase (if run remotely)
# 2. Symlinks skills, commands, and agents to ~/.config/opencode/ for global availability
# 3. Sets up local .opencode/skill symlinks (for local development)
# 4. Installs skill dependencies (Playwright, Google AI Search plugin)
# 5. Configures the opencode-mem plugin
#
# After running, skills will be available in ANY repository.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
#
# Or locally:
#   ./tools/setup.sh [options]
#
# Options:
#   --skip-deps     Skip installing skill dependencies (Playwright, plugins)
#   --deps-only     Only install skill dependencies (skip symlink setup)
#   --verify        Just verify the current setup
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="${HOME}/.shipitsmarter/ai-knowledgebase"
REPO_URL="https://github.com/ShipitSmarter/ai-knowledgebase"
OPENCODE_CONFIG_HOME="${HOME}/.config/opencode"
OPENCODE_PLUGINS="${HOME}/.opencode/plugins"

# Determine script location and repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || SCRIPT_DIR=""
if [[ -n "$SCRIPT_DIR" && -d "$(dirname "$SCRIPT_DIR")/skills" ]]; then
  REPO_ROOT="$(dirname "$SCRIPT_DIR")"
  RUNNING_LOCALLY=true
else
  REPO_ROOT="$INSTALL_DIR"
  RUNNING_LOCALLY=false
fi

# Parse arguments
SKIP_DEPS=false
DEPS_ONLY=false
VERIFY_ONLY=false

for arg in "$@"; do
  case $arg in
    --skip-deps)
      SKIP_DEPS=true
      ;;
    --deps-only)
      DEPS_ONLY=true
      ;;
    --verify)
      VERIFY_ONLY=true
      ;;
  esac
done

# Print functions
print_header() {
  echo ""
  echo -e "${BLUE}=== $1 ===${NC}"
  echo ""
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}!${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Detect shell config file
detect_shell_config() {
  if [ -f "${HOME}/.zshrc" ]; then
    echo "${HOME}/.zshrc"
  else
    echo "${HOME}/.bashrc"
  fi
}

# Set up a directory symlink
setup_directory_symlink() {
  local name="$1"
  local target="$2"
  local link_path="$OPENCODE_CONFIG_HOME/$name"
  
  if [[ -L "$link_path" ]]; then
    current_target=$(readlink "$link_path")
    if [[ "$current_target" == "$target" ]]; then
      print_success "$name already linked correctly"
      return 0
    else
      print_warning "$name points to wrong location, updating..."
      rm "$link_path"
    fi
  elif [[ -d "$link_path" ]]; then
    echo "Migrating $name from individual symlinks to directory symlink..."
    rm -rf "$link_path"
  elif [[ -e "$link_path" ]]; then
    print_warning "$name exists but is not a symlink or directory, skipping"
    return 1
  fi
  
  ln -sf "$target" "$link_path"
  print_success "Linked $name -> $target"
}

# Set up local skill symlinks in .opencode/skill
setup_local_symlinks() {
  info "Setting up local skill symlinks..."
  
  mkdir -p "${REPO_ROOT}/.opencode/skill"
  
  for skill_dir in "${REPO_ROOT}/skills"/*/; do
    if [[ -d "$skill_dir" ]]; then
      skill_name=$(basename "$skill_dir")
      link_path="${REPO_ROOT}/.opencode/skill/${skill_name}"
      target="../../skills/${skill_name}"
      
      if [[ -L "$link_path" ]]; then
        success "Symlink exists: ${skill_name}"
      elif [[ -e "$link_path" ]]; then
        warn "Path exists but is not a symlink: ${link_path}"
      else
        ln -sf "$target" "$link_path"
        success "Created symlink: ${skill_name}"
      fi
    fi
  done
}

# Install skill dependencies
setup_dependencies() {
  print_header "Installing Skill Dependencies"
  
  # Check for Node.js
  if ! command_exists node; then
    error "Node.js is required but not installed."
    echo "  Install from: https://nodejs.org/"
    return 1
  fi
  success "Node.js found: $(node --version)"
  
  # Check for npm
  if ! command_exists npm; then
    error "npm is required but not installed."
    return 1
  fi
  success "npm found: $(npm --version)"
  
  # Install Playwright
  info "Checking Playwright installation..."
  if ! command_exists playwright; then
    info "Installing Playwright globally..."
    npm install -g playwright
  fi
  success "Playwright available"
  
  # Install Chromium for Playwright
  info "Ensuring Chromium is installed for Playwright..."
  npx playwright install chromium 2>/dev/null || {
    warn "Could not install Chromium automatically."
    echo "  Run manually: npx playwright install chromium"
  }
  
  # Setup Google AI Search plugin
  info "Setting up Google AI Search plugin..."
  mkdir -p "$OPENCODE_PLUGINS"
  
  SEARCH_PLUGIN_DIR="${OPENCODE_PLUGINS}/opencode-google-ai-search"
  if [[ -d "$SEARCH_PLUGIN_DIR" ]]; then
    success "Google AI Search plugin already cloned"
    info "Updating plugin..."
    cd "$SEARCH_PLUGIN_DIR"
    git pull --quiet || warn "Could not update plugin"
  else
    info "Cloning Google AI Search plugin..."
    git clone --quiet https://github.com/IgorWarzocha/Opencode-Google-AI-Search-Plugin.git "$SEARCH_PLUGIN_DIR"
    success "Plugin cloned"
  fi
  
  # Build the plugin
  info "Building Google AI Search plugin..."
  cd "$SEARCH_PLUGIN_DIR"
  npm install --quiet
  if npm run build --quiet 2>/dev/null; then
    success "Plugin built"
  else
    warn "Plugin build had errors (may still work, or plugin may need updates)"
    echo "  Check: https://github.com/IgorWarzocha/Opencode-Google-AI-Search-Plugin"
  fi
  
  # Check for Notion token
  if [[ -n "$NOTION_TOKEN" ]]; then
    success "NOTION_TOKEN is set"
  else
    warn "NOTION_TOKEN not set. Notion integration will not work."
    echo "  To enable Notion:"
    echo "  1. Create integration at https://www.notion.so/profile/integrations"
    echo "  2. export NOTION_TOKEN=\"ntn_your_token_here\""
    echo "  3. Share Notion pages with your integration"
  fi
}

# Verify the setup
verify_setup() {
  print_header "Verifying Setup"
  
  # Check OpenCode installation
  if command_exists opencode; then
    success "OpenCode installed: $(opencode --version 2>/dev/null || echo 'version unknown')"
  else
    warn "OpenCode not found in PATH"
    echo "  Install from: https://opencode.ai/docs/"
  fi
  
  # Check global symlinks
  echo ""
  info "Global configuration (${OPENCODE_CONFIG_HOME}):"
  for item in skills commands agents; do
    link_path="${OPENCODE_CONFIG_HOME}/${item}"
    if [[ -L "$link_path" ]]; then
      target=$(readlink "$link_path")
      echo "  ${item} -> ${target}"
    elif [[ -d "$link_path" ]]; then
      echo "  ${item} (directory)"
    else
      echo "  ${item} (not found)"
    fi
  done
  
  # Check local symlinks
  if [[ -d "${REPO_ROOT}/.opencode/skill" ]]; then
    echo ""
    info "Local skill symlinks (${REPO_ROOT}/.opencode/skill):"
    local count=0
    for link in "${REPO_ROOT}/.opencode/skill"/*; do
      if [[ -L "$link" ]]; then
        ((count++))
      fi
    done
    echo "  ${count} skills linked"
  fi
  
  # Count available items
  local skill_count=$(find "$REPO_ROOT/skills" -maxdepth 1 -type d ! -name "skills" 2>/dev/null | wc -l | tr -d ' ')
  local command_count=$(find "$REPO_ROOT/commands" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  local agent_count=$(find "$REPO_ROOT/agents" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  
  echo ""
  info "Available:"
  echo "  ${skill_count} skills"
  echo "  ${command_count} commands"
  echo "  ${agent_count} agents"
  
  # Check plugins
  echo ""
  info "Plugins:"
  if [[ -f "${OPENCODE_CONFIG_HOME}/opencode.json" ]]; then
    if grep -q "opencode-mem" "${OPENCODE_CONFIG_HOME}/opencode.json"; then
      success "opencode-mem configured"
    else
      warn "opencode-mem not in global config"
    fi
  fi
  
  if [[ -d "${OPENCODE_PLUGINS}/opencode-google-ai-search" ]]; then
    success "google-ai-search plugin installed"
  else
    warn "google-ai-search plugin not installed"
  fi
  
  # Check dependencies
  echo ""
  info "Dependencies:"
  if command_exists node; then
    success "Node.js: $(node --version)"
  else
    warn "Node.js not found"
  fi
  if command_exists playwright; then
    success "Playwright available"
  else
    warn "Playwright not found"
  fi
}

# Main setup flow
main() {
  echo ""
  echo "=========================================="
  echo "  ShipitSmarter OpenCode Setup"
  echo "=========================================="
  echo ""
  
  # Verify only mode
  if [[ "$VERIFY_ONLY" == true ]]; then
    verify_setup
    exit 0
  fi
  
  # Dependencies only mode
  if [[ "$DEPS_ONLY" == true ]]; then
    setup_dependencies
    echo ""
    print_success "Dependencies installed!"
    exit 0
  fi
  
  # Step 1: Check if OpenCode is installed
  echo "Checking OpenCode installation..."
  if command_exists opencode; then
    OPENCODE_VERSION=$(opencode --version 2>/dev/null || echo "unknown")
    print_success "OpenCode is installed (version: $OPENCODE_VERSION)"
  else
    print_warning "OpenCode is not installed"
    echo ""
    echo "Install OpenCode first:"
    echo "  curl -fsSL https://opencode.ai/install | bash"
    echo ""
    read -p "Continue without OpenCode? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
  
  # Step 2: Clone or update ai-knowledgebase (only if running remotely)
  if [[ "$RUNNING_LOCALLY" == false ]]; then
    print_header "AI Knowledgebase"
    
    if [ -d "$INSTALL_DIR" ]; then
      echo "Updating existing installation..."
      git -C "$INSTALL_DIR" pull --quiet
      print_success "Updated ai-knowledgebase"
    else
      echo "Cloning ai-knowledgebase..."
      mkdir -p "${HOME}/.shipitsmarter"
      git clone --quiet "$REPO_URL" "$INSTALL_DIR"
      print_success "Cloned ai-knowledgebase to $INSTALL_DIR"
    fi
  else
    print_success "Running from local repository: $REPO_ROOT"
  fi
  
  # Step 3: Set up global OpenCode config with directory symlinks
  print_header "Setting up Global Configuration"
  
  mkdir -p "$OPENCODE_CONFIG_HOME"
  
  echo "Setting up skills..."
  setup_directory_symlink "skills" "$REPO_ROOT/skills"
  
  echo "Setting up commands..."
  setup_directory_symlink "commands" "$REPO_ROOT/commands"
  
  echo "Setting up agents..."
  setup_directory_symlink "agents" "$REPO_ROOT/agents"
  
  # Step 4: Set up local skill symlinks (for development in this repo)
  if [[ "$RUNNING_LOCALLY" == true ]]; then
    print_header "Setting up Local Skill Symlinks"
    setup_local_symlinks
  fi
  
  # Step 5: Set up opencode.json with plugins
  print_header "Configuring Plugins"
  
  OPENCODE_JSON="$OPENCODE_CONFIG_HOME/opencode.json"
  if [ ! -f "$OPENCODE_JSON" ]; then
    echo '{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["opencode-mem"]
}' > "$OPENCODE_JSON"
    print_success "Created global config with opencode-mem plugin"
  elif ! grep -q "opencode-mem" "$OPENCODE_JSON" 2>/dev/null; then
    print_warning "opencode-mem plugin not in global config"
    echo "  Add to $OPENCODE_JSON:"
    echo '  "plugin": ["opencode-mem"]'
  else
    print_success "opencode-mem plugin configured"
  fi
  
  # Step 6: Install dependencies (unless skipped)
  if [[ "$SKIP_DEPS" == false ]]; then
    setup_dependencies
  else
    print_warning "Skipping dependency installation (--skip-deps)"
  fi
  
  # Step 7: Clean up old environment variables
  SHELL_RC=$(detect_shell_config)
  if grep -q "OPENCODE_CONFIG_DIR.*ai-knowledgebase" "$SHELL_RC" 2>/dev/null; then
    print_warning "Found old OPENCODE_CONFIG_DIR in $SHELL_RC"
    echo "  The new setup uses symlinks instead. You can remove these lines:"
    echo "    export OPENCODE_CONFIG_DIR=..."
    echo "    export OPENCODE_CONFIG=..."
  fi
  
  # Summary
  print_header "Setup Complete"
  
  verify_setup
  
  echo ""
  echo -e "${GREEN}Skills are now available in ANY repository!${NC}"
  echo ""
  echo -e "${GREEN}New skills/commands are automatically available after 'git pull'${NC}"
  echo ""
  echo "Try it out:"
  echo "  cd ~/your-project"
  echo "  opencode"
  echo "  /research <topic>"
  echo ""
}

main "$@"
