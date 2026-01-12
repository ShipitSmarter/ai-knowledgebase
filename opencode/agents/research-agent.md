# Research Agent

An OpenCode agent configuration for conducting online research with source tracking, project-based organization, and integration with your existing knowledge base.

## Features

- Online research with source attribution (Google AI Search)
- Notion knowledge base integration (check existing knowledge first)
- Persistent memory across sessions (opencode-mem)
- Automatic project detection (new vs existing)
- Structured output with links to original sources
- Research stored per-project in `research/` folder
- Cross-session recall of research context

## Setup

### 1. Install Required Tools

```bash
# Install Playwright for Google AI Search
npm install -g playwright
npx playwright install chromium

# Clone Google AI Search plugin
mkdir -p ~/.opencode/plugins
git clone https://github.com/IgorWarzocha/Opencode-Google-AI-Search-Plugin.git \
  ~/.opencode/plugins/opencode-google-ai-search
cd ~/.opencode/plugins/opencode-google-ai-search
npm install && npm run build
```

### 2. Set Environment Variables

```bash
# Notion integration token (from https://www.notion.so/profile/integrations)
export NOTION_TOKEN="ntn_your_integration_secret_here"
```

### 3. OpenCode Configuration

The `.opencode/config.json` in this repository is pre-configured:

```jsonc
{
  "plugins": ["opencode-mem"],
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["-y", "@notionhq/notion-mcp-server"],
      "env": { "NOTION_TOKEN": "${NOTION_TOKEN}" }
    },
    "google-ai-search": {
      "command": "node",
      "args": ["${HOME}/.opencode/plugins/opencode-google-ai-search/dist/index.js"]
    }
  }
}
```

### 4. Connect Notion Pages

1. Go to your Notion workspace
2. Open pages you want accessible for research
3. Click `...` menu > "Connect to" > Select your integration
4. Share parent pages to include all children

### 5. Research Agent Skill

The skill is configured at `.opencode/skill/research/SKILL.md`. Key behaviors:

#### Research Workflow

```
1. CHECK MEMORY    → Search opencode-mem for prior research on topic
2. CHECK NOTION    → Search Notion knowledge base for existing notes
3. WEB SEARCH      → Use Google AI Search for new information
4. SYNTHESIZE      → Combine existing knowledge with new findings
5. STORE           → Save to research/ folder + add key points to memory
6. LINK            → Reference relevant Notion pages in output
```

#### Output Format

Files created at: `research/<project-name>/<date>-<topic-slug>.md`

```markdown
---
topic: <full topic>
date: <YYYY-MM-DD>
sources_count: <number>
notion_refs: [<page-ids>]
status: draft | reviewed | final
---

# <Topic Title>

## Summary
<2-3 paragraph executive summary>

## Key Findings
- Finding 1
- Finding 2

## Related Knowledge Base
- [Notion: Page Title](notion://page-id) - Existing notes on...

## Detailed Analysis
<Organized sections based on topic>

## Sources
1. [Title](URL) - Brief description of what was learned
2. [Title](URL) - Brief description of what was learned

## Questions for Further Research
- Question 1
- Question 2
```

#### Source Requirements
- ALWAYS include original URLs
- Note the date accessed
- Prefer primary sources over aggregators
- Include author/organization when available

## Directory Structure

```
research/
├── <project-name>/
│   ├── _index.md              # Project overview and status
│   ├── 2026-01-12-topic-a.md  # Individual research files
│   ├── 2026-01-13-topic-b.md
│   └── sources/               # Downloaded PDFs, images
└── <another-project>/
    └── ...
```

## Usage Examples

### New Research Project
```
> /research AI agent memory architectures

I'll create a new research project for this. Suggested name: "ai-agent-memory"
Is this correct? (y/n or provide alternative name)

> y

Researching AI agent memory architectures...
[Searches multiple sources]

Created: research/ai-agent-memory/2026-01-12-memory-architectures.md

## Summary
Found 5 authoritative sources covering...

## Key Findings
1. Three main memory types: episodic, semantic, procedural
2. Vector databases are the dominant storage approach
...
```

### Adding to Existing Project
```
> /research vector database comparison for agent memory

Found existing project: ai-agent-memory
Adding research to this project...

Created: research/ai-agent-memory/2026-01-12-vector-db-comparison.md
```

### Listing Projects
```
> /research --list

Research Projects:
1. ai-agent-memory (3 documents, last updated: 2026-01-12)
2. figma-to-code (1 document, last updated: 2026-01-10)
```

## Best Practices

### Source Quality
- Prefer academic papers, official documentation, reputable tech blogs
- Cross-reference claims across multiple sources
- Note when sources disagree

### Organization
- One focused topic per research file
- Use clear, descriptive filenames
- Update project `_index.md` with new findings

### Attribution
- Always link to original source
- Quote directly when appropriate (with quotation marks)
- Summarize in your own words for general findings

## Recommended Tools

| Tool | Purpose | Documentation |
|------|---------|---------------|
| Google AI Search | Web search with AI synthesis | [Setup Guide](../plugins/google-ai-search.md) |
| Notion MCP | Knowledge base integration | [Setup Guide](../mcp-servers/notion.md) |
| opencode-mem | Persistent memory | [Setup Guide](../plugins/opencode-mem.md) |

### Alternative: Brave Search

If Google AI Search is unreliable, configure Brave Search as fallback:

```jsonc
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      }
    }
  }
}
```

## Memory Integration

opencode-mem enables cross-session research continuity:

### Automatic Behaviors

1. **Before Research**: Check for prior research
   ```javascript
   memory({ mode: "search", query: "<topic>", tags: ["research"] })
   ```

2. **After Research**: Store key findings
   ```javascript
   memory({
     mode: "add",
     content: "Key finding: ...",
     scope: "project",
     tags: ["research", "<project-name>"]
   })
   ```

3. **Cross-Project Links**: Connect related research
   ```javascript
   memory({
     mode: "add", 
     content: "Research on X relates to project Y findings on Z",
     scope: "user"
   })
   ```

### Web UI

Browse all stored research context at `http://127.0.0.1:4747`
