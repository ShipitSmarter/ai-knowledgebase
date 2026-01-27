# OpenCode Plugins

Configuration guides for OpenCode plugins used in this repository.

## Installed Plugins

| Plugin | Description | Documentation |
|--------|-------------|---------------|
| opencode-mem | Persistent memory with vector search | [Setup Guide](./opencode-mem.md) |
| Google AI Search | Web search via Google AI Mode | [Setup Guide](./google-ai-search.md) |
| ai-attribution | Tracks AI file modifications for git commit attribution | [Research](../../research/ai-commit-attribution/) |

## Configuration

Plugins are configured in `.opencode/config.json`:

```json
{
  "plugins": [
    "opencode-mem"
  ]
}
```

## Custom Plugins

Custom TypeScript plugins live in the `plugins/` directory at the repo root. These are symlinked to `~/.config/opencode/plugins/` by the setup script for global availability.

| Plugin | Location | Description |
|--------|----------|-------------|
| ai-attribution | `plugins/ai-attribution.ts` | Tracks AI file modifications for git commit attribution |

### Creating a New Plugin

1. Create a `.ts` file in `plugins/`
2. Export a default object implementing the OpenCode Plugin interface
3. Run `./tools/setup.sh` to ensure the symlink is in place
4. Plugins in the plugins directory are auto-loaded (no config needed)

## Plugin vs MCP Server

- **Plugins**: Built-in OpenCode extensions (add to `plugins` array)
- **MCP Servers**: External tools via Model Context Protocol (add to `mcpServers` object)

Google AI Search is technically an MCP server but documented here since it's a local file-based plugin rather than an npm package.

## See Also

- [MCP Servers](../mcp-servers/README.md) - External tool integrations
- [Research Skill](../../skills/research-strategy/research/SKILL.md) - Uses these plugins for research workflows
