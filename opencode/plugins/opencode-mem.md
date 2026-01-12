# opencode-mem Plugin

Persistent memory for OpenCode using a local vector database. Enables cross-session recall, user preferences, and project-specific context.

## Overview

- **Storage**: Local SQLite + sqlite-vec (vector embeddings)
- **Scopes**: User-level (global) and project-level memories
- **Web UI**: Browse and manage memories at `http://127.0.0.1:4747`
- **Auto-capture**: Intelligent extraction of important information

## Installation

### 1. Add Plugin to OpenCode

In `.opencode/config.json`:

```json
{
  "plugins": [
    "opencode-mem"
  ]
}
```

### 2. Plugin Configuration

Create `~/.config/opencode/opencode-mem.jsonc`:

```jsonc
{
  // Memory storage location
  "dataDir": "~/.local/share/opencode-mem",
  
  // Web UI settings
  "webUI": {
    "enabled": true,
    "port": 4747,
    "host": "127.0.0.1"
  },
  
  // Auto-capture settings
  "autoCapture": {
    "enabled": true,
    "capturePatterns": [
      "user prefers",
      "always use",
      "never use", 
      "remember that",
      "note that",
      "important:"
    ]
  },
  
  // Embedding model (for semantic search)
  "embedding": {
    "model": "text-embedding-3-small",
    "dimensions": 1536
  },
  
  // Memory retention
  "retention": {
    "maxMemories": 10000,
    "pruneAfterDays": 365
  }
}
```

## Memory Tool Usage

The plugin provides a `memory` tool with multiple modes:

### Add Memory

```javascript
memory({
  mode: "add",
  content: "User prefers TypeScript over JavaScript for all new projects",
  scope: "user",  // "user" (global) or "project"
  tags: ["preferences", "languages"]
})
```

### Search Memories

```javascript
memory({
  mode: "search",
  query: "TypeScript preferences",
  scope: "user",  // optional, defaults to both
  limit: 10
})
```

### List Memories

```javascript
memory({
  mode: "list",
  scope: "project",
  tags: ["api", "authentication"]
})
```

### User Profile

```javascript
memory({
  mode: "profile"
})
// Returns aggregated user preferences, patterns, and workflows
```

### Delete Memory

```javascript
memory({
  mode: "delete",
  id: "mem_abc123"
})
```

## Memory Scopes

### User-Level (Global)
- Persists across all projects
- Stores: preferences, workflows, common patterns
- Location: `~/.local/share/opencode-mem/user.db`

### Project-Level
- Specific to current project
- Stores: project decisions, architecture notes, conventions
- Location: `.opencode/memory.db` (in project root)

## Auto-Capture

When enabled, opencode-mem automatically captures important information from conversations:

**Triggers**:
- Explicit statements: "Remember that...", "Always use...", "I prefer..."
- Decisions: "Let's go with X approach"
- Corrections: "Actually, use Y instead of X"
- Patterns: Repeated behaviors across sessions

**Example**:
```
User: "I always want tests written with Vitest, not Jest"
System: [Auto-captured as user preference]
```

## Web UI

Access at `http://127.0.0.1:4747` when enabled.

### Features
- Browse all memories by scope
- Search with filters
- Edit/delete memories
- View memory statistics
- Export/import memories

### Starting Web UI
The web UI starts automatically with OpenCode. To start manually:
```bash
opencode-mem serve
```

## Integration with Research Agent

Recommended workflow for research:

1. **Before searching**: Check memories for relevant prior research
   ```
   memory({ mode: "search", query: "OAuth implementation" })
   ```

2. **After research**: Store important findings
   ```
   memory({
     mode: "add",
     content: "Google OAuth requires consent screen setup before API access",
     scope: "project",
     tags: ["oauth", "google", "research"]
   })
   ```

3. **Cross-session recall**: Next time the topic comes up, relevant context is automatically available

## Best Practices

1. **Tag Consistently**: Use consistent tags for easier retrieval
2. **Scope Appropriately**: User preferences = global, project decisions = project
3. **Be Specific**: "User prefers Tailwind CSS" > "User likes CSS frameworks"
4. **Review Periodically**: Use web UI to clean outdated memories
5. **Don't Over-store**: Focus on decisions and preferences, not facts

## Troubleshooting

### Memories Not Persisting
- Check `dataDir` path exists and is writable
- Verify plugin is listed in `config.json`

### Web UI Not Loading
- Check if port 4747 is available
- Try different port in config

### Search Not Finding Results
- Semantic search may not match exact keywords
- Try rephrasing query or use tags

### High Memory Usage
- Reduce `maxMemories` in config
- Export and prune old memories

## CLI Commands

```bash
# List all memories
opencode-mem list

# Search memories
opencode-mem search "typescript preferences"

# Export memories
opencode-mem export > memories.json

# Import memories
opencode-mem import < memories.json

# Start web UI only
opencode-mem serve --port 4747

# Clear all memories (with confirmation)
opencode-mem clear --scope user
```

## Resources

- [opencode-mem GitHub](https://github.com/opencode/opencode-mem)
- [OpenCode Plugin Documentation](https://opencode.ai/docs/plugins)
