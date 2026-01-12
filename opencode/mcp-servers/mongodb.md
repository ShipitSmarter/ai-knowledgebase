# MongoDB MCP Server

Official MongoDB MCP Server for database operations and Atlas cluster management.

## Official Server

**[mongodb-js/mongodb-mcp-server](https://github.com/mongodb-js/mongodb-mcp-server)** (878 stars)
- Official server from MongoDB team
- Supports both local MongoDB and Atlas
- Full database operations + Atlas management
- Apache 2.0 license

## Installation

```bash
npm install -g mongodb-mcp-server
```

## Configuration

### OpenCode Config

Add to `~/.config/opencode/config.json` or `.opencode/config.json`:

#### Option 1: Connection String (Local or Atlas)

```jsonc
{
  "mcpServers": {
    "mongodb": {
      "command": "npx",
      "args": ["-y", "mongodb-mcp-server", "--readOnly"],
      "env": {
        "MDB_MCP_CONNECTION_STRING": "${MDB_MCP_CONNECTION_STRING}"
      }
    }
  }
}
```

#### Option 2: Atlas API Credentials

```jsonc
{
  "mcpServers": {
    "mongodb": {
      "command": "npx",
      "args": ["-y", "mongodb-mcp-server", "--readOnly"],
      "env": {
        "MDB_MCP_API_CLIENT_ID": "${MDB_MCP_API_CLIENT_ID}",
        "MDB_MCP_API_CLIENT_SECRET": "${MDB_MCP_API_CLIENT_SECRET}"
      }
    }
  }
}
```

#### Option 3: Full Access (Read/Write)

```jsonc
{
  "mcpServers": {
    "mongodb": {
      "command": "npx",
      "args": ["-y", "mongodb-mcp-server"],
      "env": {
        "MDB_MCP_CONNECTION_STRING": "${MDB_MCP_CONNECTION_STRING}"
      }
    }
  }
}
```

### Environment Variables

```bash
# Add to ~/.bashrc or ~/.zshrc

# Connection string (local or Atlas)
export MDB_MCP_CONNECTION_STRING="mongodb://localhost:27017/myDatabase"
# Or for Atlas:
export MDB_MCP_CONNECTION_STRING="mongodb+srv://user:pass@cluster.mongodb.net/myDatabase"

# Atlas API credentials (for cluster management)
export MDB_MCP_API_CLIENT_ID="your-atlas-service-account-client-id"
export MDB_MCP_API_CLIENT_SECRET="your-atlas-service-account-client-secret"
```

## Available Tools

### Database Operations

| Tool | Description |
|------|-------------|
| `find` | Query documents from a collection |
| `aggregate` | Run aggregation pipelines |
| `insert-many` | Insert documents |
| `update-many` | Update documents |
| `delete-many` | Delete documents |
| `count` | Count documents |
| `create-collection` | Create new collection |
| `drop-collection` | Drop collection |
| `create-index` | Create index |
| `drop-index` | Drop index |
| `collection-schema` | Infer collection schema |
| `collection-indexes` | List indexes |
| `list-databases` | List all databases |
| `list-collections` | List collections in database |

### Atlas Management

| Tool | Description |
|------|-------------|
| `atlas-list-clusters` | List Atlas clusters |
| `atlas-inspect-cluster` | Get cluster details |
| `atlas-create-free-cluster` | Create free tier cluster |
| `atlas-list-projects` | List Atlas projects |
| `atlas-create-project` | Create new project |
| `atlas-list-db-users` | List database users |
| `atlas-create-db-user` | Create database user |
| `atlas-get-performance-advisor` | Get performance recommendations |

## Use Cases

### Query and Explore Data

```
> "Show me the schema of the users collection"
> "Find all orders from the last 7 days"
> "Run an aggregation to get sales by category"
```

### Database Management

```
> "Create an index on the email field in users collection"
> "List all collections in the production database"
> "Show me slow query logs from Atlas"
```

### Atlas Operations

```
> "List all my Atlas clusters"
> "Create a new free tier cluster in AWS us-east-1"
> "Show performance recommendations for my cluster"
```

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `--readOnly` | false | Only allow read operations |
| `--connectionString` | - | MongoDB connection string |
| `--apiClientId` | - | Atlas API client ID |
| `--apiClientSecret` | - | Atlas API client secret |
| `--disabledTools` | "" | Comma-separated tools to disable |
| `--maxDocumentsPerQuery` | 100 | Max documents returned |
| `--indexCheck` | false | Require queries to use indexes |

### Read-Only Mode (Recommended for Safety)

```jsonc
{
  "mcpServers": {
    "mongodb": {
      "command": "npx",
      "args": ["-y", "mongodb-mcp-server", "--readOnly"],
      "env": {
        "MDB_MCP_CONNECTION_STRING": "${MDB_MCP_CONNECTION_STRING}"
      }
    }
  }
}
```

### Disable Specific Tools

```jsonc
{
  "mcpServers": {
    "mongodb": {
      "command": "npx",
      "args": [
        "-y", "mongodb-mcp-server",
        "--disabledTools", "drop-database,drop-collection,delete-many"
      ],
      "env": {
        "MDB_MCP_CONNECTION_STRING": "${MDB_MCP_CONNECTION_STRING}"
      }
    }
  }
}
```

## Getting Atlas API Credentials

1. Go to [MongoDB Atlas](https://cloud.mongodb.com)
2. Navigate to **Organization Access Manager**
3. Go to **API Keys** or **Service Accounts**
4. Create a new Service Account
5. Assign appropriate permissions (e.g., "Organization Read Only")
6. Copy the Client ID and Client Secret

## Docker Usage

```bash
# With connection string
docker run --rm -i \
  -e MDB_MCP_CONNECTION_STRING="mongodb://host.docker.internal:27017/mydb" \
  -e MDB_MCP_READ_ONLY="true" \
  mongodb/mongodb-mcp-server:latest
```

## Security Best Practices

1. **Use `--readOnly`** for exploration and analysis
2. **Use environment variables** for credentials (never command-line args)
3. **Limit permissions** in Atlas service accounts
4. **Disable destructive tools** if not needed
5. **Use connection strings with minimal permissions**

## Troubleshooting

### "Connection failed"
- Check connection string format
- Verify network access (Atlas IP allowlist)
- Ensure credentials are correct

### "Authentication failed"
- Verify username/password in connection string
- Check database user exists and has permissions
- For Atlas: verify service account credentials

### "Tool not found"
- Check if tool is disabled via `--disabledTools`
- Verify `--readOnly` isn't blocking write operations

## Resources

- [MongoDB MCP Server GitHub](https://github.com/mongodb-js/mongodb-mcp-server)
- [MongoDB Atlas Documentation](https://www.mongodb.com/docs/atlas/)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
