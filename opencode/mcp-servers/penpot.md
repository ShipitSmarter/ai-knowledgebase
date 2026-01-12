# Penpot MCP Server

Access Penpot designs from AI coding agents. Penpot is an open-source design platform alternative to Figma.

## Recommended Servers

### Official Server (Recommended)

**[penpot/penpot-mcp](https://github.com/penpot/penpot-mcp)** (123 stars)
- Official MCP Server from Penpot team
- TypeScript implementation
- Active development

### Community Server (More Stars)

**[montevive/penpot-mcp](https://github.com/montevive/penpot-mcp)** (208 stars)
- Python implementation
- Community maintained
- Feature-rich

## Installation

### Official TypeScript Server

```bash
npm install -g @penpot/penpot-mcp
```

### Community Python Server

```bash
pip install penpot-mcp
```

## Configuration

### OpenCode Config (Official Server)

Add to `~/.config/opencode/config.json` or `.opencode/config.json`:

```jsonc
{
  "mcpServers": {
    "penpot": {
      "command": "npx",
      "args": ["-y", "@penpot/penpot-mcp"],
      "env": {
        "PENPOT_ACCESS_TOKEN": "${PENPOT_ACCESS_TOKEN}",
        "PENPOT_BASE_URL": "${PENPOT_BASE_URL}"
      }
    }
  }
}
```

### OpenCode Config (Community Python Server)

```jsonc
{
  "mcpServers": {
    "penpot": {
      "command": "uvx",
      "args": ["penpot-mcp"],
      "env": {
        "PENPOT_ACCESS_TOKEN": "${PENPOT_ACCESS_TOKEN}",
        "PENPOT_BASE_URL": "${PENPOT_BASE_URL}"
      }
    }
  }
}
```

### Environment Variables

```bash
# Add to ~/.bashrc or ~/.zshrc

# For Penpot Cloud
export PENPOT_ACCESS_TOKEN="your-penpot-access-token"
export PENPOT_BASE_URL="https://design.penpot.app"

# For Self-Hosted Penpot
export PENPOT_ACCESS_TOKEN="your-penpot-access-token"
export PENPOT_BASE_URL="https://your-penpot-instance.com"
```

## Getting a Penpot Access Token

### Penpot Cloud

1. Go to [design.penpot.app](https://design.penpot.app)
2. Log in to your account
3. Go to Profile Settings
4. Navigate to "Access Tokens"
5. Generate a new token
6. Copy and store securely

### Self-Hosted

1. Access your Penpot instance admin panel
2. Navigate to user settings
3. Generate an API access token

## Available Tools

Once configured, you can ask OpenCode to:

- "Get the design from this Penpot project"
- "Extract components from the Penpot file"
- "Show me the color palette from this design"
- "List all frames in the Penpot project"

## Self-Hosted Penpot

Penpot can be self-hosted for teams wanting full control:

```bash
# Docker Compose setup
git clone https://github.com/penpot/penpot.git
cd penpot/docker
docker-compose up -d
```

Then configure MCP with your self-hosted URL:

```bash
export PENPOT_BASE_URL="http://localhost:9001"
```

## Alternative Servers

| Server | Language | Description |
|--------|----------|-------------|
| [zcube/penpot-mcp-server](https://github.com/zcube/penpot-mcp-server) | TypeScript | Docker support, design automation |
| [ajeetraina/penpot-mcp-docker](https://github.com/ajeetraina/penpot-mcp-docker) | Docker | Containerized deployment |

## Use Cases

### Open-Source Design Workflow

1. Create designs in Penpot (free, open-source)
2. Share project with OpenCode via MCP
3. Generate code from designs
4. Iterate without vendor lock-in

### Team Collaboration

1. Self-host Penpot for your team
2. Configure MCP server with team instance
3. All developers can access designs via AI

## Why Penpot?

- **Open Source**: No vendor lock-in
- **Self-Hostable**: Full data control
- **Free**: No per-seat pricing
- **Standards-Based**: SVG-native
- **Figma Import**: Can import Figma files

## Troubleshooting

### "Authentication failed"
- Verify your access token is valid
- Check token hasn't expired
- Ensure base URL is correct (no trailing slash)

### "Connection refused" (Self-Hosted)
- Verify Penpot instance is running
- Check firewall rules
- Ensure the URL is accessible from your machine

### "Project not found"
- Verify you have access to the project
- Check the project ID is correct

## Resources

- [Penpot Official Docs](https://help.penpot.app/)
- [Penpot GitHub](https://github.com/penpot/penpot)
- [Official MCP Server](https://github.com/penpot/penpot-mcp)
- [Community MCP Server](https://github.com/montevive/penpot-mcp)
