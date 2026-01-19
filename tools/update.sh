#!/bin/bash
set -e

INSTALL_DIR="${HOME}/.shipitsmarter/ai-knowledgebase"

if [ ! -d "$INSTALL_DIR" ]; then
  echo "Error: ai-knowledgebase not found at $INSTALL_DIR"
  echo "Run the setup script first: tools/setup.sh"
  exit 1
fi

echo "Updating ShipitSmarter AI Knowledgebase..."
git -C "$INSTALL_DIR" pull

echo ""
echo "Skills updated!"
echo ""
echo "Available skills:"
ls -1 "$INSTALL_DIR/skills" | grep -v "^viya-app$" | sed 's/^/  - /'
