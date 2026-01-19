# MongoDB Development

Research on MongoDB development tools, AI integrations, and best practices for ShipitSmarter.

## Documents

| Date | Topic | Status |
|------|-------|--------|
| 2026-01-19 | [MongoDB AI Development Tools and MCP Integration](./2026-01-19-mongodb-ai-development-tools.md) | draft |

## Key Insights

- **Official MCP server exists**: `mongodb-mcp-server` is the recommended way to give AI assistants MongoDB access
- **Two modes**: Connection string (any MongoDB) or Atlas API (cluster management)
- **Safety first**: Use `--readOnly` flag for production connections
- **30+ tools available**: CRUD, aggregations, schema inference, index management, Atlas operations

## Open Questions

- [ ] Configure MCP for multiple ShipitSmarter databases
- [ ] Document common shipping database aggregation patterns
- [ ] Set up Atlas API service account with minimal permissions
