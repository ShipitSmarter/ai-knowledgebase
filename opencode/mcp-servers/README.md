# MCP Server Configurations

Pre-configured MCP (Model Context Protocol) servers for use with OpenCode and other AI coding agents.

## Available Configurations

| Server | Description | Status |
|--------|-------------|--------|
| [Figma](./figma.md) | Access Figma designs and layout information | Ready |
| [Penpot](./penpot.md) | Open-source design platform integration | Ready |
| [MongoDB](./mongodb.md) | MongoDB database operations and Atlas management | Ready |
| [Notion](./notion.md) | Search and access Notion knowledge base | Ready |

## How to Add MCP Servers in OpenCode

OpenCode supports two types of MCP servers: **local** (stdio) and **remote** (HTTP).

### Configuration File Location

MCP servers are configured in `opencode.json` (not `.opencode/config.json`):

- **Project-level**: `<project-root>/opencode.json`
- **Global**: `~/.config/opencode/opencode.json`

### Using the CLI (Recommended)

```bash
# Add a server interactively
opencode mcp add

# List configured servers
opencode mcp list

# Authenticate with OAuth-enabled servers
opencode mcp auth <server-name>
```

### Configuration Format

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "server-name": {
      "type": "local",
      "command": ["npx", "-y", "package-name"],
      "environment": {
        "API_KEY": "{env:API_KEY}"
      },
      "enabled": true
    }
  }
}
```

### Local Servers (stdio)

For MCP servers that run as local processes:

```json
{
  "mcp": {
    "notion": {
      "type": "local",
      "command": ["npx", "-y", "@notionhq/notion-mcp-server"],
      "environment": {
        "NOTION_TOKEN": "{env:NOTION_TOKEN}"
      }
    }
  }
}
```

**Options:**
| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `type` | string | Yes | Must be `"local"` |
| `command` | array | Yes | Command and arguments to run |
| `environment` | object | No | Environment variables (use `{env:VAR}` syntax) |
| `enabled` | boolean | No | Enable/disable the server |
| `timeout` | number | No | Timeout in ms (default: 5000) |

### Remote Servers (HTTP)

For MCP servers that expose HTTP endpoints:

```json
{
  "mcp": {
    "penpot": {
      "type": "remote",
      "url": "http://localhost:4401/mcp",
      "enabled": true
    }
  }
}
```

**Options:**
| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `type` | string | Yes | Must be `"remote"` |
| `url` | string | Yes | URL of the MCP server |
| `headers` | object | No | HTTP headers to send |
| `oauth` | object/false | No | OAuth configuration |
| `enabled` | boolean | No | Enable/disable the server |

### OAuth-Enabled Servers

For servers requiring OAuth authentication:

```json
{
  "mcp": {
    "sentry": {
      "type": "remote",
      "url": "https://mcp.sentry.dev/mcp",
      "oauth": {}
    }
  }
}
```

Then authenticate:

```bash
opencode mcp auth sentry
```

## Environment Variables

Store sensitive credentials in your shell config (`~/.bashrc` or `~/.zshrc`):

```bash
# Notion
export NOTION_TOKEN="your-notion-token"

# Figma
export FIGMA_API_KEY="your-figma-api-key"

# MongoDB
export MDB_MCP_CONNECTION_STRING="mongodb+srv://..."
export MDB_MCP_API_CLIENT_ID="your-atlas-client-id"
export MDB_MCP_API_CLIENT_SECRET="your-atlas-client-secret"
```

Reference them in config with `{env:VAR_NAME}` syntax.

## Verifying Setup

```bash
# Check if servers are configured and connected
opencode mcp list

# Expected output shows connected servers:
# ┌  MCP Servers
# │
# ●  ✓ penpot connected
# │      http://localhost:4401/mcp
# │
# └  1 server(s)
```

## Common Issues

### "No MCP servers configured"
- Ensure `opencode.json` exists in project root or global config
- Use `"mcp"` key, not `"mcpServers"`
- Restart OpenCode after adding config

### Server shows as disconnected
- For local servers: check command is correct and package is installed
- For remote servers: ensure the server is running and URL is accessible

### Tools not appearing
- Restart OpenCode after server connects
- Check `opencode mcp list` shows the server as connected

## Security Notes

- Never commit API keys or tokens to version control
- Use `{env:VAR}` syntax for all sensitive data
- Consider using `--readOnly` flags where available
- Review MCP server permissions before enabling

## Resources

- [OpenCode MCP Docs](https://opencode.ai/docs/mcp-servers/)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
