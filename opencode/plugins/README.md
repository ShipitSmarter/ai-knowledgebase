# OpenCode Plugins

Configuration guides for OpenCode plugins used in this repository.

## Installed Plugins

| Plugin | Description | Documentation |
|--------|-------------|---------------|
| opencode-mem | Persistent memory with vector search | [Setup Guide](./opencode-mem.md) |
| Google AI Search | Web search via Google AI Mode | [Setup Guide](./google-ai-search.md) |

## Configuration

Plugins are configured in `.opencode/config.json`:

```json
{
  "plugins": [
    "opencode-mem"
  ]
}
```

## Plugin vs MCP Server

- **Plugins**: Built-in OpenCode extensions (add to `plugins` array)
- **MCP Servers**: External tools via Model Context Protocol (add to `mcpServers` object)

Google AI Search is technically an MCP server but documented here since it's a local file-based plugin rather than an npm package.

## See Also

- [MCP Servers](../mcp-servers/README.md) - External tool integrations
- [Research Agent](../agents/research-agent.md) - Uses these plugins for research workflows
