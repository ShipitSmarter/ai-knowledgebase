#!/bin/bash
#
# setup-ai-attribution.sh - Set up AI commit attribution for git
#
# This script installs:
# - Global git hooks that add AI trailers to commit messages
# - Shell functions for session management (ai-session-start, ai-session-end, ai-session-status)
# - Enables the OpenCode plugin for automatic tracking (if plugins are linked)
#
# Usage:
#   ./tools/setup-ai-attribution.sh           # Interactive setup
#   ./tools/setup-ai-attribution.sh --force   # Non-interactive, install everything
#   ./tools/setup-ai-attribution.sh --remove  # Remove AI attribution setup (disables plugin)
#
# Can be run standalone or called from setup.sh
#

set -e

# Colors (using printf-compatible format)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Output helpers
ok() { printf '  %b✓%b %s\n' "$GREEN" "$NC" "$1"; }
warn() { printf '  %b!%b %s\n' "$YELLOW" "$NC" "$1"; }
info() { printf '  %b→%b %s\n' "$BLUE" "$NC" "$1"; }
error() { printf '  %b✗%b %s\n' "$RED" "$NC" "$1"; }

# Configuration
CONFIG_DIR="${HOME}/.config/opencode"
HOOKS_DIR="$CONFIG_DIR/git-hooks"
PLUGINS_DIR="$CONFIG_DIR/plugins"
PLUGIN_FILE="ai-attribution.ts"
PLUGIN_DISABLED="ai-attribution.ts.disabled"

# Parse arguments
FORCE=false
REMOVE=false
for arg in "$@"; do
  case $arg in
    --force) FORCE=true ;;
    --remove) REMOVE=true ;;
  esac
done

# Detect shell configuration file
detect_shell_config() {
  if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == *"zsh"* ]]; then
    echo "$HOME/.zshrc"
  else
    echo "$HOME/.bashrc"
  fi
}

# Create the prepare-commit-msg hook
create_prepare_commit_msg_hook() {
  cat > "$HOOKS_DIR/prepare-commit-msg" << 'HOOK_EOF'
#!/bin/bash
#
# prepare-commit-msg hook for AI attribution
# Adds trailers based on AI_* environment variables
#

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# Skip if this is a merge, squash, or amend
if [ "$COMMIT_SOURCE" = "merge" ] || [ "$COMMIT_SOURCE" = "squash" ]; then
    exit 0
fi

# Only proceed if AI_ASSISTED is set
if [ -z "$AI_ASSISTED" ] || [ "$AI_ASSISTED" != "1" ]; then
    exit 0
fi

# Check if trailers already exist (avoid duplicates on amend)
if grep -q "^AI-assisted-by:" "$COMMIT_MSG_FILE"; then
    exit 0
fi

# Build the trailer block
TRAILERS=""

# AI Model/Tool attribution
if [ -n "$AI_MODEL" ]; then
    if [ -n "$AI_TOOL" ]; then
        TRAILERS="${TRAILERS}AI-assisted-by: ${AI_MODEL} via ${AI_TOOL}\n"
    else
        TRAILERS="${TRAILERS}AI-assisted-by: ${AI_MODEL}\n"
    fi
elif [ -n "$AI_TOOL" ]; then
    TRAILERS="${TRAILERS}AI-assisted-by: ${AI_TOOL}\n"
else
    TRAILERS="${TRAILERS}AI-assisted-by: AI assistant\n"
fi

# Contribution level
if [ -n "$AI_CONTRIBUTION" ]; then
    TRAILERS="${TRAILERS}AI-contribution: ${AI_CONTRIBUTION}\n"
fi

# Calculate percentage if line counts available
if [ -n "$AI_LINES_ADDED" ] && [ -n "$AI_LINES_TOTAL" ] && [ "$AI_LINES_TOTAL" -gt 0 ]; then
    PERCENTAGE=$((AI_LINES_ADDED * 100 / AI_LINES_TOTAL))
    TRAILERS="${TRAILERS}AI-percentage: ${PERCENTAGE}%\n"
fi

# Session ID (useful for auditing)
if [ -n "$AI_SESSION_ID" ]; then
    TRAILERS="${TRAILERS}AI-session: ${AI_SESSION_ID}\n"
fi

# Append trailers to commit message
echo "" >> "$COMMIT_MSG_FILE"
printf '%b' "$TRAILERS" >> "$COMMIT_MSG_FILE"
HOOK_EOF
}

# Create the post-commit hook
create_post_commit_hook() {
  cat > "$HOOKS_DIR/post-commit" << 'HOOK_EOF'
#!/bin/bash
#
# post-commit hook for AI attribution
# Adds detailed git notes with session and commit metadata
#

# Only proceed if AI was involved
if [ -z "$AI_ASSISTED" ] || [ "$AI_ASSISTED" != "1" ]; then
    exit 0
fi

# Get the commit hash
COMMIT_HASH=$(git rev-parse HEAD)

# Build detailed note
NOTE="AI Attribution Details
=====================
Model: ${AI_MODEL:-unknown}
Tool: ${AI_TOOL:-unknown}
Contribution: ${AI_CONTRIBUTION:-unknown}
Session ID: ${AI_SESSION_ID:-none}
Commit Time: $(date -Iseconds)"

if [ -n "$AI_LINES_ADDED" ]; then
    NOTE="${NOTE}
Lines Added by AI: ${AI_LINES_ADDED}"
fi
if [ -n "$AI_LINES_TOTAL" ]; then
    NOTE="${NOTE}
Total Lines Changed: ${AI_LINES_TOTAL}"
fi
if [ -n "$AI_LINES_ADDED" ] && [ -n "$AI_LINES_TOTAL" ] && [ "$AI_LINES_TOTAL" -gt 0 ]; then
    PERCENTAGE=$((AI_LINES_ADDED * 100 / AI_LINES_TOTAL))
    NOTE="${NOTE}
AI Contribution: ${PERCENTAGE}%"
fi
if [ -n "$AI_FILES_TOUCHED" ]; then
    NOTE="${NOTE}

Files Modified by AI:
${AI_FILES_TOUCHED}"
fi

# Create the note
echo "$NOTE" | git notes add -f -F - "$COMMIT_HASH" 2>/dev/null || true

echo "AI attribution added to commit ${COMMIT_HASH:0:7}"
HOOK_EOF
}

# Get the shell integration code
get_shell_integration() {
  cat << 'SHELL_EOF'

# AI Commit Attribution - Auto-cleanup
# Session vars persist until ai-session-end; per-commit vars cleared after each commit
# Installed by: ai-knowledgebase setup.sh

_ai_commit_var_cleanup() {
    unset AI_LINES_ADDED AI_LINES_TOTAL AI_FILES_TOUCHED AI_CONTEXT
}

_ai_session_cleanup() {
    unset AI_ASSISTED AI_MODEL AI_TOOL AI_CONTRIBUTION AI_SESSION_ID
    unset AI_LINES_ADDED AI_LINES_TOTAL AI_FILES_TOUCHED AI_CONTEXT
}

git() {
    command git "$@"
    local exit_code=$?
    if [ "$1" = "commit" ] && [ $exit_code -eq 0 ] && [ -n "$AI_ASSISTED" ]; then
        _ai_commit_var_cleanup
        echo "AI commit recorded (session $AI_SESSION_ID still active)"
    fi
    return $exit_code
}

ai-session-start() {
    export AI_ASSISTED=1
    export AI_MODEL="${1:-unknown}"
    export AI_TOOL="${2:-cli}"
    export AI_CONTRIBUTION="${3:-partial}"
    export AI_SESSION_ID="${4:-$(date +%Y%m%d-%H%M%S)-$$}"
    echo "AI session started:"
    echo "  Model: $AI_MODEL"
    echo "  Tool: $AI_TOOL"
    echo "  Session ID: $AI_SESSION_ID"
    echo ""
    echo "All commits attributed to this session until: ai-session-end"
}

ai-session-end() {
    [ -n "$AI_SESSION_ID" ] && echo "AI session ended: $AI_SESSION_ID"
    _ai_session_cleanup
    echo "Next commit will be human-attributed"
}

ai-session-status() {
    if [ -n "$AI_ASSISTED" ]; then
        echo "AI Session Active:"
        echo "  Model: ${AI_MODEL:-not set}"
        echo "  Tool: ${AI_TOOL:-not set}"
        echo "  Contribution: ${AI_CONTRIBUTION:-not set}"
        echo "  Session ID: ${AI_SESSION_ID:-not set}"
    else
        echo "No AI session active (commits will be human-attributed)"
        echo "Start with: ai-session-start <model> <tool>"
    fi
}
SHELL_EOF
}

# Install git hooks
install_hooks() {
  mkdir -p "$HOOKS_DIR"
  
  create_prepare_commit_msg_hook
  create_post_commit_hook
  
  chmod +x "$HOOKS_DIR/prepare-commit-msg"
  chmod +x "$HOOKS_DIR/post-commit"
  
  # Configure global git hooks path
  git config --global core.hooksPath "$HOOKS_DIR"
  ok "Git hooks installed to $HOOKS_DIR"
}

# Enable the OpenCode plugin (rename from .disabled if needed)
enable_plugin() {
  if [[ -d "$PLUGINS_DIR" ]]; then
    # Check if plugin exists but is disabled
    if [[ -f "$PLUGINS_DIR/$PLUGIN_DISABLED" ]]; then
      mv "$PLUGINS_DIR/$PLUGIN_DISABLED" "$PLUGINS_DIR/$PLUGIN_FILE"
      ok "OpenCode plugin enabled"
    elif [[ -f "$PLUGINS_DIR/$PLUGIN_FILE" ]]; then
      ok "OpenCode plugin already enabled"
    else
      info "OpenCode plugin not found (manual sessions only)"
    fi
  else
    info "Plugins directory not linked (manual sessions only)"
  fi
}

# Disable the OpenCode plugin (rename to .disabled)
disable_plugin() {
  if [[ -d "$PLUGINS_DIR" ]]; then
    if [[ -f "$PLUGINS_DIR/$PLUGIN_FILE" ]]; then
      mv "$PLUGINS_DIR/$PLUGIN_FILE" "$PLUGINS_DIR/$PLUGIN_DISABLED"
      ok "OpenCode plugin disabled"
      info "Rename back to $PLUGIN_FILE to re-enable"
    elif [[ -f "$PLUGINS_DIR/$PLUGIN_DISABLED" ]]; then
      ok "OpenCode plugin already disabled"
    else
      info "OpenCode plugin not found (nothing to disable)"
    fi
  else
    info "Plugins directory not linked (nothing to disable)"
  fi
}

# Install shell integration
install_shell_integration() {
  local shell_config="$1"
  
  # Check if shell integration already exists
  if grep -q "# AI Commit Attribution" "$shell_config" 2>/dev/null; then
    ok "Shell integration already in $shell_config"
    return 0
  fi
  
  # Backup shell config
  cp "$shell_config" "$shell_config.backup" 2>/dev/null || true
  
  # Add shell integration
  get_shell_integration >> "$shell_config"
  
  ok "Shell functions added to $shell_config"
  info "Backed up to $shell_config.backup"
}

# Remove AI attribution setup
remove_attribution() {
  local shell_config=$(detect_shell_config)
  
  printf '\n'
  printf '%bRemoving AI Commit Attribution%b\n' "$BOLD" "$NC"
  printf '\n'
  
  # Remove git hooks path config
  local current_hooks=$(git config --global core.hooksPath 2>/dev/null || echo "")
  if [[ "$current_hooks" == "$HOOKS_DIR" ]]; then
    git config --global --unset core.hooksPath
    ok "Removed global git hooks path"
  else
    info "Git hooks path not set to our directory (skipping)"
  fi
  
  # Remove hooks directory
  if [[ -d "$HOOKS_DIR" ]]; then
    rm -rf "$HOOKS_DIR"
    ok "Removed hooks directory: $HOOKS_DIR"
  fi
  
  # Disable the OpenCode plugin
  disable_plugin
  
  # Remove shell integration
  if grep -q "# AI Commit Attribution" "$shell_config" 2>/dev/null; then
    # Create backup
    cp "$shell_config" "$shell_config.backup"
    
    # Remove the AI attribution block (from marker to last function)
    # This is a bit tricky - we'll use sed to remove from the marker to the closing brace of ai-session-status
    local temp_file=$(mktemp)
    awk '
      /^# AI Commit Attribution/ { skip=1 }
      skip && /^ai-session-status\(\)/ { in_func=1 }
      skip && in_func && /^}$/ { skip=0; in_func=0; next }
      !skip { print }
    ' "$shell_config" > "$temp_file"
    mv "$temp_file" "$shell_config"
    
    ok "Removed shell integration from $shell_config"
    info "Backed up to $shell_config.backup"
  else
    info "No shell integration found (skipping)"
  fi
  
  printf '\n'
  ok "AI commit attribution removed"
  info "Restart your shell and OpenCode to complete removal"
}

# Main installation
install_attribution() {
  local shell_config=$(detect_shell_config)
  
  install_hooks
  install_shell_integration "$shell_config"
  enable_plugin
  
  printf '\n'
  ok "AI commit attribution installed!"
  printf '\n'
  printf '   %bUsage:%b\n' "$BOLD" "$NC"
  printf '     ai-session-start claude-opus-4.5 opencode   # Start AI session\n'
  printf '     git commit -m "message"                     # Commits get AI trailers\n'
  printf '     ai-session-end                              # End session\n'
  printf '\n'
  printf '   %bNote:%b Restart your shell or run: source %s\n' "$YELLOW" "$NC" "$shell_config"
}

# Check current status
check_status() {
  local shell_config=$(detect_shell_config)
  local hooks_path=$(git config --global core.hooksPath 2>/dev/null || echo "")
  
  local hooks_installed=false
  local shell_installed=false
  local plugin_enabled=false
  
  if [[ "$hooks_path" == "$HOOKS_DIR" ]] && [[ -f "$HOOKS_DIR/prepare-commit-msg" ]]; then
    hooks_installed=true
  fi
  
  if grep -q "# AI Commit Attribution" "$shell_config" 2>/dev/null; then
    shell_installed=true
  fi
  
  if [[ -f "$PLUGINS_DIR/$PLUGIN_FILE" ]]; then
    plugin_enabled=true
  fi
  
  if $hooks_installed && $shell_installed; then
    echo "installed"
  elif $hooks_installed || $shell_installed || $plugin_enabled; then
    echo "partial"
  else
    echo "not_installed"
  fi
}

# Main
main() {
  if [[ "$REMOVE" == true ]]; then
    remove_attribution
    exit 0
  fi
  
  # Check current status
  local status=$(check_status)
  
  if [[ "$status" == "installed" ]] && [[ "$FORCE" != true ]]; then
    ok "AI commit attribution already installed"
    exit 0
  fi
  
  if [[ "$status" == "partial" ]]; then
    warn "AI commit attribution partially installed"
    if [[ "$FORCE" != true ]]; then
      printf '\n'
      read -p "   Reinstall? (Y/n) " -n 1 -r </dev/tty
      echo
      if [[ $REPLY =~ ^[Nn]$ ]]; then
        exit 0
      fi
    fi
  fi
  
  install_attribution
}

# Run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
