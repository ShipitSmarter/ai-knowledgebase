#!/bin/bash
#
# setup.sh - Set up ShipitSmarter AI Knowledgebase for OpenCode
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
#
# Or locally: ./tools/setup.sh
#
# Options:
#   --skip-deps   Skip optional dependencies (Playwright)
#   --verify      Just verify the current setup
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

ok() { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }
info() { echo -e "  ${BLUE}→${NC} $1"; }

# Configuration
REPO_URL="https://github.com/ShipitSmarter/ai-knowledgebase"
CONFIG_DIR="${HOME}/.config/opencode"

# Detect OS
OS="$(uname -s)"

# Detect if we're in the repo already
detect_repo() {
  local dir="$1"
  [[ -d "$dir/skills" && -d "$dir/commands" && -f "$dir/AGENTS.md" ]]
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)" || SCRIPT_DIR=""

if [[ -n "$SCRIPT_DIR" ]] && detect_repo "$(dirname "$SCRIPT_DIR")"; then
  REPO_ROOT="$(dirname "$SCRIPT_DIR")"
elif detect_repo "$(pwd)"; then
  REPO_ROOT="$(pwd)"
else
  REPO_ROOT=""
fi

# Parse args
SKIP_DEPS=false
VERIFY_ONLY=false
for arg in "$@"; do
  case $arg in
    --skip-deps) SKIP_DEPS=true ;;
    --verify) VERIFY_ONLY=true ;;
  esac
done

# Common directories to search for existing installations
SEARCH_DIRS=(
  "${HOME}/Developer/ai-knowledgebase"
  "${HOME}/Projects/ai-knowledgebase"
  "${HOME}/Code/ai-knowledgebase"
  "${HOME}/git/ai-knowledgebase"
  "${HOME}/repos/ai-knowledgebase"
  "${HOME}/code/ai-knowledgebase"
  "${HOME}/projects/ai-knowledgebase"
  "${HOME}/dev/ai-knowledgebase"
  "${HOME}/Documents/GitHub/ai-knowledgebase"
  "${HOME}/Documents/git/ai-knowledgebase"
)

# Find existing ai-knowledgebase installation
find_existing_repo() {
  for dir in "${SEARCH_DIRS[@]}"; do
    if detect_repo "$dir"; then
      echo "$dir"
      return 0
    fi
  done
  return 1
}

# Find the best default install location
find_default_location() {
  # macOS: Check common locations
  if [[ "$OS" == "Darwin" ]]; then
    # Prefer existing git folders
    for dir in "${HOME}/Developer" "${HOME}/Projects" "${HOME}/Code" "${HOME}/git" "${HOME}/repos" "${HOME}/Documents/GitHub" "${HOME}/Documents/git"; do
      if [[ -d "$dir" ]]; then
        echo "$dir/ai-knowledgebase"
        return
      fi
    done
    # Default to Developer folder (Apple's recommended location)
    echo "${HOME}/Developer/ai-knowledgebase"
    return
  fi
  
  # Linux: Check common locations
  for dir in "${HOME}/git" "${HOME}/repos" "${HOME}/code" "${HOME}/projects" "${HOME}/dev"; do
    if [[ -d "$dir" ]]; then
      echo "$dir/ai-knowledgebase"
      return
    fi
  done
  
  # Fallback
  echo "${HOME}/git/ai-knowledgebase"
}

# Setup a symlink
setup_link() {
  local name="$1" target="$2"
  local link="$CONFIG_DIR/$name"
  
  if [[ -L "$link" ]]; then
    [[ "$(readlink "$link")" == "$target" ]] && { ok "$name linked"; return; }
    rm "$link"
  elif [[ -d "$link" ]]; then
    rm -rf "$link"
  fi
  
  ln -sf "$target" "$link"
  ok "$name → $target"
}

# Verify setup
verify() {
  echo ""
  echo -e "${BOLD}Setup Status${NC}"
  echo ""
  
  command -v opencode &>/dev/null && ok "OpenCode installed" || warn "OpenCode not installed"
  
  for item in skills commands agents plugins; do
    [[ -L "$CONFIG_DIR/$item" ]] && ok "$item linked" || warn "$item not linked"
  done
  
  [[ -f "$CONFIG_DIR/opencode.json" ]] && ok "Config exists" || warn "No config"
}

# Main
main() {
  echo ""
  echo -e "${BOLD}╭─────────────────────────────────────────╮${NC}"
  echo -e "${BOLD}│  ShipitSmarter AI Knowledgebase Setup   │${NC}"
  echo -e "${BOLD}╰─────────────────────────────────────────╯${NC}"
  echo ""
  
  [[ "$VERIFY_ONLY" == true ]] && { verify; exit 0; }
  
  # Step 1: OpenCode
  echo -e "${BOLD}1. OpenCode${NC}"
  echo ""
  if ! command -v opencode &>/dev/null; then
    warn "OpenCode not installed"
    echo ""
    read -p "   Install OpenCode now? (Y/n) " -n 1 -r </dev/tty
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      info "Installing OpenCode..."
      curl -fsSL https://opencode.ai/install | bash
      export PATH="$HOME/.local/bin:$PATH"
    fi
  else
    ok "OpenCode installed"
  fi
  
  # Step 2: Clone repo if needed
  if [[ -z "$REPO_ROOT" ]]; then
    echo ""
    echo -e "${BOLD}2. Repository Location${NC}"
    echo ""
    
    # First, search for existing installation
    local existing=$(find_existing_repo)
    if [[ -n "$existing" ]]; then
      ok "Found existing installation: $existing"
      echo ""
      read -p "   Use this location? (Y/n) " -n 1 -r </dev/tty
      echo
      if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        REPO_ROOT="$existing"
        info "Updating existing repo..."
        git -C "$REPO_ROOT" pull --quiet 2>/dev/null || true
        ok "Repository ready"
      fi
    fi
    
    # If still no repo (not found or user declined), prompt for location
    if [[ -z "$REPO_ROOT" ]]; then
      local default=$(find_default_location)
      
      echo "   Where should we install the AI knowledgebase?"
      echo ""
      if [[ "$OS" == "Darwin" ]]; then
        echo "   ${BLUE}Tip:${NC} On Mac, ~/Developer is the recommended location for code"
      fi
      echo ""
      read -p "   Location [$default]: " location </dev/tty
      REPO_ROOT="${location:-$default}"
      REPO_ROOT="${REPO_ROOT/#\~/$HOME}"
      
      echo ""
      if [[ -d "$REPO_ROOT" ]] && detect_repo "$REPO_ROOT"; then
        info "Updating existing repo..."
        git -C "$REPO_ROOT" pull --quiet 2>/dev/null || true
      else
        info "Cloning to $REPO_ROOT..."
        mkdir -p "$(dirname "$REPO_ROOT")"
        git clone --quiet "$REPO_URL" "$REPO_ROOT"
      fi
      ok "Repository ready"
    fi
  else
    echo ""
    echo -e "${BOLD}2. Repository${NC}"
    echo ""
    ok "Using local repo: $REPO_ROOT"
  fi
  
  # Step 3: Create symlinks
  echo ""
  echo -e "${BOLD}3. Linking to OpenCode${NC}"
  echo ""
  mkdir -p "$CONFIG_DIR"
  
  setup_link "skills" "$REPO_ROOT/skills"
  setup_link "commands" "$REPO_ROOT/commands"
  setup_link "agents" "$REPO_ROOT/agents"
  setup_link "plugins" "$REPO_ROOT/plugins"
  
  # Step 4: Config file
  echo ""
  echo -e "${BOLD}4. Configuration${NC}"
  echo ""
  if [[ ! -f "$CONFIG_DIR/opencode.json" ]]; then
    echo '{"$schema": "https://opencode.ai/config.json", "plugin": ["opencode-mem"]}' > "$CONFIG_DIR/opencode.json"
    ok "Created config with opencode-mem"
  else
    ok "Config exists"
  fi
  
  # Step 5: Optional dependencies
  if [[ "$SKIP_DEPS" == false ]] && command -v npm &>/dev/null; then
    echo ""
    echo -e "${BOLD}5. Optional: Playwright${NC}"
    echo ""
    if command -v playwright &>/dev/null; then
      ok "Playwright already installed"
    else
      info "Installing Playwright (for browser-debug skill)..."
      npm install -g playwright 2>/dev/null && npx playwright install chromium 2>/dev/null && ok "Playwright installed" || warn "Playwright install failed (optional, can skip)"
    fi
  fi
  
  # Done
  echo ""
  echo -e "${BOLD}╭─────────────────────────────────────────╮${NC}"
  echo -e "${BOLD}│            Setup Complete!              │${NC}"
  echo -e "${BOLD}╰─────────────────────────────────────────╯${NC}"
  
  verify
  
  echo ""
  echo -e "  ${GREEN}Ready!${NC} Run ${BOLD}opencode${NC} in any project folder."
  echo ""
  echo "  To update later:"
  echo "    cd $REPO_ROOT && git pull"
  echo ""
}

main "$@"
