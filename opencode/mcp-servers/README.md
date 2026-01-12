# MCP Server Configurations

Pre-configured MCP (Model Context Protocol) servers for use with OpenCode and other AI coding agents.

## Available Configurations

| Server | Description | Status |
|--------|-------------|--------|
| [Figma](./figma.md) | Access Figma designs and layout information | Ready |
| [Penpot](./penpot.md) | Open-source design platform integration | Ready |
| [MongoDB](./mongodb.md) | MongoDB database operations and Atlas management | Ready |

## Installation

MCP servers can be configured in your OpenCode config file (`~/.config/opencode/config.json`) or project-level `.opencode/config.json`.

### Global Configuration

```jsonc
// ~/.config/opencode/config.json
{
  "mcpServers": {
    // Add servers from individual config files
  }
}
```

### Project-Level Configuration

```jsonc
// .opencode/config.json
{
  "mcpServers": {
    // Project-specific servers
  }
}
```

## Quick Start

1. Choose the MCP servers you need from the list above
2. Copy the configuration from the individual server docs
3. Add required API keys to your environment
4. Restart OpenCode

## Environment Variables

Store sensitive credentials in your shell config:

```bash
# ~/.bashrc or ~/.zshrc

# Figma
export FIGMA_API_KEY="your-figma-api-key"

# Penpot
export PENPOT_ACCESS_TOKEN="your-penpot-token"
export PENPOT_BASE_URL="https://design.penpot.app"  # or self-hosted URL

# MongoDB
export MDB_MCP_CONNECTION_STRING="mongodb+srv://..."
export MDB_MCP_API_CLIENT_ID="your-atlas-client-id"
export MDB_MCP_API_CLIENT_SECRET="your-atlas-client-secret"
```

## Security Notes

- Never commit API keys or tokens to version control
- Use environment variables for all sensitive data
- Consider using `--readOnly` flags where available
- Review MCP server permissions before enabling
