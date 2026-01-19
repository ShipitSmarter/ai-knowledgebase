# ShipitSmarter AI Knowledgebase Setup

This repository serves as the central source for AI skills, commands, and MCP server configurations for all ShipitSmarter projects.

## Quick Start

Run the setup script:

```bash
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
```

Or manually clone and configure:

```bash
# Clone to standard location
git clone https://github.com/ShipitSmarter/ai-knowledgebase ~/.shipitsmarter/ai-knowledgebase

# Add to your shell config (~/.bashrc or ~/.zshrc)
export OPENCODE_CONFIG_DIR="$HOME/.shipitsmarter/ai-knowledgebase"
export OPENCODE_CONFIG="$HOME/.shipitsmarter/ai-knowledgebase/shared-config.json"
```

Restart your terminal or run `source ~/.bashrc` (or `~/.zshrc`).

## What You Get

### Skills

Available in all repos via the `/skill` command or automatically loaded by OpenCode:

| Skill | Description |
|-------|-------------|
| `github-issue-creator` | Create well-structured GitHub issues |
| `github-issue-tracker` | Track and update issue progress |
| `research` | Conduct web research with sources |
| `skill-writer` | Create new skills following the spec |
| `product-documentation` | Write product documentation |

**viya-app specific skills** (also available globally):
- `vue-component` - Vue 3 component conventions
- `unit-testing` - Vitest test patterns
- `playwright-test` - E2E test patterns
- `api-integration` - Generated API types
- `typescript-helpers` - TypeScript patterns
- `codebase-navigation` - Project structure guide
- `docs-writing` - User-facing documentation
- `github-workflow` - PR and commit conventions
- `pr-review` - Code review patterns
- `browser-debug` - Headless browser debugging

### Commands

Available via slash commands:
- `/research <topic>` - Research a topic with source attribution
- `/document <topic>` - Create documentation
- `/designer` - Start design workflow
- `/product-strategy` - Product strategy documents

### MCP Servers (opt-in)

Shared MCP server configurations, disabled by default. Enable in your project's `opencode.json`:

```json
{
  "mcp": {
    "notion": { "enabled": true },
    "google-ai-search": { "enabled": true },
    "posthog": { "enabled": true }
  }
}
```

**Available servers:**
| Server | Description | Required Env Var |
|--------|-------------|------------------|
| `notion` | Search Notion knowledge base | `NOTION_TOKEN` |
| `google-ai-search` | Web research | (plugin required) |
| `posthog` | Analytics queries | `POSTHOG_API_KEY` |

### Plugins

The `opencode-mem` plugin is enabled by default for persistent memory across sessions.

## Updating

Pull the latest skills and configurations:

```bash
git -C ~/.shipitsmarter/ai-knowledgebase pull
```

Or use the update script:

```bash
~/.shipitsmarter/ai-knowledgebase/tools/update.sh
```

## How It Works

OpenCode loads configuration from multiple sources that are merged together:

1. **Global config** (`~/.config/opencode/opencode.json`) - Your personal preferences
2. **Shared config** (`OPENCODE_CONFIG`) - Team-wide MCP servers and plugins
3. **Shared directory** (`OPENCODE_CONFIG_DIR`) - Skills, commands, agents
4. **Project config** (`opencode.json` in repo) - Project-specific settings

Project configs override shared configs, so you can customize per-project while inheriting team defaults.

## Adding New Skills

1. Create a folder in `skills/<skill-name>/`
2. Add a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: skill-name
description: What it does and when to use it
license: MIT
metadata:
  author: shipitsmarter
  version: "1.0"
---

# Skill Title

Instructions and guidelines...
```

3. Commit and push - all team members get it on next `git pull`

See the [skill-writer skill](../skills/skill-writer/SKILL.md) or [agentskills.io spec](https://agentskills.io/specification) for details.

## Adding New Commands

1. Create a markdown file in `commands/<command-name>.md`
2. Add frontmatter with description:

```yaml
---
description: Short description for command list
---

Your command template with $ARGUMENTS placeholder...
```

3. Commit and push

## Project-Specific Configuration

Each project can have its own `opencode.json` that:

- Enables/disables specific MCP servers
- Adds project-specific instructions
- Overrides any shared settings

Example `opencode.json` for viya-app:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    ".github/copilot-instructions.md",
    "docs/frontend-guidelines/frontend-guidelines.md"
  ],
  "mcp": {
    "notion": { "enabled": true },
    "chrome-devtools": {
      "type": "local",
      "command": ["npx", "-y", "chrome-devtools-mcp@latest"]
    }
  }
}
```

## Troubleshooting

### Skills not showing up

1. Verify environment variables are set:
   ```bash
   echo $OPENCODE_CONFIG_DIR
   echo $OPENCODE_CONFIG
   ```

2. Restart OpenCode after changing shell config

3. Check skill file is named `SKILL.md` (case-sensitive)

### MCP server not connecting

1. Ensure required environment variables are set (e.g., `NOTION_TOKEN`)
2. Enable the server in your project's `opencode.json`
3. Check OpenCode logs for connection errors

### Commands not available

1. Verify `OPENCODE_CONFIG_DIR` points to the ai-knowledgebase directory
2. Commands must have `.md` extension
3. Restart OpenCode after adding new commands
