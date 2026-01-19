#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

INSTALL_DIR="${HOME}/.shipitsmarter/ai-knowledgebase"
REPO_URL="https://github.com/ShipitSmarter/ai-knowledgebase"
OPENCODE_PLUGINS_DIR="${HOME}/.opencode/plugins"

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

# Step 3: Configure shell environment
print_header "Shell Configuration"

SHELL_RC=$(detect_shell_config)
NEEDS_SOURCE=false

if ! grep -q "OPENCODE_CONFIG_DIR" "$SHELL_RC" 2>/dev/null; then
  echo "" >> "$SHELL_RC"
  echo "# ShipitSmarter AI Knowledgebase (added by setup.sh)" >> "$SHELL_RC"
  echo "export OPENCODE_CONFIG_DIR=\"\$HOME/.shipitsmarter/ai-knowledgebase\"" >> "$SHELL_RC"
  echo "export OPENCODE_CONFIG=\"\$HOME/.shipitsmarter/ai-knowledgebase/shared-config.json\"" >> "$SHELL_RC"
  print_success "Added environment variables to $SHELL_RC"
  NEEDS_SOURCE=true
else
  print_success "Environment variables already configured"
fi

# Export for current session
export OPENCODE_CONFIG_DIR="$INSTALL_DIR"
export OPENCODE_CONFIG="$INSTALL_DIR/shared-config.json"

# Step 4: Install opencode-mem plugin (if not installed)
print_header "Plugins"

OPENCODE_CONFIG_HOME="${HOME}/.config/opencode"
if [ ! -f "$OPENCODE_CONFIG_HOME/opencode.json" ]; then
  mkdir -p "$OPENCODE_CONFIG_HOME"
  echo '{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["opencode-mem"]
}' > "$OPENCODE_CONFIG_HOME/opencode.json"
  print_success "Created global config with opencode-mem plugin"
elif ! grep -q "opencode-mem" "$OPENCODE_CONFIG_HOME/opencode.json" 2>/dev/null; then
  print_warning "opencode-mem plugin not in global config"
  echo "  Add to $OPENCODE_CONFIG_HOME/opencode.json:"
  echo '  "plugin": ["opencode-mem"]'
else
  print_success "opencode-mem plugin configured"
fi

# Step 5: Check for google-ai-search plugin (optional)
if [ -d "$OPENCODE_PLUGINS_DIR/opencode-google-ai-search" ]; then
  print_success "google-ai-search plugin installed"
else
  print_warning "google-ai-search plugin not installed (optional)"
  echo "  To install: See https://github.com/anthropics/opencode-google-ai-search"
fi

# Step 6: Summary
print_header "Setup Complete"

echo "Skills available ($(ls -1 "$INSTALL_DIR/skills" | wc -l) total):"
ls -1 "$INSTALL_DIR/skills" | head -10 | sed 's/^/  - /'
if [ $(ls -1 "$INSTALL_DIR/skills" | wc -l) -gt 10 ]; then
  echo "  ... and $(( $(ls -1 "$INSTALL_DIR/skills" | wc -l) - 10 )) more"
fi

echo ""
echo "Commands available:"
ls -1 "$INSTALL_DIR/commands" | sed 's/.md$//' | sed 's/^/  \//g'

echo ""
echo "MCP Servers (enable in project opencode.json):"
echo "  - notion (requires NOTION_TOKEN)"
echo "  - google-ai-search (requires plugin)"
echo "  - posthog (requires POSTHOG_API_KEY)"

if [ "$NEEDS_SOURCE" = true ]; then
  echo ""
  echo -e "${YELLOW}Action required:${NC} Restart your terminal or run:"
  echo "  source $SHELL_RC"
fi

echo ""
echo "To update later:"
echo "  git -C ~/.shipitsmarter/ai-knowledgebase pull"
echo ""
