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

# Step 3: Create OpenCode config directories
print_header "Setting up OpenCode Configuration"

mkdir -p "$OPENCODE_CONFIG_HOME/skills"
mkdir -p "$OPENCODE_CONFIG_HOME/commands"

# Step 4: Symlink skills to global config
echo "Linking skills..."
SKILLS_LINKED=0
SKILLS_SKIPPED=0

for skill_dir in "$INSTALL_DIR/skills"/*/; do
  if [[ -d "$skill_dir" && -f "${skill_dir}SKILL.md" ]]; then
    skill_name=$(basename "$skill_dir")
    link_path="$OPENCODE_CONFIG_HOME/skills/${skill_name}"
    
    if [[ -L "$link_path" ]]; then
      # Check if symlink points to our repo
      current_target=$(readlink "$link_path")
      if [[ "$current_target" == "$skill_dir"* || "$current_target" == *"ai-knowledgebase"* ]]; then
        SKILLS_SKIPPED=$((SKILLS_SKIPPED + 1))
      else
        print_warning "Skill '$skill_name' exists but points elsewhere: $current_target"
        SKILLS_SKIPPED=$((SKILLS_SKIPPED + 1))
      fi
    elif [[ -e "$link_path" ]]; then
      print_warning "Skill '$skill_name' exists but is not a symlink, skipping"
      SKILLS_SKIPPED=$((SKILLS_SKIPPED + 1))
    else
      ln -sf "$skill_dir" "$link_path"
      SKILLS_LINKED=$((SKILLS_LINKED + 1))
    fi
  fi
done

if [[ $SKILLS_LINKED -gt 0 ]]; then
  print_success "Linked $SKILLS_LINKED new skills"
fi
if [[ $SKILLS_SKIPPED -gt 0 ]]; then
  echo "  ($SKILLS_SKIPPED skills already configured)"
fi

# Step 5: Symlink commands to global config
echo "Linking commands..."
COMMANDS_LINKED=0
COMMANDS_SKIPPED=0

for cmd_file in "$INSTALL_DIR/commands"/*.md; do
  if [[ -f "$cmd_file" ]]; then
    cmd_name=$(basename "$cmd_file")
    link_path="$OPENCODE_CONFIG_HOME/commands/${cmd_name}"
    
    if [[ -L "$link_path" ]]; then
      current_target=$(readlink "$link_path")
      if [[ "$current_target" == *"ai-knowledgebase"* ]]; then
        COMMANDS_SKIPPED=$((COMMANDS_SKIPPED + 1))
      else
        print_warning "Command '$cmd_name' exists but points elsewhere"
        COMMANDS_SKIPPED=$((COMMANDS_SKIPPED + 1))
      fi
    elif [[ -e "$link_path" ]]; then
      print_warning "Command '$cmd_name' exists but is not a symlink, skipping"
      COMMANDS_SKIPPED=$((COMMANDS_SKIPPED + 1))
    else
      ln -sf "$cmd_file" "$link_path"
      COMMANDS_LINKED=$((COMMANDS_LINKED + 1))
    fi
  fi
done

if [[ $COMMANDS_LINKED -gt 0 ]]; then
  print_success "Linked $COMMANDS_LINKED new commands"
fi
if [[ $COMMANDS_SKIPPED -gt 0 ]]; then
  echo "  ($COMMANDS_SKIPPED commands already configured)"
fi

# Step 6: Set up opencode.json with plugins
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

# Step 7: Clean up old environment variables (optional migration)
SHELL_RC=$(detect_shell_config)
if grep -q "OPENCODE_CONFIG_DIR.*ai-knowledgebase" "$SHELL_RC" 2>/dev/null; then
  print_warning "Found old OPENCODE_CONFIG_DIR in $SHELL_RC"
  echo "  The new setup uses symlinks instead. You can remove these lines:"
  echo "    export OPENCODE_CONFIG_DIR=..."
  echo "    export OPENCODE_CONFIG=..."
fi

# Step 8: Summary
print_header "Setup Complete"

SKILL_COUNT=$(find "$OPENCODE_CONFIG_HOME/skills" -maxdepth 1 -type l 2>/dev/null | wc -l)
COMMAND_COUNT=$(find "$OPENCODE_CONFIG_HOME/commands" -maxdepth 1 -type l -name "*.md" 2>/dev/null | wc -l)

echo "Skills available globally ($SKILL_COUNT total):"
find "$OPENCODE_CONFIG_HOME/skills" -maxdepth 1 -type l -exec basename {} \; 2>/dev/null | sort | head -10 | sed 's/^/  - /'
if [[ $SKILL_COUNT -gt 10 ]]; then
  echo "  ... and $(( SKILL_COUNT - 10 )) more"
fi

echo ""
echo "Commands available globally ($COMMAND_COUNT total):"
find "$OPENCODE_CONFIG_HOME/commands" -maxdepth 1 -type l -name "*.md" -exec basename {} .md \; 2>/dev/null | sort | head -10 | sed 's/^/  \//'
if [[ $COMMAND_COUNT -gt 10 ]]; then
  echo "  ... and $(( COMMAND_COUNT - 10 )) more"
fi

echo ""
echo -e "${GREEN}Skills are now available in ANY repository!${NC}"
echo ""
echo "Try it out:"
echo "  cd ~/your-project"
echo "  opencode"
echo "  /research <topic>"
echo ""
echo "To update later:"
echo "  cd ~/.shipitsmarter/ai-knowledgebase && git pull"
echo "  # Or run this script again"
echo ""
