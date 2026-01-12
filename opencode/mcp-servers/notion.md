# Notion MCP Server

Connect OpenCode to your Notion workspace for reading, searching, and managing your knowledge base.

## Server

**Official Server**: `@notionhq/notion-mcp-server`
- GitHub: https://github.com/makenotion/notion-mcp-server
- Stars: 3.7k+
- Maintainer: Notion (official)

## Installation

### 1. Create a Notion Integration

1. Go to https://www.notion.so/profile/integrations
2. Click "New integration"
3. Name it (e.g., "OpenCode")
4. Select your workspace
5. Copy the "Internal Integration Secret" (starts with `ntn_`)

### 2. Connect Pages to Integration

**Important**: The integration can only access pages explicitly shared with it.

1. Open a Notion page you want accessible
2. Click the `...` menu in the top right
3. Select "Connect to" > Your integration name
4. Repeat for each page/database you want accessible

**Tip**: Share a top-level page to give access to all its children.

### 3. Set Environment Variable

```bash
# Add to ~/.bashrc, ~/.zshrc, or equivalent
export NOTION_TOKEN="ntn_your_integration_secret_here"
```

### 4. OpenCode Configuration

Add to `.opencode/config.json`:

```json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_TOKEN": "${NOTION_TOKEN}"
      }
    }
  }
}
```

## Available Tools

| Tool | Description |
|------|-------------|
| `notion_search` | Search across all connected pages and databases |
| `notion_get_page` | Retrieve a specific page by ID |
| `notion_get_page_content` | Get the full content/blocks of a page |
| `notion_create_page` | Create a new page in a database or as a child |
| `notion_update_page` | Update page properties |
| `notion_get_database` | Get database schema and properties |
| `notion_query_database` | Query a database with filters/sorts |
| `notion_create_database_item` | Add a new item to a database |
| `notion_get_comments` | Get comments on a page or block |
| `notion_create_comment` | Add a comment to a page |

## Usage Examples

### Search Knowledge Base
```
Search my Notion for "API authentication patterns"
```

### Query a Database
```
Show me all tasks in my Projects database that are marked "In Progress"
```

### Create Documentation
```
Create a new page in my Documentation database titled "MCP Server Setup"
```

### Link Research
```
Find the relevant Notion page about OAuth flows and link it to my current research
```

## Best Practices

1. **Check Notion First**: Before web searching, check if relevant information exists in your Notion knowledge base
2. **Organize by Database**: Use Notion databases for structured content (research, projects, notes)
3. **Link Research**: When conducting research, link findings to relevant Notion pages
4. **Keep Token Secure**: Never commit your `NOTION_TOKEN` to version control

## Troubleshooting

### "Could not find page"
- Ensure the page is connected to your integration
- Check that the page ID is correct (from URL or API)

### "Unauthorized"
- Verify `NOTION_TOKEN` is set correctly
- Confirm the token hasn't expired or been revoked

### Rate Limits
- Notion API has rate limits (3 requests/second average)
- The server handles retries automatically

## Resources

- [Notion API Documentation](https://developers.notion.com/)
- [MCP Server README](https://github.com/makenotion/notion-mcp-server)
- [Integration Setup Guide](https://developers.notion.com/docs/create-a-notion-integration)
