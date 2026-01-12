# Figma MCP Server

Access Figma designs and layout information from AI coding agents.

## Recommended Server

**[Figma-Context-MCP](https://github.com/GLips/Figma-Context-MCP)** (12.5k stars)
- Provides Figma layout information to AI coding agents
- Best for: Cursor, OpenCode, and other coding assistants
- Translates Figma designs to code-friendly context

## Installation

```bash
npm install -g figma-context-mcp
```

## Configuration

### OpenCode Config

Add to `~/.config/opencode/config.json` or `.opencode/config.json`:

```jsonc
{
  "mcpServers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "figma-context-mcp"],
      "env": {
        "FIGMA_API_KEY": "${FIGMA_API_KEY}"
      }
    }
  }
}
```

### Environment Variable

```bash
# Add to ~/.bashrc or ~/.zshrc
export FIGMA_API_KEY="your-figma-personal-access-token"
```

## Getting a Figma API Key

1. Go to [Figma Account Settings](https://www.figma.com/settings)
2. Scroll to "Personal access tokens"
3. Click "Generate new token"
4. Give it a descriptive name (e.g., "OpenCode MCP")
5. Copy the token and store it securely

## Available Tools

Once configured, you can ask OpenCode to:

- "Get the layout information from this Figma file: [URL]"
- "Extract the design tokens from the Figma component"
- "Show me the spacing and typography from this design"
- "Convert this Figma frame to React component structure"

## Alternative Servers

| Server | Stars | Description |
|--------|-------|-------------|
| [figma-mcp-server](https://github.com/TimHolden/figma-mcp-server) | 145 | Full Figma API implementation |
| [mcp-figma](https://github.com/thirdstrandstudio/mcp-figma) | 54 | Full API functionality |
| [figma-flutter-mcp](https://github.com/mhmzdev/figma-flutter-mcp) | 182 | Flutter-specific integration |
| [mcp-figma-to-react](https://github.com/StudentOfJS/mcp-figma-to-react) | 64 | Figma to React conversion |

### Full API Alternative

For complete Figma API access:

```jsonc
{
  "mcpServers": {
    "figma-full": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-figma"],
      "env": {
        "FIGMA_API_KEY": "${FIGMA_API_KEY}"
      }
    }
  }
}
```

## Use Cases

### Design-to-Code Workflow

1. Share Figma file URL with OpenCode
2. Ask: "Analyze this design and create the component structure"
3. OpenCode reads design tokens, spacing, colors
4. Generates code matching the design

### Design System Extraction

1. Point to Figma design system file
2. Ask: "Extract all colors and typography as CSS variables"
3. Get consistent design tokens for your codebase

## Troubleshooting

### "Invalid API key"
- Verify your token in Figma settings
- Ensure the token has read access to the file
- Check the token hasn't expired

### "File not found"
- Verify you have access to the Figma file
- Check the URL is a valid Figma file URL
- Ensure the file is shared or you're a team member

## Resources

- [Figma API Documentation](https://www.figma.com/developers/api)
- [Figma MCP Server Guide](https://github.com/figma/mcp-server-guide)
- [Figma-Context-MCP Repository](https://github.com/GLips/Figma-Context-MCP)
