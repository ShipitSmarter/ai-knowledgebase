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
VERSION="0.0.4"

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
  printf '\n'
  printf '%b' "$CYAN"
  cat << 'EOF'
        ╭────────────────────────────────────────────────────────────────╮
        │                                                                │
        │   ██╗   ██╗██╗██╗   ██╗ █████╗            ▄▀▀▀▄                │
        │   ██║   ██║██║╚██╗ ██╔╝██╔══██╗          █  ●  █═══════►       │
        │   ██║   ██║██║ ╚████╔╝ ███████║          █     █ · _ .         │
        │   ╚██╗ ██╔╝██║  ╚██╔╝  ██╔══██║          █ ─── █    *          │
        │    ╚████╔╝ ██║   ██║   ██║  ██║    *   . █     █ .             │
        │     ╚═══╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝  ·  *   ▄█▄▄▄▄▄█▄    ·         │
        │                                        ◢██◣ ◢██◣               │
        │       AI Knowledgebase                 ▀▀▀   ▀▀▀               │
        │                                                                │
        ╰────────────────────────────────────────────────────────────────╯
EOF
  printf '%b\n' "$NC"
  printf '                             %bv%s%b\n' "$DIM" "$VERSION" "$NC"
  printf '\n'
  printf '           %bSkills, commands, and agents for OpenCode%b\n' "$DIM" "$NC"
  printf '        %bhttps://github.com/ShipitSmarter/ai-knowledgebase%b\n' "$DIM" "$NC"
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
  # First check the static list
  for dir in "${SEARCH_DIRS[@]}"; do
    if detect_repo "$dir"; then
      echo "$dir"
      return 0
    fi
  done
  
  # Then search one level deep in Documents (for custom folders like ~/Documents/sis/)
  if [[ -d "${HOME}/Documents" ]]; then
    for subdir in "${HOME}/Documents"/*/ai-knowledgebase; do
      if [[ -d "$subdir" ]] && detect_repo "$subdir"; then
        echo "$subdir"
        return 0
      fi
    done
  fi
  
  # Also search one level deep in home directory for custom git folders
  for subdir in "${HOME}"/*/ai-knowledgebase; do
    if [[ -d "$subdir" ]] && detect_repo "$subdir"; then
      echo "$subdir"
      return 0
    fi
  done
  
  return 1
}

# Find the best default git directory (for fresh install)
find_default_git_dir() {
  # macOS: Check common locations
  if [[ "$OS" == "Darwin" ]]; then
    for dir in "${HOME}/Developer" "${HOME}/Projects" "${HOME}/Code" "${HOME}/git" "${HOME}/repos" "${HOME}/Documents/GitHub" "${HOME}/Documents/git"; do
      if [[ -d "$dir" ]]; then
        echo "$dir"
        return
      fi
    done
    # Default to Developer folder (Apple's recommended location)
    echo "${HOME}/Developer"
    return
  fi
  
  # Linux: Check common locations
  for dir in "${HOME}/git" "${HOME}/repos" "${HOME}/code" "${HOME}/projects" "${HOME}/dev"; do
    if [[ -d "$dir" ]]; then
      echo "$dir"
      return
    fi
  done
  
  # Fallback
  echo "${HOME}/git"
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
    printf '%b2. Repository%b\n' "$BOLD" "$NC"
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
    
    # If still no repo (not found or user declined), ask which flow
    if [[ -z "$REPO_ROOT" ]]; then
      printf '   Do you already have ai-knowledgebase cloned?\n'
      printf '\n'
      printf '   %b1%b) Yes - I have it cloned somewhere\n' "$BOLD" "$NC"
      printf '   %b2%b) No  - Clone it for me (fresh install)\n' "$BOLD" "$NC"
      printf '\n'
      read -p "   Choice [2]: " choice </dev/tty
      choice="${choice:-2}"
      
      printf '\n'
      
      if [[ "$choice" == "1" ]]; then
        # Flow 1: User has existing repo - ask for full path
        printf '   Enter the path to your ai-knowledgebase folder:\n'
        printf '\n'
        read -p "   Path: " repo_path </dev/tty
        repo_path="${repo_path/#\~/$HOME}"
        
        printf '\n'
        if [[ -d "$repo_path" ]] && detect_repo "$repo_path"; then
          REPO_ROOT="$repo_path"
          info "Updating existing repo..."
          git -C "$REPO_ROOT" pull --quiet 2>/dev/null || true
          ok "Repository ready"
        else
          warn "Not a valid ai-knowledgebase folder: $repo_path"
          printf '   Expected to find skills/, commands/, and AGENTS.md\n'
          exit 1
        fi
      else
        # Flow 2: Fresh install - ask for git folder, we'll clone into it
        local default_git_dir=$(find_default_git_dir)
        
        printf '   Where do you keep your git repositories?\n'
        printf '\n'
        if [[ "$OS" == "Darwin" ]]; then
          printf '   %bTip:%b On Mac, ~/Developer is the recommended location\n' "$BLUE" "$NC"
          printf '\n'
        fi
        read -p "   Git folder [$default_git_dir]: " git_dir </dev/tty
        git_dir="${git_dir:-$default_git_dir}"
        git_dir="${git_dir/#\~/$HOME}"
        
        REPO_ROOT="$git_dir/ai-knowledgebase"
        
        printf '\n'
        if [[ -d "$REPO_ROOT" ]] && detect_repo "$REPO_ROOT"; then
          info "Found existing repo, updating..."
          git -C "$REPO_ROOT" pull --quiet 2>/dev/null || true
        else
          info "Cloning to $REPO_ROOT..."
          mkdir -p "$git_dir"
          git clone --quiet "$REPO_URL" "$REPO_ROOT"
        fi
        ok "Repository ready"
      fi
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
  
  # Step 4: Optional dependencies
  if [[ "$SKIP_DEPS" == false ]] && command -v npm &>/dev/null; then
    printf '\n'
    printf '%b4. Optional: Playwright%b\n' "$BOLD" "$NC"
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
