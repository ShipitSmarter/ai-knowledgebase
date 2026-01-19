# AI Knowledgebase

**Central repository for AI skills, commands, and configurations at ShipitSmarter.**

This repository serves as the single source of truth for AI-assisted development tools across all ShipitSmarter projects. It provides shared skills, commands, MCP server configurations, and research documentation.

## Table of Contents

- [Quick Setup](#quick-setup)
- [What's Included](#whats-included)
- [OpenCode Setup](#opencode-setup)
- [GitHub Copilot Setup](#github-copilot-setup)
- [Available Skills](#available-skills)
- [Available Commands](#available-commands)
- [Adding New Skills](#adding-new-skills)
- [Updating](#updating)
- [Repository Structure](#repository-structure)

## Quick Setup

### OpenCode

Run the setup script to configure everything automatically:

```bash
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
```

The script will:
1. Check if OpenCode is installed
2. Clone the ai-knowledgebase to `~/.shipitsmarter/ai-knowledgebase`
3. Configure shell environment variables (`OPENCODE_CONFIG_DIR`, `OPENCODE_CONFIG`)
4. Verify the `opencode-mem` plugin is configured
5. Show available skills and commands

Then restart your terminal or run `source ~/.bashrc` (or `~/.zshrc`).

### Manual Setup

If you prefer manual setup:

```bash
# Clone to standard location
git clone https://github.com/ShipitSmarter/ai-knowledgebase ~/.shipitsmarter/ai-knowledgebase

# Add to your shell config (~/.bashrc or ~/.zshrc)
export OPENCODE_CONFIG_DIR="$HOME/.shipitsmarter/ai-knowledgebase"
export OPENCODE_CONFIG="$HOME/.shipitsmarter/ai-knowledgebase/shared-config.json"
```

## What's Included

| Feature | Description |
|---------|-------------|
| **Skills** | 17 reusable AI skills for common development tasks |
| **Commands** | Slash commands (`/research`, `/document`, etc.) |
| **MCP Servers** | Pre-configured Notion, PostHog, and web search integrations |
| **Plugins** | `opencode-mem` for persistent memory across sessions |
| **Research** | Documented research organized by project |

## OpenCode Setup

OpenCode uses two environment variables to load shared configurations:

| Variable | Purpose |
|----------|---------|
| `OPENCODE_CONFIG_DIR` | Directory containing `skills/`, `commands/`, `agents/` |
| `OPENCODE_CONFIG` | Path to shared `opencode.json` config file |

### How It Works

1. **Shared config** (`shared-config.json`) provides:
   - `opencode-mem` plugin for persistent memory
   - MCP server configurations (disabled by default)

2. **Skills directory** (`skills/`) contains all shared skills

3. **Commands directory** (`commands/`) contains slash commands

4. **Project configs** can override or extend shared settings

### Enabling MCP Servers

MCP servers are disabled by default. Enable them in your project's `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "notion": { "enabled": true },
    "google-ai-search": { "enabled": true }
  }
}
```

**Available MCP servers:**

| Server | Description | Required Env Var |
|--------|-------------|------------------|
| `notion` | Search Notion knowledge base | `NOTION_TOKEN` |
| `google-ai-search` | Web research capabilities | Plugin installed |
| `posthog` | Analytics queries | `POSTHOG_API_KEY` |

## GitHub Copilot Setup

GitHub Copilot doesn't support cross-repository custom instructions natively. Here are the options:

### Option 1: Copy Instructions (Simple)

Copy the instructions file to your repository:

```bash
curl -o .github/copilot-instructions.md \
  https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/copilot/copilot-instructions.md
```

### Option 2: GitHub Actions Sync (Automated)

Add this workflow to automatically sync instructions weekly:

```yaml
# .github/workflows/sync-copilot-instructions.yml
name: Sync Copilot Instructions
on:
  schedule:
    - cron: '0 6 * * 1'  # Weekly on Monday
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Fetch shared instructions
        run: |
          mkdir -p .github
          curl -o .github/copilot-instructions.md \
            https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/copilot/copilot-instructions.md
      - name: Create PR if changed
        uses: peter-evans/create-pull-request@v5
        with:
          title: "chore: sync Copilot instructions"
          commit-message: "chore: sync Copilot instructions from ai-knowledgebase"
          branch: sync-copilot-instructions
```

### Option 3: Organization Instructions (Enterprise)

For Copilot Business/Enterprise, set organization-wide instructions in GitHub.com:
1. Go to Organization Settings > Copilot > Custom Instructions
2. Add your shared instructions

**Note:** Organization instructions only work on GitHub.com, not in IDEs.

## Available Skills

### General Skills

| Skill | Description |
|-------|-------------|
| `github-issue-creator` | Create well-structured GitHub issues with templates |
| `github-issue-tracker` | Track and update issue progress on project boards |
| `research` | Conduct web research with source attribution |
| `skill-writer` | Create new skills following the agentskills.io spec |
| `product-documentation` | Write product documentation |

### Development Skills (from viya-app)

| Skill | Description |
|-------|-------------|
| `vue-component` | Vue 3 component conventions and script order |
| `unit-testing` | Vitest + vue-test-utils test patterns |
| `playwright-test` | E2E test patterns and fixtures |
| `api-integration` | Generated API types and service patterns |
| `typescript-helpers` | TypeScript types, interfaces, and guards |
| `codebase-navigation` | Project structure and file organization |
| `docs-writing` | User-facing documentation style |
| `github-workflow` | PR workflow and commit conventions |
| `pr-review` | Code review patterns and checklists |
| `browser-debug` | Headless browser debugging |

### Using Skills

In OpenCode, skills are automatically available. Load them with:

```
/skill vue-component
```

Or reference them in your prompt and OpenCode will load them automatically.

## Available Commands

| Command | Description |
|---------|-------------|
| `/research <topic>` | Research a topic with source attribution |
| `/document <topic>` | Create documentation |
| `/designer` | Start Penpot design workflow |
| `/product-strategy` | Create product strategy documents |

## Adding New Skills

1. Create a folder: `skills/<skill-name>/`
2. Add `SKILL.md` with YAML frontmatter:

```yaml
---
name: skill-name
description: What it does and when to use it (required)
license: MIT
metadata:
  author: shipitsmarter
  version: "1.0"
---

# Skill Title

Instructions and guidelines...
```

3. Commit and push - team members get it on next `git pull`

See the [skill-writer skill](skills/skill-writer/SKILL.md) or [agentskills.io spec](https://agentskills.io/specification) for details.

## Adding New Commands

1. Create `commands/<command-name>.md`
2. Add frontmatter:

```yaml
---
description: Short description shown in command list
---

Your command template with $ARGUMENTS placeholder...
```

3. Commit and push

## Updating

Pull the latest skills and configurations:

```bash
git -C ~/.shipitsmarter/ai-knowledgebase pull
```

Or use the update script:

```bash
~/.shipitsmarter/ai-knowledgebase/tools/update.sh
```

## Repository Structure

```
ai-knowledgebase/
├── skills/                  # Shared AI skills (17 skills)
│   ├── github-issue-creator/
│   ├── vue-component/
│   └── ...
├── commands/                # Slash commands
│   ├── research.md
│   └── ...
├── shared-config.json       # Shared OpenCode config (MCP servers, plugins)
├── research/                # Research documents by project
│   ├── agent-skills/
│   ├── github-copilot/
│   └── ...
├── tools/
│   ├── setup.sh             # Developer setup script
│   └── update.sh            # Update script
├── docs/
│   └── SETUP.md             # Detailed setup documentation
├── opencode/                # OpenCode documentation and examples
└── workflows/               # Reusable AI workflow patterns
```

## Troubleshooting

### Skills not showing up

1. Verify environment variables:
   ```bash
   echo $OPENCODE_CONFIG_DIR
   echo $OPENCODE_CONFIG
   ```
2. Restart OpenCode after changing shell config
3. Ensure `SKILL.md` is named correctly (case-sensitive)

### MCP server not connecting

1. Check required environment variables are set
2. Enable the server in your project's `opencode.json`
3. Check OpenCode logs for errors

### Commands not available

1. Verify `OPENCODE_CONFIG_DIR` is set correctly
2. Commands need `.md` extension
3. Restart OpenCode after adding commands

## Contributing

1. Fork/clone the repository
2. Create your skill or command
3. Test locally by setting `OPENCODE_CONFIG_DIR` to your clone
4. Submit a PR

## Related Documentation

- [Detailed Setup Guide](docs/SETUP.md)
- [OpenCode Documentation](https://opencode.ai/docs/)
- [Agent Skills Specification](https://agentskills.io/specification)
