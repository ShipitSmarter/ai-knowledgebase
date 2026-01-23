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

# Version
VERSION="0.0.2"

# Colors (using printf-compatible format)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Use printf for cross-platform color support
print() { printf '%b\n' "$1"; }
ok() { printf '  %b✓%b %s\n' "$GREEN" "$NC" "$1"; }
warn() { printf '  %b!%b %s\n' "$YELLOW" "$NC" "$1"; }
info() { printf '  %b→%b %s\n' "$BLUE" "$NC" "$1"; }

# Show intro screen
show_intro() {
  printf '\n%b' "$CYAN"
  cat << 'EOF'
       _____ _     _       _ _   _____                      _            
      / ____| |   (_)     (_) | / ____|                    | |           
     | (___ | |__  _ _ __  _| || (___  _ __ ___   __ _ _ __| |_ ___ _ __ 
      \___ \| '_ \| | '_ \| | __\___ \| '_ ` _ \ / _` | '__| __/ _ \ '__|
      ____) | | | | | |_) | | |_____) | | | | | | (_| | |  | ||  __/ |   
     |_____/|_| |_|_| .__/|_|\__|_____/|_| |_| |_|\__,_|_|   \__\___|_|   
                    | |                                                  
                    |_|                                                  
EOF
  printf '%b\n' "$NC"
  printf '        %bAI Knowledgebase%b %bv%s%b\n' "$BOLD" "$NC" "$DIM" "$VERSION" "$NC"
  printf '\n'
  printf '                  %b     🚀%b\n' "$YELLOW" "$NC"
  printf '                  %b    /|%b\n' "$DIM" "$NC"
  printf '                  %b   / |%b\n' "$DIM" "$NC"
  printf '                  %b  /  |%b\n' "$DIM" "$NC"
  printf '                  %b /   |%b\n' "$DIM" "$NC"
  printf '                  %b/____|%b\n' "$DIM" "$NC"
  printf '                  %b  ||%b\n' "$YELLOW" "$NC"
  printf '                  %b \\||/%b\n' "$YELLOW" "$NC"
  printf '                  %b  \\/%b\n' "$YELLOW" "$NC"
  printf '\n'
  printf '  %bSkills, commands, and agents for OpenCode%b\n' "$DIM" "$NC"
  printf '  %bhttps://github.com/ShipitSmarter/ai-knowledgebase%b\n' "$DIM" "$NC"
  printf '\n'
}

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
  "${HOME}/Documents/ai-knowledgebase"
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

# List items in a directory
list_items() {
  local dir="$1"
  local type="$2"
  local items=()
  
  if [[ ! -d "$dir" ]]; then
    return
  fi
  
  case "$type" in
    skills)
      # Skills are directories containing SKILL.md (can be nested)
      while IFS= read -r skill_file; do
        local skill_dir=$(dirname "$skill_file")
        local skill_name=$(basename "$skill_dir")
        items+=("$skill_name")
      done < <(find "$dir" -name "SKILL.md" -type f 2>/dev/null | sort)
      ;;
    commands)
      # Commands are .md files
      for f in "$dir"/*.md; do
        [[ -f "$f" ]] && items+=("$(basename "$f" .md)")
      done
      ;;
    agents)
      # Agents are .md files
      for f in "$dir"/*.md; do
        [[ -f "$f" ]] && items+=("$(basename "$f" .md)")
      done
      ;;
    plugins)
      # Plugins are .ts files
      for f in "$dir"/*.ts; do
        [[ -f "$f" ]] && items+=("$(basename "$f" .ts)")
      done
      ;;
  esac
  
  # Print items
  if [[ ${#items[@]} -gt 0 ]]; then
    printf '%s\n' "${items[@]}"
  fi
}

# Verify setup
verify() {
  printf '\n'
  printf '%bSetup Status%b\n' "$BOLD" "$NC"
  printf '\n'
  
  command -v opencode &>/dev/null && ok "OpenCode installed" || warn "OpenCode not installed"
  
  [[ -f "$CONFIG_DIR/opencode.json" ]] && ok "Config exists" || warn "No config"
  
  printf '\n'
  
  # Skills
  if [[ -L "$CONFIG_DIR/skills" ]]; then
    local skills_dir=$(readlink "$CONFIG_DIR/skills")
    local skills=($(list_items "$skills_dir" "skills"))
    ok "Skills (${#skills[@]}):"
    for skill in "${skills[@]}"; do
      printf '     %b•%b %s\n' "$DIM" "$NC" "$skill"
    done
  else
    warn "skills not linked"
  fi
  
  printf '\n'
  
  # Commands
  if [[ -L "$CONFIG_DIR/commands" ]]; then
    local commands_dir=$(readlink "$CONFIG_DIR/commands")
    local commands=($(list_items "$commands_dir" "commands"))
    ok "Commands (${#commands[@]}):"
    for cmd in "${commands[@]}"; do
      printf '     %b•%b /%s\n' "$DIM" "$NC" "$cmd"
    done
  else
    warn "commands not linked"
  fi
  
  printf '\n'
  
  # Agents
  if [[ -L "$CONFIG_DIR/agents" ]]; then
    local agents_dir=$(readlink "$CONFIG_DIR/agents")
    local agents=($(list_items "$agents_dir" "agents"))
    ok "Agents (${#agents[@]}):"
    for agent in "${agents[@]}"; do
      printf '     %b•%b %s\n' "$DIM" "$NC" "$agent"
    done
  else
    warn "agents not linked"
  fi
  
  printf '\n'
  
  # Plugins
  if [[ -L "$CONFIG_DIR/plugins" ]]; then
    local plugins_dir=$(readlink "$CONFIG_DIR/plugins")
    local plugins=($(list_items "$plugins_dir" "plugins"))
    ok "Plugins (${#plugins[@]}):"
    for plugin in "${plugins[@]}"; do
      printf '     %b•%b %s\n' "$DIM" "$NC" "$plugin"
    done
  else
    warn "plugins not linked"
  fi
}

# Main
main() {
  show_intro
  
  [[ "$VERIFY_ONLY" == true ]] && { verify; exit 0; }
  
  # Step 1: OpenCode
  printf '%b1. OpenCode%b\n' "$BOLD" "$NC"
  printf '\n'
  if ! command -v opencode &>/dev/null; then
    warn "OpenCode not installed"
    printf '\n'
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
    printf '\n'
    printf '%b2. Repository Location%b\n' "$BOLD" "$NC"
    printf '\n'
    
    # First, search for existing installation
    local existing=$(find_existing_repo)
    if [[ -n "$existing" ]]; then
      ok "Found existing installation: $existing"
      printf '\n'
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
      
      printf '   Where should we install the AI knowledgebase?\n'
      printf '\n'
      if [[ "$OS" == "Darwin" ]]; then
        printf '   %bTip:%b On Mac, ~/Developer is the recommended location for code\n' "$BLUE" "$NC"
      fi
      printf '\n'
      read -p "   Location [$default]: " location </dev/tty
      REPO_ROOT="${location:-$default}"
      REPO_ROOT="${REPO_ROOT/#\~/$HOME}"
      
      printf '\n'
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
    printf '\n'
    printf '%b2. Repository%b\n' "$BOLD" "$NC"
    printf '\n'
    ok "Using local repo: $REPO_ROOT"
  fi
  
  # Step 3: Create symlinks
  printf '\n'
  printf '%b3. Linking to OpenCode%b\n' "$BOLD" "$NC"
  printf '\n'
  mkdir -p "$CONFIG_DIR"
  
  setup_link "skills" "$REPO_ROOT/skills"
  setup_link "commands" "$REPO_ROOT/commands"
  setup_link "agents" "$REPO_ROOT/agents"
  setup_link "plugins" "$REPO_ROOT/plugins"
  
  # Step 4: Config file
  printf '\n'
  printf '%b4. Configuration%b\n' "$BOLD" "$NC"
  printf '\n'
  local config_file="$CONFIG_DIR/opencode.json"
  local config_updated=false
  
  if [[ ! -f "$config_file" ]]; then
    cat > "$config_file" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": [
    "opencode-mem",
    "plugins/auto-session-name.ts"
  ]
}
EOF
    ok "Created config with plugins"
    config_updated=true
  else
    # Check if auto-session-name plugin is registered
    if ! grep -q "auto-session-name" "$config_file"; then
      # Add the plugin to existing config using a simple approach
      if grep -q '"plugin"' "$config_file"; then
        # Config has plugin array - add to it
        if command -v jq &>/dev/null; then
          local tmp_file=$(mktemp)
          jq '.plugin += ["plugins/auto-session-name.ts"] | .plugin |= unique' "$config_file" > "$tmp_file" && mv "$tmp_file" "$config_file"
          ok "Added auto-session-name plugin to config"
          config_updated=true
        else
          warn "Config exists but missing auto-session-name plugin"
          info "Add \"plugins/auto-session-name.ts\" to the plugin array in $config_file"
        fi
      else
        # Config doesn't have plugin array - add one
        if command -v jq &>/dev/null; then
          local tmp_file=$(mktemp)
          jq '. + {"plugin": ["opencode-mem", "plugins/auto-session-name.ts"]}' "$config_file" > "$tmp_file" && mv "$tmp_file" "$config_file"
          ok "Added plugins to config"
          config_updated=true
        else
          warn "Config exists but has no plugins configured"
          info "Add a plugin array to $config_file"
        fi
      fi
    else
      ok "Config already has auto-session-name plugin"
    fi
  fi
  
  [[ "$config_updated" == false ]] && ok "Config exists"
  
  # Step 5: Optional dependencies
  if [[ "$SKIP_DEPS" == false ]] && command -v npm &>/dev/null; then
    printf '\n'
    printf '%b5. Optional: Playwright%b\n' "$BOLD" "$NC"
    printf '\n'
    if command -v playwright &>/dev/null; then
      ok "Playwright already installed"
    else
      info "Installing Playwright (for browser-debug skill)..."
      npm install -g playwright 2>/dev/null && npx playwright install chromium 2>/dev/null && ok "Playwright installed" || warn "Playwright install failed (optional, can skip)"
    fi
  fi
  
  # Done
  printf '\n'
  printf '%b╭─────────────────────────────────────────╮%b\n' "$BOLD" "$NC"
  printf '%b│            Setup Complete!              │%b\n' "$BOLD" "$NC"
  printf '%b╰─────────────────────────────────────────╯%b\n' "$BOLD" "$NC"
  
  verify
  
  printf '\n'
  printf '  %bReady!%b Run %bopencode%b in any project folder.\n' "$GREEN" "$NC" "$BOLD" "$NC"
  printf '\n'
  printf '  To update later:\n'
  printf '    cd %s && git pull\n' "$REPO_ROOT"
  printf '\n'
}

main "$@"
