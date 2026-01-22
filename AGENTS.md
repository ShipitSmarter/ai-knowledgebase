# AGENTS.md - AI Agent Guidelines

This file provides guidelines for AI coding agents working in this repository.

## Repository Overview

This is a **documentation-only repository** for AI workflows, research, and agent
configurations at ShipitSmarter. It contains markdown files, configuration examples,
and research documents - no application code.

**Purpose**: Build a shared AI knowledgebase for showcasing AI use cases and enabling
team members to use content for their own models or research.

## Build/Lint/Test Commands

This is a documentation repository with no build system. There are no:
- Build commands
- Test suites
- Linting tools
- CI/CD pipelines

**Validation**: Manually review markdown formatting and link validity.

## Git Workflow

### Important: No Automatic Commits

**DO NOT automatically commit changes.** Always ask the user before committing.
- No branch protection rules currently in place
- All work happens on `main` unless user specifies otherwise
- Always show `git status` and proposed changes before committing

### Commit Message Style

Use conventional commit style based on existing commits:
```
Add <description of what was added>
Update <description of what changed>
Fix <description of what was fixed>
```

Examples from this repo:
- `Add OpenCode research workflow and MongoDB deployment research`
- `Add ShipitSmarter/Viya company research document`

## Directory Structure

```
ai-knowledgebase/
├── .opencode/              # OpenCode configuration (active config)
│   ├── config.json         # Main OpenCode config
│   ├── command/            # Slash commands (e.g., /research)
│   └── skill/              # Skills (detailed workflows)
├── opencode/               # OpenCode documentation & examples
│   ├── agents/             # Agent presets & prompts
│   ├── ide/                # IDE-specific setups
│   ├── mcp-servers/        # MCP server configurations
│   ├── plugins/            # Plugin documentation
│   └── skills/             # Skill documentation
├── research/               # Research projects (organized by topic)
│   └── <project-name>/     # Each project in its own folder
│       ├── _index.md       # Project overview
│       └── YYYY-MM-DD-*.md # Research documents
├── architect-reviews/      # Technical architecture reviews
│   └── YYYY-MM-DD-*.md     # Review documents
├── agents/                 # Generic agent configurations
├── workflows/              # Reusable AI workflow patterns
├── ideas/                  # Ideas backlog
├── tools/                  # Scripts and utilities
└── plan/                   # Planning documents
```

## File Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| General files | `kebab-case.md` | `code-review.md` |
| Research docs | `YYYY-MM-DD-topic.md` | `2026-01-12-atlas-operator.md` |
| Architect reviews | `YYYY-MM-DD-topic.md` | `2026-01-21-mv-implementation-plan.md` |
| Index files | `_index.md` or `README.md` | `research/mongodb/_index.md` |
| Directories | `lowercase` | `mcp-servers/` |

## Markdown Style Guide

### Frontmatter

Use YAML frontmatter for metadata on research documents:

```yaml
---
topic: Full Topic Title
date: YYYY-MM-DD
project: project-name
sources_count: 5
status: draft | reviewed | final
tags: [tag1, tag2, tag3]
---
```

### Document Structure

Research documents should follow this structure:
1. **Summary** - 2-3 paragraph executive summary
2. **Key Findings** - Numbered list of main points
3. **Detailed Analysis** - Organized by subtopic
4. **Sources** - Table with URLs and key contributions
5. **Questions for Further Research** - Open items as checklist

### Tables

Use GitHub-flavored markdown tables:

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data     | Data     | Data     |
```

### Code Blocks

Use fenced code blocks with language identifiers:

```markdown
    ```yaml
    key: value
    ```
```

### Links

- Use relative links for internal references: `[text](./other-file.md)`
- Use absolute URLs for external sources: `[text](https://example.com)`

## Research Workflow

When conducting research, use the `/research` skill which:

1. Checks memory for prior research on the topic
2. Searches Notion knowledge base for existing notes
3. Conducts web search for new information
4. Creates organized research document in `research/<project>/`
5. Stores key findings in memory for future recall

### Creating Research Documents

Place new research in the appropriate project folder:

```
research/<project-name>/YYYY-MM-DD-<topic-slug>.md
```

If creating a new project, also create `_index.md` with project overview.

### Source Attribution

Always include sources with:

- Full URL
- Author/organization if available
- Date if available
- Key contribution from that source

## OpenCode Configuration

### Config Location

Active configuration lives in `.opencode/config.json`.

### Skills vs Commands

- **Commands** (`.opencode/command/<name>.md`): Short trigger files
- **Skills** (`.opencode/skill/<name>/SKILL.md`): Detailed workflow instructions

### Available Tools

This repository is configured with:
- `opencode-mem` - Persistent memory across sessions
- `notion` MCP server - Search Notion knowledge base
- `google-ai-search` MCP server - Web research

## Content Guidelines

### What Belongs Here

- AI workflow documentation
- Research findings with sources
- Agent configurations and prompts
- IDE setup guides
- MCP server configurations
- Plugin documentation

### What Does NOT Belong Here

- Application source code
- Secrets or credentials (use environment variables)
- Large binary files
- Personal notes without team value

### Writing Style

- Be concise and actionable
- Use examples where helpful
- Include diagrams for complex architectures (ASCII or Mermaid)
- Prioritize primary sources over aggregators
- Note when sources conflict

## Error Handling

When research fails:
- Report the issue to the user
- Suggest alternative search terms
- Check if Notion has relevant content
- Offer to try different approaches

## Common Tasks

### Adding a New Research Topic

1. Check if project folder exists in `research/`
2. If not, create `research/<project>/_index.md`
3. Create `research/<project>/YYYY-MM-DD-<topic>.md`
4. Use the research document template
5. Update `_index.md` with new document link

### Adding IDE Configuration

1. Create folder in `opencode/ide/<ide-name>/`
2. Add `README.md` with setup instructions
3. Add relevant config files (`settings.json`, etc.)

### Adding MCP Server Documentation

1. Create `opencode/mcp-servers/<server-name>.md`
2. Include: description, installation, configuration, usage examples
