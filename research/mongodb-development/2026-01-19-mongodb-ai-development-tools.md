---
topic: MongoDB AI Development Tools and MCP Integration
date: 2026-01-19
project: mongodb-development
sources_count: 5
status: draft
tags: [mongodb, mcp, ai-tools, development]
---

# MongoDB AI Development Tools and MCP Integration

## Summary

MongoDB provides an **official MCP (Model Context Protocol) server** that enables AI assistants to interact with MongoDB databases and Atlas clusters. This is the recommended approach for AI-assisted MongoDB development. The official server (`mongodb-mcp-server`) is actively maintained by MongoDB and provides comprehensive tools for both database operations and Atlas cluster management.

Beyond MCP, MongoDB offers traditional development tools including **Compass** (GUI with AI-powered natural language querying) and **mongosh** (JavaScript shell). For AI-assisted workflows, the MCP server is the most powerful integration, allowing AI to directly query, analyze schemas, build aggregations, and manage Atlas resources.

## Key Findings

1. **Official MongoDB MCP Server exists**: `mongodb-mcp-server` by mongodb-js is the official, production-ready MCP server with 891+ stars
2. **Two operation modes**: Can connect via connection string (any MongoDB) OR Atlas API credentials (for Atlas management)
3. **Comprehensive toolset**: 30+ tools covering CRUD, aggregations, schema analysis, index management, and Atlas operations
4. **Read-only mode available**: `--readOnly` flag restricts to safe read/metadata operations only
5. **Docker support**: Can run as container for isolation
6. **Compass has AI**: MongoDB Compass now includes an "intelligent assistant" for natural language querying

## MongoDB MCP Server

### Installation

The official MongoDB MCP server can be installed via npx:

```json
{
  "mcpServers": {
    "MongoDB": {
      "command": "npx",
      "args": ["-y", "mongodb-mcp-server@latest", "--readOnly"],
      "env": {
        "MDB_MCP_CONNECTION_STRING": "mongodb://localhost:27017/myDatabase"
      }
    }
  }
}
```

### Available Tools

#### Database Tools
| Tool | Description |
|------|-------------|
| `find` | Run find queries against collections |
| `aggregate` | Run aggregation pipelines |
| `collection-schema` | Describe/infer schema for a collection |
| `collection-indexes` | List indexes for a collection |
| `collection-storage-size` | Get collection size |
| `count` | Count documents with optional filter |
| `create-collection` | Create new collection |
| `create-index` | Create an index |
| `drop-index` | Drop an index |
| `drop-collection` | Drop a collection |
| `drop-database` | Drop a database |
| `insert-many` | Insert documents |
| `update-many` | Update documents |
| `delete-many` | Delete documents |
| `explain` | Explain query execution plan |
| `export` | Export query results to EJSON |
| `list-databases` | List all databases |
| `list-collections` | List collections in database |
| `mongodb-logs` | Get recent mongod logs |
| `connect` | Connect to MongoDB instance |
| `switch-connection` | Switch to different connection |

#### Atlas Tools
| Tool | Description |
|------|-------------|
| `atlas-list-clusters` | List Atlas clusters |
| `atlas-inspect-cluster` | Get cluster metadata |
| `atlas-create-free-cluster` | Create free tier cluster |
| `atlas-list-projects` | List Atlas projects |
| `atlas-create-project` | Create new project |
| `atlas-list-db-users` | List database users |
| `atlas-create-db-user` | Create database user |
| `atlas-create-access-list` | Add IP to access list |
| `atlas-get-performance-advisor` | Get performance recommendations |
| `atlas-list-alerts` | List alerts |

### Configuration Options

| Option | Description |
|--------|-------------|
| `--readOnly` | Only allow read operations |
| `--disabledTools` | Disable specific tools |
| `--indexCheck` | Require queries use indexes |
| `--connectionString` | MongoDB connection string |
| `--apiClientId` | Atlas API client ID |
| `--apiClientSecret` | Atlas API secret |

### For ShipitSmarter

For local development with viya-app:

```json
{
  "mcpServers": {
    "mongodb": {
      "command": "npx",
      "args": ["-y", "mongodb-mcp-server@latest"],
      "env": {
        "MDB_MCP_CONNECTION_STRING": "mongodb://localhost:27017/shipping",
        "MDB_MCP_READ_ONLY": "true"
      }
    }
  }
}
```

For Atlas (production/staging inspection):

```json
{
  "mcpServers": {
    "mongodb-atlas": {
      "command": "npx",
      "args": ["-y", "mongodb-mcp-server@latest", "--readOnly"],
      "env": {
        "MDB_MCP_API_CLIENT_ID": "${ATLAS_CLIENT_ID}",
        "MDB_MCP_API_CLIENT_SECRET": "${ATLAS_CLIENT_SECRET}"
      }
    }
  }
}
```

## Alternative Tools

### MongoDB Compass

GUI tool with:
- Visual query builder
- Aggregation pipeline builder
- Schema analysis
- Index management
- **AI-powered natural language querying** (new feature)

Good for: Visual exploration, learning aggregations, ad-hoc queries

### mongosh (MongoDB Shell)

JavaScript REPL for MongoDB:
- Direct database interaction
- Script automation
- Custom functions via `.mongoshrc`
- Snippets for code reuse

Good for: Scripting, automation, direct shell access

### VS Code Extensions

- **MongoDB for VS Code** - Browse data, run queries, playgrounds
- Limited compared to MCP integration

## Recommendations for ShipitSmarter

### 1. Install MongoDB MCP Server (Primary)

Add to OpenCode config for AI-assisted MongoDB work:

```json
{
  "mcpServers": {
    "mongodb": {
      "command": "npx",
      "args": ["-y", "mongodb-mcp-server@latest"],
      "env": {
        "MDB_MCP_CONNECTION_STRING": "mongodb://localhost:27017/shipping"
      }
    }
  }
}
```

Benefits:
- AI can directly query and analyze data
- Schema inference for understanding data models
- Aggregation assistance
- Index recommendations via performance advisor

### 2. Create MongoDB Development Skill

A skill should cover:
- Common query patterns for shipping database
- Aggregation pipeline patterns
- Index strategy guidance
- Schema conventions used in ShipitSmarter services

### 3. Safety Considerations

- Use `--readOnly` for production/staging connections
- Use `--disabledTools drop-database,drop-collection,delete-many` for extra safety
- Use Atlas API credentials with minimal permissions
- Consider `--indexCheck` to prevent collection scans

## Sources

| # | Source | Key Contribution |
|---|--------|------------------|
| 1 | [mongodb-mcp-server GitHub](https://github.com/mongodb-js/mongodb-mcp-server) | Official MCP server documentation, tool list, configuration |
| 2 | [MongoDB Compass](https://www.mongodb.com/products/tools/compass) | GUI tool with AI assistant features |
| 3 | [mongosh Docs](https://www.mongodb.com/docs/mongodb-shell/) | Shell scripting and automation |
| 4 | [MCP Servers Registry](https://github.com/modelcontextprotocol/servers) | MCP ecosystem overview |
| 5 | [MongoDB Docs](https://www.mongodb.com/docs/) | General MongoDB documentation |

## Questions for Further Research

- [ ] What are the specific Atlas API permissions needed for read-only access?
- [ ] How to configure MongoDB MCP for multiple databases (shipping, auditor, etc.)?
- [ ] Can we use MongoDB MCP with Analytics MongoDB (read-only replica)?
- [ ] What common aggregation patterns should be documented for shipping data?
