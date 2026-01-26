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
#   --quiet       Skip Trucky animations (for CI)
#

set -e

# Version
VERSION="0.2.0"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Helpers
print() { printf '%b\n' "$1"; }
ok() { printf '  %b✓%b %s\n' "$GREEN" "$NC" "$1"; }
warn() { printf '  %b!%b %s\n' "$YELLOW" "$NC" "$1"; }
info() { printf '  %b→%b %s\n' "$BLUE" "$NC" "$1"; }
err() { printf '  %b✗%b %s\n' "$RED" "$NC" "$1"; }

# Detect if we can use Unicode
can_unicode() {
  [[ "$(uname -s)" != "MINGW"* && "$(uname -s)" != "CYGWIN"* ]]
}

# ═══════════════════════════════════════════════════════════════════════════════
# TRUCKY - The Delivery Truck Mascot
# ═══════════════════════════════════════════════════════════════════════════════

# Trucky's faces
TRUCKY_EYES_HAPPY="◠ ◠"
TRUCKY_EYES_NORMAL="● ●"
TRUCKY_EYES_EXCITED="◉ ◉"
TRUCKY_EYES_THINKING="◔ ◔"
TRUCKY_EYES_WINK="◠ ●"
TRUCKY_EYES_WORRIED="• •"

# ASCII fallbacks
TRUCKY_EYES_HAPPY_ASCII="^ ^"
TRUCKY_EYES_NORMAL_ASCII="o o"
TRUCKY_EYES_EXCITED_ASCII="O O"
TRUCKY_EYES_THINKING_ASCII=". o"
TRUCKY_EYES_WINK_ASCII="^ o"
TRUCKY_EYES_WORRIED_ASCII=". ."

# Trucky character (delivery truck with face in cargo area)
trucky() {
  local eyes="$1"
  local msg="$2"
  local action="${3:-}"
  
  if ! can_unicode; then
    # ASCII fallback
    case "$eyes" in
      "$TRUCKY_EYES_HAPPY") eyes="$TRUCKY_EYES_HAPPY_ASCII" ;;
      "$TRUCKY_EYES_NORMAL") eyes="$TRUCKY_EYES_NORMAL_ASCII" ;;
      "$TRUCKY_EYES_EXCITED") eyes="$TRUCKY_EYES_EXCITED_ASCII" ;;
      "$TRUCKY_EYES_THINKING") eyes="$TRUCKY_EYES_THINKING_ASCII" ;;
      "$TRUCKY_EYES_WINK") eyes="$TRUCKY_EYES_WINK_ASCII" ;;
      "$TRUCKY_EYES_WORRIED") eyes="$TRUCKY_EYES_WORRIED_ASCII" ;;
    esac
    
    printf '\n'
    printf '    %b________________%b\n' "$CYAN" "$NC"
    printf '   %b|     %s     |%b\n' "$CYAN" "$eyes" "$NC"
    printf '   %b|      %b%s%b      |====%b\n' "$CYAN" "$MAGENTA" "u" "$CYAN" "$NC"
    printf '   %b|______________|_ |%b\n' "$CYAN" "$NC"
    printf '   %b(__) |ShipIt|  (__)%b\n' "$DIM" "$NC"
    printf '\n'
  else
    # Unicode version - friendly delivery truck
    printf '\n'
    printf '    %b┌──────────────┐%b\n' "$CYAN" "$NC"
    printf '   %b │    %s    │%b\n' "$CYAN" "$eyes" "$NC"
    printf '   %b │      %b◡%b      │▓▓▓▓%b\n' "$CYAN" "$MAGENTA" "$CYAN" "$NC"
    printf '   %b └──────────────┴─┐%b\n' "$CYAN" "$NC"
    printf '    %b◯%b %b░ShipIt░%b  %b◯%b\n' "$DIM" "$NC" "$DIM" "$NC" "$DIM" "$NC"
    printf '\n'
  fi
  
  # Print action in dim if provided
  if [[ -n "$action" ]]; then
    printf '   %b%s%b\n' "$DIM" "$action" "$NC"
  fi
  
  # Print message
  printf '   %bTrucky:%b %s\n' "$BOLD$CYAN" "$NC" "$msg"
  printf '\n'
}

# Trucky says something with typing effect
trucky_say() {
  local eyes="$1"
  local msg="$2"
  local action="${3:-}"
  
  if [[ "$QUIET" == true ]]; then
    # Skip animation in quiet mode
    trucky "$eyes" "$msg" "$action"
    return
  fi
  
  trucky "$eyes" "" "$action"
  
  # Move cursor up to message line and type it out
  printf '\033[1A'  # Move up 1 line
  printf '\r   %bTrucky:%b ' "$BOLD$CYAN" "$NC"
  
  # Type out message word by word
  local words=($msg)
  for word in "${words[@]}"; do
    printf '%s ' "$word"
    sleep 0.05
  done
  printf '\n\n'
}

# Random greetings
GREETINGS=(
  "*beep beep* Special delivery!"
  "*revs engine* Ready to ship some skills!"
  "*honk honk* Your AI toolkit has arrived!"
  "*pulls up* Did someone order some automation?"
  "*parks excitedly* Let's get you set up!"
)

WORKING_MSGS=(
  "*loading cargo*"
  "*checking manifest*"
  "*organizing packages*"
  "*securing shipment*"
  "*calibrating GPS*"
)

SUCCESS_MSGS=(
  "*happy horn sounds*"
  "*does a little truck dance*"
  "*flashes headlights excitedly*"
  "*revs engine triumphantly*"
)

ERROR_MSGS=(
  "*confused engine noises*"
  "*checks mirrors nervously*"
  "*honks softly*"
)

random_from() {
  local arr=("$@")
  echo "${arr[$RANDOM % ${#arr[@]}]}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# INTRO
# ═══════════════════════════════════════════════════════════════════════════════

show_intro() {
  clear 2>/dev/null || true
  printf '\n'
  
  if [[ "$QUIET" != true ]]; then
    # Animated truck arrival
    local frames=(
      "                                        🚚"
      "                              🚚        "
      "                    🚚                  "
      "          🚚                            "
      "🚚                                      "
    )
    
    if can_unicode; then
      for frame in "${frames[@]}"; do
        printf '\r%s' "$frame"
        sleep 0.08
      done
      printf '\r                                          \n'
    fi
  fi
  
  # Logo
  printf '%b' "$CYAN"
  cat << 'EOF'

       _____ _     _       _ _   _____                      _            
      / ____| |   (_)     (_) | / ____|                    | |           
     | (___ | |__  _ _ __  _| || (___  _ __ ___   __ _ _ __| |_ ___ _ __ 
      \___ \| '_ \| | '_ \| | __\___ \| '_ ` _ \ / _` | '__| __/ _ \ '__|
      ____) | | | | | |_) | | |_____) | | | | | | (_| | |  | ||  __/ |   
     |_____/|_| |_|_| .__/|_|\__|_____/|_| |_| |_|\__,_|_|   \__\___|_|   
                    | |                                                   
                    |_|   AI Knowledgebase                               
EOF
  printf '%b' "$NC"
  printf '\n'
  printf '              %bSkills · Commands · Agents%b\n' "$DIM" "$NC"
  printf '                      %bv%s%b\n' "$DIM" "$VERSION" "$NC"
  printf '\n'
}

# ═══════════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

REPO_URL="https://github.com/ShipitSmarter/ai-knowledgebase"
CONFIG_DIR="${HOME}/.config/opencode"
SECRETS_FILE="${CONFIG_DIR}/.secrets"

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
QUIET=false
for arg in "$@"; do
  case $arg in
    --skip-deps) SKIP_DEPS=true ;;
    --verify) VERIFY_ONLY=true ;;
    --quiet) QUIET=true ;;
  esac
done

# Auto-detect CI
if [[ -n "$CI" || -n "$GITHUB_ACTIONS" || -n "$GITLAB_CI" ]]; then
  QUIET=true
fi

# Common directories to search
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

find_existing_repo() {
  for dir in "${SEARCH_DIRS[@]}"; do
    if detect_repo "$dir"; then
      echo "$dir"
      return 0
    fi
  done
  
  # Search one level deep in Documents
  if [[ -d "${HOME}/Documents" ]]; then
    for subdir in "${HOME}/Documents"/*/ai-knowledgebase; do
      if [[ -d "$subdir" ]] && detect_repo "$subdir"; then
        echo "$subdir"
        return 0
      fi
    done
  fi
  
  # Search one level deep in home
  for subdir in "${HOME}"/*/ai-knowledgebase; do
    if [[ -d "$subdir" ]] && detect_repo "$subdir"; then
      echo "$subdir"
      return 0
    fi
  done
  
  return 1
}

find_default_git_dir() {
  if [[ "$OS" == "Darwin" ]]; then
    for dir in "${HOME}/Developer" "${HOME}/Projects" "${HOME}/Code" "${HOME}/git"; do
      if [[ -d "$dir" ]]; then
        echo "$dir"
        return
      fi
    done
    echo "${HOME}/Developer"
    return
  fi
  
  for dir in "${HOME}/git" "${HOME}/repos" "${HOME}/code" "${HOME}/projects" "${HOME}/dev"; do
    if [[ -d "$dir" ]]; then
      echo "$dir"
      return
    fi
  done
  
  echo "${HOME}/git"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SETUP FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

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
  ok "$name → $(basename "$target")"
}

list_items() {
  local dir="$1"
  local type="$2"
  local items=()
  
  [[ ! -d "$dir" ]] && return
  
  case "$type" in
    skills)
      while IFS= read -r skill_file; do
        local skill_dir=$(dirname "$skill_file")
        local skill_name=$(basename "$skill_dir")
        items+=("$skill_name")
      done < <(find "$dir" -name "SKILL.md" -type f 2>/dev/null | sort)
      ;;
    commands|agents)
      for f in "$dir"/*.md; do
        [[ -f "$f" ]] && items+=("$(basename "$f" .md)")
      done
      ;;
  esac
  
  [[ ${#items[@]} -gt 0 ]] && printf '%s\n' "${items[@]}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# SECRETS MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════════

setup_secrets() {
  printf '\n'
  printf '%b5. MCP Server Secrets%b\n' "$BOLD" "$NC"
  printf '\n'
  
  if [[ -f "$SECRETS_FILE" ]]; then
    ok "Secrets file exists: $SECRETS_FILE"
    printf '\n'
    read -p "   Update secrets? (y/N) " -n 1 -r </dev/tty
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && return
  fi
  
  trucky_say "$TRUCKY_EYES_NORMAL" "Let's set up your MCP server credentials!" "*pulls out clipboard*"
  
  printf '   These are optional - press Enter to skip any.\n'
  printf '   Secrets are stored in: %b%s%b\n\n' "$DIM" "$SECRETS_FILE" "$NC"
  
  # Notion
  printf '   %bNotion API Key%b (for searching Notion workspace)\n' "$BOLD" "$NC"
  printf '   Get one at: https://www.notion.so/my-integrations\n'
  read -p "   NOTION_API_KEY: " -r notion_key </dev/tty
  
  printf '\n'
  
  # Google AI Search (if applicable)
  printf '   %bGoogle AI Search Key%b (for web research)\n' "$BOLD" "$NC"
  read -p "   GOOGLE_AI_SEARCH_KEY: " -r google_key </dev/tty
  
  printf '\n'
  
  # Write secrets file
  mkdir -p "$(dirname "$SECRETS_FILE")"
  cat > "$SECRETS_FILE" << EOF
# OpenCode MCP Server Secrets
# Generated by Trucky on $(date)
# 
# Source this file in your shell profile:
#   source ~/.config/opencode/.secrets

EOF
  
  [[ -n "$notion_key" ]] && echo "export NOTION_API_KEY=\"$notion_key\"" >> "$SECRETS_FILE"
  [[ -n "$google_key" ]] && echo "export GOOGLE_AI_SEARCH_KEY=\"$google_key\"" >> "$SECRETS_FILE"
  
  chmod 600 "$SECRETS_FILE"
  
  if [[ -n "$notion_key" || -n "$google_key" ]]; then
    ok "Secrets saved to $SECRETS_FILE"
    printf '\n'
    printf '   %bImportant:%b Add this to your ~/.bashrc or ~/.zshrc:\n' "$YELLOW" "$NC"
    printf '   %bsource %s%b\n' "$DIM" "$SECRETS_FILE" "$NC"
  else
    info "No secrets configured (that's fine, you can add them later)"
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# SAFETY PERMISSIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Generate default config JSON
get_default_config() {
  cat << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "bash": {
      "*": "allow",
      "kubectl*": "deny",
      "kubectl *": "deny",
      "git commit*": "ask",
      "git push*": "ask",
      "git pull*": "ask",
      "git rebase*": "ask",
      "git merge*": "ask",
      "git reset*": "ask",
      "git checkout*": "ask",
      "git switch*": "ask",
      "git fetch*": "ask",
      "git cherry-pick*": "ask",
      "git stash*": "ask",
      "git tag*": "ask",
      "git branch*": "ask",
      "git status*": "allow",
      "git log*": "allow",
      "git diff*": "allow",
      "git show*": "allow",
      "git ls-files*": "allow",
      "git remote*": "allow",
      "git config --get*": "allow",
      "git rev-parse*": "allow",
      "rm -rf*": "ask",
      "sudo*": "ask"
    }
  }
}
EOF
}

# Normalize JSON for comparison (remove whitespace, sort keys)
normalize_json() {
  local file="$1"
  if command -v jq &>/dev/null; then
    jq -S -c . "$file" 2>/dev/null
  else
    # Fallback: just remove all whitespace
    tr -d ' \n\t\r' < "$file"
  fi
}

# Setup safety permissions
setup_permissions() {
  local config_file="$CONFIG_DIR/opencode.json"
  local temp_default=$(mktemp)
  local temp_existing=$(mktemp)
  
  # Clean up temp files on exit
  trap "rm -f '$temp_default' '$temp_existing'" RETURN
  
  # Generate default config to temp file
  get_default_config > "$temp_default"
  
  # If config doesn't exist, create it with safety defaults
  if [[ ! -f "$config_file" ]]; then
    cat "$temp_default" > "$config_file"
    ok "Safety permissions configured"
  else
    # Config exists - check if it's different from defaults
    
    # First check if it has permission settings at all
    if ! grep -q '"permission"' "$config_file" 2>/dev/null; then
      warn "Existing config found without safety permissions"
      printf '\n'
      read -p "   Replace with recommended safety config? (Y/n) " -n 1 -r </dev/tty
      echo
      if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        # Backup old config
        cp "$config_file" "$config_file.backup"
        info "Backed up old config to opencode.json.backup"
        cat "$temp_default" > "$config_file"
        ok "Safety permissions configured"
      else
        info "Keeping existing config (no safety permissions)"
        warn "You can manually add permissions from: opencode/opencode.json.example"
      fi
      return
    fi
    
    # Config has permissions - check if it matches defaults
    local default_normalized=$(normalize_json "$temp_default")
    local existing_normalized=$(normalize_json "$config_file")
    
    if [[ "$default_normalized" != "$existing_normalized" ]]; then
      # Configs are different
      warn "Existing config differs from recommended defaults"
      printf '\n'
      info "Your config has custom settings or outdated permissions"
      printf '\n'
      read -p "   Replace with latest recommended config? (y/N) " -n 1 -r </dev/tty
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Backup old config
        cp "$config_file" "$config_file.backup"
        info "Backed up old config to opencode.json.backup"
        cat "$temp_default" > "$config_file"
        ok "Updated to latest safety permissions"
      else
        ok "Keeping existing config"
        info "Compare with opencode/opencode.json.example to see latest defaults"
      fi
    else
      # Configs match
      ok "Safety permissions up to date"
    fi
  fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# VERIFY
# ═══════════════════════════════════════════════════════════════════════════════

verify() {
  printf '\n'
  printf '%bSetup Status%b\n' "$BOLD" "$NC"
  printf '\n'
  
  command -v opencode &>/dev/null && ok "OpenCode installed" || warn "OpenCode not installed"
  [[ -f "$CONFIG_DIR/opencode.json" ]] && ok "Config exists" || warn "No config"
  [[ -f "$SECRETS_FILE" ]] && ok "Secrets file exists" || info "No secrets file"
  
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

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
  show_intro
  
  [[ "$VERIFY_ONLY" == true ]] && { verify; exit 0; }
  
  # Get username for personalization
  local username
  username=$(git config user.name 2>/dev/null | cut -d' ' -f1) || username=$(whoami)
  
  # Trucky greeting
  local greeting=$(random_from "${GREETINGS[@]}")
  trucky_say "$TRUCKY_EYES_EXCITED" "$greeting Hey $username!"
  
  # Step 1: OpenCode
  printf '%b1. OpenCode%b\n' "$BOLD" "$NC"
  printf '\n'
  if ! command -v opencode &>/dev/null; then
    warn "OpenCode not installed"
    printf '\n'
    read -p "   Install OpenCode now? (Y/n) " -n 1 -r </dev/tty
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
      trucky "$TRUCKY_EYES_THINKING" "Installing OpenCode..." "*starts engine*"
      curl -fsSL https://opencode.ai/install | bash
      export PATH="$HOME/.local/bin:$PATH"
      ok "OpenCode installed!"
    fi
  else
    ok "OpenCode installed"
  fi
  
  # Step 2: Repository
  if [[ -z "$REPO_ROOT" ]]; then
    printf '\n'
    printf '%b2. Repository%b\n' "$BOLD" "$NC"
    printf '\n'
    
    local existing=$(find_existing_repo)
    if [[ -n "$existing" ]]; then
      ok "Found existing installation: $existing"
      printf '\n'
      read -p "   Use this location? (Y/n) " -n 1 -r </dev/tty
      echo
      if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        REPO_ROOT="$existing"
        trucky "$TRUCKY_EYES_HAPPY" "Great, I know this place!" "*checks mirrors*"
        git -C "$REPO_ROOT" pull --quiet 2>/dev/null || true
        ok "Repository updated"
      fi
    fi
    
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
        printf '   Enter the path to your ai-knowledgebase folder:\n'
        printf '\n'
        read -p "   Path: " repo_path </dev/tty
        repo_path="${repo_path/#\~/$HOME}"
        
        printf '\n'
        if [[ -d "$repo_path" ]] && detect_repo "$repo_path"; then
          REPO_ROOT="$repo_path"
          trucky "$TRUCKY_EYES_HAPPY" "Found it!" "$(random_from "${WORKING_MSGS[@]}")"
          git -C "$REPO_ROOT" pull --quiet 2>/dev/null || true
          ok "Repository ready"
        else
          trucky "$TRUCKY_EYES_WORRIED" "Hmm, that doesn't look right..." "$(random_from "${ERROR_MSGS[@]}")"
          err "Not a valid ai-knowledgebase folder: $repo_path"
          printf '   Expected to find skills/, commands/, and AGENTS.md\n'
          exit 1
        fi
      else
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
          trucky "$TRUCKY_EYES_WINK" "Oh, it's already here! Let me update it..." "*backs up carefully*"
          git -C "$REPO_ROOT" pull --quiet 2>/dev/null || true
        else
          trucky "$TRUCKY_EYES_EXCITED" "Fresh delivery coming up!" "$(random_from "${WORKING_MSGS[@]}")"
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
  
  # Step 3: Symlinks
  printf '\n'
  printf '%b3. Linking to OpenCode%b\n' "$BOLD" "$NC"
  printf '\n'
  
  trucky "$TRUCKY_EYES_THINKING" "Connecting the packages..." "$(random_from "${WORKING_MSGS[@]}")"
  
  mkdir -p "$CONFIG_DIR"
  setup_link "skills" "$REPO_ROOT/skills"
  setup_link "commands" "$REPO_ROOT/commands"
  setup_link "agents" "$REPO_ROOT/agents"
  
  # Step 4: Safety Permissions
  printf '\n'
  printf '%b4. Safety Permissions%b\n' "$BOLD" "$NC"
  printf '\n'
  setup_permissions
  
  # Step 5: Secrets
  printf '\n'
  read -p "   Configure MCP server secrets? (y/N) " -n 1 -r </dev/tty
  echo
  [[ $REPLY =~ ^[Yy]$ ]] && setup_secrets
  
  # Step 6: Optional dependencies
  if [[ "$SKIP_DEPS" == false ]] && command -v npm &>/dev/null; then
    printf '\n'
    printf '%b6. Optional: Playwright%b\n' "$BOLD" "$NC"
    printf '\n'
    if command -v playwright &>/dev/null; then
      ok "Playwright already installed"
    else
      read -p "   Install Playwright for browser-debug skill? (y/N) " -n 1 -r </dev/tty
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        trucky "$TRUCKY_EYES_THINKING" "Installing Playwright..." "*opens cargo door*"
        npm install -g playwright 2>/dev/null && npx playwright install chromium 2>/dev/null && ok "Playwright installed" || warn "Playwright install failed (optional)"
      fi
    fi
  fi
  
  # Done!
  printf '\n'
  local success_msg=$(random_from "${SUCCESS_MSGS[@]}")
  trucky_say "$TRUCKY_EYES_HAPPY" "Delivery complete! $success_msg" "*parks truck*"
  
  printf '%b┌─────────────────────────────────────────────────────┐%b\n' "$GREEN" "$NC"
  printf '%b│              Setup Complete!                        │%b\n' "$GREEN" "$NC"
  printf '%b└─────────────────────────────────────────────────────┘%b\n' "$GREEN" "$NC"
  
  verify
  
  printf '\n'
  printf '  %bReady!%b Run %bopencode%b in any project folder.\n' "$GREEN" "$NC" "$BOLD" "$NC"
  printf '\n'
  printf '  %bPopular skills to try:%b\n' "$BOLD" "$NC"
  printf '    • %btechnical-architect%b - Architecture planning\n' "$CYAN" "$NC"
  printf '    • %bvue-component%b       - Vue 3 patterns\n' "$CYAN" "$NC"
  printf '    • %bdeep-research%b       - Multi-phase research\n' "$CYAN" "$NC"
  printf '    • %bpr-review%b           - Code review workflow\n' "$CYAN" "$NC"
  printf '\n'
  printf '  To update later:\n'
  printf '    cd %s && git pull\n' "$REPO_ROOT"
  printf '\n'
  
  trucky "$TRUCKY_EYES_WINK" "See you next time! *beep beep*"
}

main "$@"
