# Penpot MCP Server

Access Penpot designs from AI coding agents. Penpot is an open-source design platform alternative to Figma.

## Architecture

The Penpot MCP server uses a unique architecture:

1. **MCP Server** - Exposes tools to AI clients via HTTP
2. **Penpot Plugin** - Runs inside Penpot, connects to MCP server via WebSocket
3. **AI Client** - Connects directly to MCP server HTTP endpoint

```
+----------------+     +------------------+     +------------------+
|   OpenCode     |<--->|   MCP Server     |<--->|  Penpot Plugin   |
|                |     |   (port 4401)    |     |   (WebSocket)    |
+----------------+     +------------------+     +------------------+
                                                        |
                                                        v
                                                +------------------+
                                                |     Penpot       |
                                                |    (browser)     |
                                                +------------------+
```

## Installation

### 1. Clone and Build the Server

```bash
mkdir -p ~/.local/share
git clone https://github.com/penpot/penpot-mcp.git ~/.local/share/penpot-mcp
cd ~/.local/share/penpot-mcp
npm install
npm run build:all
```

### 2. Configure OpenCode

Add to `opencode.json` in your project root:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "penpot": {
      "type": "remote",
      "url": "http://localhost:4401/mcp",
      "enabled": true
    }
  }
}
```

Or use the CLI:

```bash
opencode mcp add
# Type: remote
# URL: http://localhost:4401/mcp
```

Verify configuration:

```bash
opencode mcp list
# Should show: ✓ penpot connected (when server is running)
```

## Usage

### Starting the Servers

```bash
cd ~/.local/share/penpot-mcp && npm run start:all &>/tmp/penpot-mcp.log &
```

This starts:
- **Port 4400**: Plugin web server
- **Port 4401**: MCP HTTP endpoint
- **Port 4402**: WebSocket server (plugin connection)
- **Port 4403**: REPL server

Verify servers are running:

```bash
ss -tlnp | grep -E "440[0-3]"
```

### Connecting the Plugin

1. Open [design.penpot.app](https://design.penpot.app)
2. Open a design file
3. Click **Plugins menu** (puzzle icon, bottom-left)
4. Click **"Install plugin from URL"**
5. Enter: `http://localhost:4400/manifest.json`
6. Open the installed plugin
7. Click **"Connect to MCP server"**

**Browser Warning**: If you get "The plugin doesn't exist or the URL is not correct":
- **Brave**: Click lion icon → turn **Shields OFF** for design.penpot.app → refresh
- **Chrome/Edge**: Allow local network access when prompted
- **Firefox**: Usually works without issues (recommended)

### Using with OpenCode

Use the `/designer` command to start an interactive design session. This will:
1. Start the servers if needed
2. Guide you through connecting the plugin
3. Give you access to Penpot MCP tools

## Available Tools

| Tool | Description |
|------|-------------|
| `penpot_execute_code` | Execute JavaScript using the Penpot Plugin API |
| `penpot_high_level_overview` | Get overview of the Penpot API |
| `penpot_penpot_api_info` | Get documentation for specific API types |
| `penpot_export_shape` | Export a shape as PNG/SVG |
| `penpot_import_image` | Import an image into the design |

## Example Code

### Get Page Structure

```javascript
const pages = penpotUtils.getPages();
const structure = penpotUtils.shapeStructure(penpot.root, 3);
return { pages, structure };
```

### Find and Modify Elements

```javascript
// Find a shape by name
const button = penpotUtils.findShape(s => s.name === "BaseButton");

// Change fill color to pink
button.fills = [{ fillColor: "#EC4899", fillOpacity: 1 }];

return { success: true, buttonId: button.id };
```

### Work with Components

```javascript
// List library components
const components = penpot.library.local.components.map(c => ({
  id: c.id,
  name: c.name
}));

return components;
```

### Generate CSS

```javascript
// Generate CSS for selected elements
return penpot.generateStyle(penpot.selection, { type: "css", withChildren: true });
```

## Stopping the Servers

```bash
pkill -f "penpot-mcp"
```

## Troubleshooting

### "The plugin doesn't exist or the URL is not correct"

Browser security blocking localhost:
- **Brave**: Turn off Shields for design.penpot.app
- **Chrome/Edge**: Allow local network access
- **Firefox**: Works without configuration

### Plugin won't connect to MCP server

- Check browser console (F12) for WebSocket errors
- Ensure servers are running: `ss -tlnp | grep 440`
- Keep the plugin UI open - closing it disconnects

### MCP tools not available in OpenCode

1. Ensure servers are running first
2. Check: `opencode mcp list` - should show penpot as connected
3. Config must be in `opencode.json` (not `.opencode/config.json`)
4. Use `"mcp"` key, not `"mcpServers"`
5. Restart OpenCode after adding config

### Servers not starting

```bash
# Check logs
tail -50 /tmp/penpot-mcp.log

# Restart
pkill -f penpot-mcp
cd ~/.local/share/penpot-mcp && npm run start:all
```

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
