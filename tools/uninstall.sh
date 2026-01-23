#!/bin/bash
#
# uninstall.sh - Remove ShipitSmarter AI Knowledgebase from OpenCode
#
# Usage: ./tools/uninstall.sh
#
# This script:
#   - Removes symlinks from ~/.config/opencode/ that point to ai-knowledgebase
#   - Optionally removes the cloned repository
#   - Preserves user's opencode.json config
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

ok() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }
header() { echo -e "\n${BLUE}=== $1 ===${NC}\n"; }

CONFIG_DIR="${HOME}/.config/opencode"

# Detect repo location
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

# Remove symlink only if it points to ai-knowledgebase
remove_link() {
  local name="$1"
  local link="$CONFIG_DIR/$name"
  
  if [[ ! -L "$link" ]]; then
    warn "$name is not a symlink, skipping"
    return
  fi
  
  local target="$(readlink "$link")"
  
  # Check if it points to ai-knowledgebase (contains /skills, /commands, etc.)
  if [[ "$target" == *"/ai-knowledgebase/"* ]] || [[ "$target" == *"/ai-knowledgebase" ]]; then
    rm "$link"
    ok "Removed $name → $target"
  else
    warn "$name points to $target (not ai-knowledgebase), keeping"
  fi
}

# Main
main() {
  echo ""
  echo "=== ShipitSmarter AI Knowledgebase Uninstall ==="
  echo ""
  
  # Step 1: Remove symlinks
  header "Removing Symlinks"
  
  if [[ ! -d "$CONFIG_DIR" ]]; then
    warn "No OpenCode config directory found at $CONFIG_DIR"
  else
    for item in skills commands agents plugins; do
      if [[ -e "$CONFIG_DIR/$item" ]]; then
        remove_link "$item"
      else
        ok "$item already removed"
      fi
    done
    
    info "Kept opencode.json (your personal config)"
  fi
  
  # Step 2: Optionally remove repo
  header "Repository"
  
  if [[ -n "$REPO_ROOT" ]]; then
    echo "Repository found at: $REPO_ROOT"
    echo ""
    read -p "Delete the repository folder? (y/N) " -n 1 -r </dev/tty
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm -rf "$REPO_ROOT"
      ok "Deleted $REPO_ROOT"
    else
      ok "Kept repository at $REPO_ROOT"
    fi
  else
    info "Repository location not detected (already removed or not in expected location)"
  fi
  
  # Done
  header "Uninstall Complete"
  
  echo -e "${GREEN}AI Knowledgebase has been removed from OpenCode.${NC}"
  echo ""
  echo "OpenCode itself was not removed. To reinstall later:"
  echo "  curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash"
  echo ""
}

main "$@"
