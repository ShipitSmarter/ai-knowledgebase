#!/bin/bash
#
# setup.sh - Set up ShipitSmarter AI Knowledgebase for OpenCode
#
# This script:
# 1. Clones ai-knowledgebase to ~/.shipitsmarter/ai-knowledgebase
# 2. Symlinks skills and commands to ~/.config/opencode/ for global availability
# 3. Sets up the opencode-mem plugin for persistent memory
#
# After running, skills will be available in ANY repository.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
#
# Or locally:
#   ./tools/setup.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

INSTALL_DIR="${HOME}/.shipitsmarter/ai-knowledgebase"
REPO_URL="https://github.com/ShipitSmarter/ai-knowledgebase"
OPENCODE_CONFIG_HOME="${HOME}/.config/opencode"

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

# Detect shell config file
detect_shell_config() {
  if [ -f "${HOME}/.zshrc" ]; then
    echo "${HOME}/.zshrc"
  else
    echo "${HOME}/.bashrc"
  fi
}

print_header "ShipitSmarter OpenCode Setup"

# Step 1: Check if OpenCode is installed
echo "Checking OpenCode installation..."
if command -v opencode &> /dev/null; then
  OPENCODE_VERSION=$(opencode --version 2>/dev/null || echo "unknown")
  print_success "OpenCode is installed (version: $OPENCODE_VERSION)"
else
  print_warning "OpenCode is not installed"
  echo ""
  echo "Install OpenCode first:"
  echo "  curl -fsSL https://opencode.ai/install | bash"
  echo ""
  echo "Or with Homebrew:"
  echo "  brew install opencode"
  echo ""
  read -p "Continue without OpenCode? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Step 2: Clone or update ai-knowledgebase
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

# Step 3: Set up OpenCode config with directory symlinks
print_header "Setting up OpenCode Configuration"

mkdir -p "$OPENCODE_CONFIG_HOME"

# Helper function to set up a directory symlink
setup_directory_symlink() {
  local name="$1"
  local target="$2"
  local link_path="$OPENCODE_CONFIG_HOME/$name"
  
  # Check if it's already the correct symlink
  if [[ -L "$link_path" ]]; then
    current_target=$(readlink "$link_path")
    if [[ "$current_target" == "$target" ]]; then
      print_success "$name already linked correctly"
      return 0
    else
      # Wrong target, remove and recreate
      print_warning "$name points to wrong location, updating..."
      rm "$link_path"
    fi
  elif [[ -d "$link_path" ]]; then
    # It's a directory (old setup with individual symlinks), remove it
    echo "Migrating $name from individual symlinks to directory symlink..."
    rm -rf "$link_path"
  elif [[ -e "$link_path" ]]; then
    print_warning "$name exists but is not a symlink or directory, skipping"
    return 1
  fi
  
  # Create the symlink
  ln -sf "$target" "$link_path"
  print_success "Linked $name -> $target"
}

# Link skills directory
echo "Setting up skills..."
setup_directory_symlink "skills" "$INSTALL_DIR/skills"

# Link commands directory
echo "Setting up commands..."
setup_directory_symlink "commands" "$INSTALL_DIR/commands"

# Step 4: Set up opencode.json with plugins
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

# Step 5: Clean up old environment variables (optional migration)
SHELL_RC=$(detect_shell_config)
if grep -q "OPENCODE_CONFIG_DIR.*ai-knowledgebase" "$SHELL_RC" 2>/dev/null; then
  print_warning "Found old OPENCODE_CONFIG_DIR in $SHELL_RC"
  echo "  The new setup uses symlinks instead. You can remove these lines:"
  echo "    export OPENCODE_CONFIG_DIR=..."
  echo "    export OPENCODE_CONFIG=..."
fi

# Summary
print_header "Setup Complete"

# Count skills and commands
SKILL_COUNT=$(find "$INSTALL_DIR/skills" -maxdepth 1 -type d -name "*" ! -name "skills" 2>/dev/null | wc -l | tr -d ' ')
COMMAND_COUNT=$(find "$INSTALL_DIR/commands" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo "Configuration:"
echo "  skills   -> $INSTALL_DIR/skills"
echo "  commands -> $INSTALL_DIR/commands"
echo ""
echo "Skills available globally ($SKILL_COUNT total):"
find "$INSTALL_DIR/skills" -maxdepth 1 -type d ! -name "skills" -exec basename {} \; 2>/dev/null | sort | head -10 | sed 's/^/  - /'
if [[ $SKILL_COUNT -gt 10 ]]; then
  echo "  ... and $(( SKILL_COUNT - 10 )) more"
fi

echo ""
echo "Commands available globally ($COMMAND_COUNT total):"
find "$INSTALL_DIR/commands" -maxdepth 1 -type f -name "*.md" -exec basename {} .md \; 2>/dev/null | sort | head -10 | sed 's/^/  \//'
if [[ $COMMAND_COUNT -gt 10 ]]; then
  echo "  ... and $(( COMMAND_COUNT - 10 )) more"
fi

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
echo "To update:"
echo "  cd ~/.shipitsmarter/ai-knowledgebase && git pull"
echo ""
