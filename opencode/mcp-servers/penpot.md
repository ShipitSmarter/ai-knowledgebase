# Penpot MCP Server

Access Penpot designs from AI coding agents. Penpot is an open-source design platform alternative to Figma.

## Architecture

The Penpot MCP server uses a unique architecture:

1. **MCP Server** - Exposes tools to AI clients via HTTP/SSE
2. **Penpot Plugin** - Runs inside Penpot, connects to MCP server via WebSocket
3. **AI Client** - Connects to MCP server (via `mcp-remote` proxy for stdio clients)

```
+----------------+     +------------------+     +------------------+
|   OpenCode     |<--->|   MCP Server     |<--->|  Penpot Plugin   |
|  (mcp-remote)  |     |   (port 4401)    |     |   (WebSocket)    |
+----------------+     +------------------+     +------------------+
                                                        |
                                                        v
                                                +------------------+
                                                |     Penpot       |
                                                |    (browser)     |
                                                +------------------+
```

## Installation

### 1. Clone the Official Server

```bash
mkdir -p ~/.local/share
git clone https://github.com/penpot/penpot-mcp.git ~/.local/share/penpot-mcp
cd ~/.local/share/penpot-mcp
npm install
npm run bootstrap
```

### 2. Configure OpenCode

Add to `.opencode/config.json`:

```jsonc
{
  "mcpServers": {
    "penpot": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "http://localhost:4401/sse", "--allow-http"],
      "env": {}
    }
  }
}
```

## Usage

### Starting the Servers

```bash
cd ~/.local/share/penpot-mcp && npm run start:all
```

This starts:
- **Port 4400**: Plugin web server
- **Port 4401**: MCP HTTP/SSE endpoint
- **Port 4402**: WebSocket server
- **Port 4403**: REPL server

### Connecting the Plugin

1. Open [design.penpot.app](https://design.penpot.app)
2. Open a design file
3. Click **Plugins menu** (puzzle icon)
4. Enter: `http://localhost:4400/manifest.json`
5. Open the installed plugin
6. Click **"Connect to MCP server"**

### Using with OpenCode

Use the `/designer` command to start an interactive design session.

## Available Tools

| Tool | Description |
|------|-------------|
| `execute_code` | Execute code using the Penpot Plugin API |
| `high_level_overview` | Get overview of current design file |
| `penpot_api_info` | Get info about available Penpot API methods |
| `export_shape` | Export a shape as image |
| `import_image` | Import an image into the design |

## Example Workflows

### Get Design Structure
```
Use high_level_overview to see frames, components, and layers
```

### Query Elements
```
Use execute_code with:
- penpot.getPage().children - Get all page elements
- penpot.selection - Get selected elements
- penpot.library.local.colors - Get color palette
```

### Generate Code from Design
```
1. Get design overview
2. Export specific components
3. Generate HTML/CSS based on design data
```

## Stopping the Servers

```bash
pkill -f "penpot-mcp"
```

## Browser Notes

### Chromium 142+ (Chrome, Brave, Edge)
Private network access restrictions require allowing localhost connections. 
- Accept the popup when prompted
- In Brave: disable "Shield" for design.penpot.app

### Firefox
Works without additional configuration.

## Troubleshooting

### Plugin won't connect
- Check browser console for WebSocket errors
- Verify servers are running: `ss -tlnp | grep 440`
- Try Firefox if Chromium has issues

### Servers not starting
```bash
# Check logs
tail -50 /tmp/penpot-mcp.log

# Restart
pkill -f penpot-mcp
cd ~/.local/share/penpot-mcp && npm run start:all
```

### MCP tools not available in OpenCode
- Restart OpenCode after servers are running
- Verify plugin shows "Connected to MCP server"

## Why Penpot?

- **Open Source**: No vendor lock-in
- **Self-Hostable**: Full data control
- **Free**: No per-seat pricing
- **Standards-Based**: SVG-native
- **Figma Import**: Can import Figma files

## Resources

- [Penpot MCP GitHub](https://github.com/penpot/penpot-mcp)
- [Penpot Plugin API](https://help.penpot.app/plugins/)
- [Penpot Help](https://help.penpot.app/)
- [Penpot GitHub](https://github.com/penpot/penpot)
