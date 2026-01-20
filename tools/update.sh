#!/bin/bash
#
# update.sh - Update ShipitSmarter AI Knowledgebase and relink any new skills/commands
#
# Usage:
#   ~/.shipitsmarter/ai-knowledgebase/tools/update.sh
#   # Or if you have it locally:
#   ./tools/update.sh
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

INSTALL_DIR="${HOME}/.shipitsmarter/ai-knowledgebase"
OPENCODE_CONFIG_HOME="${HOME}/.config/opencode"

if [ ! -d "$INSTALL_DIR" ]; then
  echo "Error: ai-knowledgebase not found at $INSTALL_DIR"
  echo "Run the setup script first:"
  echo "  curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash"
  exit 1
fi

echo -e "${BLUE}Updating ShipitSmarter AI Knowledgebase...${NC}"
git -C "$INSTALL_DIR" pull

# Relink any new skills
echo ""
echo "Checking for new skills..."
NEW_SKILLS=0
for skill_dir in "$INSTALL_DIR/.opencode/skill"/*/; do
  if [[ -d "$skill_dir" && -f "${skill_dir}SKILL.md" ]]; then
    skill_name=$(basename "$skill_dir")
    link_path="$OPENCODE_CONFIG_HOME/skills/${skill_name}"
    
    if [[ ! -e "$link_path" ]]; then
      ln -sf "$skill_dir" "$link_path"
      echo "  + $skill_name"
      NEW_SKILLS=$((NEW_SKILLS + 1))
    fi
  fi
done

if [[ $NEW_SKILLS -eq 0 ]]; then
  echo "  No new skills"
fi

# Relink any new commands
echo ""
echo "Checking for new commands..."
NEW_COMMANDS=0
for cmd_file in "$INSTALL_DIR/.opencode/command"/*.md; do
  if [[ -f "$cmd_file" ]]; then
    cmd_name=$(basename "$cmd_file")
    link_path="$OPENCODE_CONFIG_HOME/commands/${cmd_name}"
    
    if [[ ! -e "$link_path" ]]; then
      ln -sf "$cmd_file" "$link_path"
      echo "  + ${cmd_name%.md}"
      NEW_COMMANDS=$((NEW_COMMANDS + 1))
    fi
  fi
done

if [[ $NEW_COMMANDS -eq 0 ]]; then
  echo "  No new commands"
fi

echo ""
echo -e "${GREEN}Update complete!${NC}"
echo ""

# Show summary
SKILL_COUNT=$(find "$OPENCODE_CONFIG_HOME/skills" -maxdepth 1 -type l 2>/dev/null | wc -l)
COMMAND_COUNT=$(find "$OPENCODE_CONFIG_HOME/commands" -maxdepth 1 -type l -name "*.md" 2>/dev/null | wc -l)
echo "Available: $SKILL_COUNT skills, $COMMAND_COUNT commands"
