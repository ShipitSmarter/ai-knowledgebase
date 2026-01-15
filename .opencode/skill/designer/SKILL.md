---
name: designer
description: Start Penpot MCP servers and work with designs. Enables AI-assisted design workflows with Penpot.
---

# Designer Skill

Work with Penpot designs using the Penpot MCP server. Enables design-to-code and code-to-design workflows.

## Trigger

When user invokes `/designer` or asks to work with Penpot designs.

## Process

### Step 1: Start Penpot MCP Servers

Check if the servers are already running:

```bash
pgrep -f "penpot-mcp" && curl -s http://localhost:4401/mcp > /dev/null 2>&1
```

If not running, start them:

```bash
cd ~/.local/share/penpot-mcp && npm run start:all &>/tmp/penpot-mcp.log &
```

Wait for servers to be ready (ports 4400-4403):
- **4400**: Plugin server (serves the Penpot plugin UI)
- **4401**: MCP HTTP/SSE endpoint
- **4402**: WebSocket server (plugin connection)
- **4403**: REPL server

Verify with:
```bash
sleep 3 && ss -tlnp | grep -E "440[0-3]"
```

### Step 2: Guide User to Connect Plugin

Inform the user:

> **Penpot MCP servers are running!**
>
> To connect Penpot:
> 1. Open [design.penpot.app](https://design.penpot.app) in your browser
> 2. Open a **design file**
> 3. Click the **Plugins menu** (puzzle piece icon, bottom-left)
> 4. Click **"Install plugin from URL"**
> 5. Enter: `http://localhost:4400/manifest.json`
> 6. Open the installed plugin
> 7. Click **"Connect to MCP server"**
>
> Let me know when you're connected!

### Step 3: Wait for Connection

The user must confirm the plugin is connected before MCP tools will work.

Check server logs if needed:
```bash
tail -20 /tmp/penpot-mcp.log
```

Look for WebSocket connection messages indicating the plugin connected.

### Step 4: Use Penpot MCP Tools

Once connected, the following MCP tools are available:

| Tool | Description |
|------|-------------|
| `execute_code` | Execute arbitrary code in the Penpot Plugin API |
| `high_level_overview` | Get an overview of the current design file |
| `penpot_api_info` | Get information about available Penpot API methods |
| `export_shape` | Export a shape as an image |
| `import_image` | Import an image into the design |

### Step 5: Execute Design Tasks

Common design operations:

**Get Design Overview**
```
Use the high_level_overview tool to see the current design structure
```

**Query Design Elements**
```
Use execute_code to run Penpot Plugin API code, e.g.:
- Get all frames: penpot.getPage().children.filter(c => c.type === 'frame')
- Get selected elements: penpot.selection
- Get color palette: penpot.library.local.colors
```

**Modify Designs**
```
Use execute_code to create or modify elements using the Penpot Plugin API
```

**Export Assets**
```
Use export_shape to export specific shapes as PNG/SVG
```

## Stopping the Servers

When done, stop the servers:

```bash
pkill -f "penpot-mcp"
```

## Troubleshooting

### Plugin won't connect
- Check browser console for WebSocket errors
- In Brave browser, disable "Shield" for design.penpot.app
- Try Firefox if Chromium-based browsers have issues

### Servers not responding
- Check logs: `tail -50 /tmp/penpot-mcp.log`
- Restart: `pkill -f penpot-mcp && cd ~/.local/share/penpot-mcp && npm run start:all`

### MCP tools not available
- Restart OpenCode after servers are running
- Verify config in `.opencode/config.json` has penpot entry

## Architecture

```
+----------------+     +------------------+     +------------------+
|                |     |                  |     |                  |
|   OpenCode     |<--->|   MCP Server     |<--->|  Penpot Plugin   |
|   (via mcp-    |     |   (port 4401)    |     |  (WebSocket)     |
|    remote)     |     |                  |     |                  |
+----------------+     +------------------+     +------------------+
                              ^                         |
                              |                         v
                              |                 +------------------+
                              |                 |                  |
                              |                 |     Penpot       |
                              |                 |   (browser)      |
                              |                 |                  |
                              +-----------------+------------------+
```

## Resources

- [Penpot MCP GitHub](https://github.com/penpot/penpot-mcp)
- [Penpot Plugin API](https://help.penpot.app/plugins/)
- [Penpot Help](https://help.penpot.app/)
