#!/bin/bash
set -e

INSTALL_DIR="${HOME}/.shipitsmarter/ai-knowledgebase"
REPO_URL="https://github.com/ShipitSmarter/ai-knowledgebase"

echo "=== ShipitSmarter AI Knowledgebase Setup ==="
echo ""

# Clone or update repo
if [ -d "$INSTALL_DIR" ]; then
  echo "Updating existing installation..."
  git -C "$INSTALL_DIR" pull
else
  echo "Cloning ai-knowledgebase..."
  mkdir -p "${HOME}/.shipitsmarter"
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Detect shell config file
if [ -f "${HOME}/.zshrc" ]; then
  SHELL_RC="${HOME}/.zshrc"
else
  SHELL_RC="${HOME}/.bashrc"
fi

# Add environment variables if not present
if ! grep -q "OPENCODE_CONFIG_DIR" "$SHELL_RC" 2>/dev/null; then
  echo "" >> "$SHELL_RC"
  echo "# ShipitSmarter AI Knowledgebase" >> "$SHELL_RC"
  echo "export OPENCODE_CONFIG_DIR=\"\$HOME/.shipitsmarter/ai-knowledgebase\"" >> "$SHELL_RC"
  echo "export OPENCODE_CONFIG=\"\$HOME/.shipitsmarter/ai-knowledgebase/shared-config.json\"" >> "$SHELL_RC"
  echo "Added environment variables to $SHELL_RC"
else
  echo "Environment variables already configured in $SHELL_RC"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Restart your terminal or run:"
echo "  source $SHELL_RC"
echo ""
echo "Available skills:"
ls -1 "$INSTALL_DIR/skills" | grep -v "^viya-app$" | sed 's/^/  - /'
echo ""
echo "To update later, run:"
echo "  git -C ~/.shipitsmarter/ai-knowledgebase pull"
