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
#   --skip-deps   Skip optional dependencies (Playwright, Google AI Search plugin)
#   --verify      Just verify the current setup
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ok() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }
header() { echo -e "\n${BLUE}=== $1 ===${NC}\n"; }

# Configuration
REPO_URL="https://github.com/ShipitSmarter/ai-knowledgebase"
CONFIG_DIR="${HOME}/.config/opencode"

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
  header "Setup Status"
  
  command -v opencode &>/dev/null && ok "OpenCode installed" || warn "OpenCode not installed"
  
  for item in skills commands agents plugins; do
    [[ -L "$CONFIG_DIR/$item" ]] && ok "$item linked" || warn "$item not linked"
  done
  
  [[ -f "$CONFIG_DIR/opencode.json" ]] && ok "Config exists" || warn "No config"
}

# Main
main() {
  echo ""
  echo "=== ShipitSmarter AI Knowledgebase Setup ==="
  echo ""
  
  [[ "$VERIFY_ONLY" == true ]] && { verify; exit 0; }
  
  # Step 1: OpenCode
  if ! command -v opencode &>/dev/null; then
    warn "OpenCode not installed"
    read -p "Install OpenCode now? (Y/n) " -n 1 -r </dev/tty
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
    header "Clone Repository"
    
    # Detect git directory
    local default="${HOME}/git/ai-knowledgebase"
    for dir in git repos code projects; do
      [[ -d "${HOME}/$dir" ]] && { default="${HOME}/$dir/ai-knowledgebase"; break; }
    done
    
    echo "Where to install? (alongside your other git repos)"
    read -p "Location [$default]: " location </dev/tty
    REPO_ROOT="${location:-$default}"
    REPO_ROOT="${REPO_ROOT/#\~/$HOME}"
    
    if [[ -d "$REPO_ROOT" ]]; then
      info "Updating existing repo..."
      git -C "$REPO_ROOT" pull --quiet
    else
      info "Cloning..."
      mkdir -p "$(dirname "$REPO_ROOT")"
      git clone --quiet "$REPO_URL" "$REPO_ROOT"
    fi
    ok "Repository at $REPO_ROOT"
  else
    ok "Using local repo: $REPO_ROOT"
  fi
  
  # Step 3: Create symlinks
  header "Linking to OpenCode"
  mkdir -p "$CONFIG_DIR"
  
  setup_link "skills" "$REPO_ROOT/skills"
  setup_link "commands" "$REPO_ROOT/commands"
  setup_link "agents" "$REPO_ROOT/agents"
  setup_link "plugins" "$REPO_ROOT/plugins"
  
  # Step 4: Config file
  if [[ ! -f "$CONFIG_DIR/opencode.json" ]]; then
    echo '{"$schema": "https://opencode.ai/config.json", "plugin": ["opencode-mem"]}' > "$CONFIG_DIR/opencode.json"
    ok "Created config with opencode-mem"
  else
    ok "Config exists"
  fi
  
  # Step 5: Optional dependencies
  if [[ "$SKIP_DEPS" == false ]]; then
    header "Optional Dependencies"
    
    if command -v playwright &>/dev/null; then
      ok "Playwright installed"
    else
      info "Installing Playwright (for browser-debug skill)..."
      npm install -g playwright 2>/dev/null && npx playwright install chromium 2>/dev/null || warn "Playwright install failed (optional)"
    fi
  fi
  
  # Done
  header "Setup Complete"
  verify
  
  echo ""
  echo -e "${GREEN}Ready! Run 'opencode' in any project folder.${NC}"
  echo ""
  echo "To update later: cd $REPO_ROOT && git pull"
  echo ""
}

main "$@"
