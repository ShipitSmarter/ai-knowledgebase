# AI Knowledgebase

**Shared AI tools and instructions for everyone at ShipitSmarter.**

This repository contains ready-to-use AI skills, commands, and settings that work across all our projects. Whether you're writing code, creating documentation, or doing research - these tools help AI assistants understand how we work.

## What Can I Do With This?

| I want to... | Use this |
|--------------|----------|
| Get AI help writing Vue components | The `vue-component` skill knows our patterns |
| Research a topic with sources | `/research <topic>` command |
| Create GitHub issues properly | `github-issue-creator` skill |
| Write product documentation | `/document <topic>` command |
| Analyze competitor ads | `competitive-ads-extractor` skill |

**18 skills** and **4 commands** are included - see the [full list](#available-skills) below.

---

## Getting Started

### Which AI Tool Are You Using?

**OpenCode** (terminal-based AI assistant)
- [Quick setup](#opencode-setup-5-minutes) - Run one command and you're done
- Skills and commands work automatically

**GitHub Copilot** (VS Code / IDE)
- [Setup instructions](#github-copilot-setup) - Requires a manual step per repository
- Only custom instructions are supported (not skills)

**Other AI tools** (ChatGPT, Claude, etc.)
- You can copy content from the `skills/` folder into your prompts manually

---

## OpenCode Setup (5 minutes)

### Automatic Setup (Recommended)

Open your terminal and run:

```bash
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
```

This will:
1. Download this repository to your computer
2. Configure OpenCode to use our shared skills and commands
3. Show you what's available

After it finishes, **restart your terminal** (close and reopen it).

**That's it!** Open any project folder, run `opencode`, and all skills are available.

### Manual Setup

If the automatic setup doesn't work, or you prefer doing it yourself:

**Step 1:** Download this repository

```bash
git clone https://github.com/ShipitSmarter/ai-knowledgebase ~/.shipitsmarter/ai-knowledgebase
```

**Step 2:** Tell OpenCode where to find it

Add these lines to your shell configuration file:
- **Mac/Linux with zsh** (most common): Edit `~/.zshrc`
- **Linux with bash**: Edit `~/.bashrc`

Add at the bottom:
```bash
export OPENCODE_CONFIG_DIR="$HOME/.shipitsmarter/ai-knowledgebase"
export OPENCODE_CONFIG="$HOME/.shipitsmarter/ai-knowledgebase/shared-config.json"
```

**Step 3:** Restart your terminal

Close and reopen your terminal, or run:
```bash
source ~/.zshrc  # or source ~/.bashrc
```

### Verify It Works

Run this to check:
```bash
ls $OPENCODE_CONFIG_DIR/skills
```

You should see a list of skill folders like `vue-component`, `research`, etc.

---

## GitHub Copilot Setup

### Why Is This Different From OpenCode?

GitHub Copilot requires instructions to be inside each repository - it can't read from a central location like OpenCode can. This means you need to copy our shared instructions into each repository where you want to use them.

This is a limitation of how Copilot works, not something we can fix.

### How to Add Copilot Instructions to a Repository

**Option 1: Copy the file (simplest)**

In your terminal, go to your repository folder and run:

```bash
curl -fsSL -o .github/copilot-instructions.md \
  https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/copilot/copilot-instructions.md
```

Then commit the file:
```bash
git add .github/copilot-instructions.md
git commit -m "Add Copilot instructions"
```

**When to update:** Run the curl command again whenever you want the latest instructions.

**Option 2: Automatic weekly updates**

If you want the repository to automatically check for updates, you can add a GitHub Action. See [Advanced: Automated Sync](#advanced-automated-copilot-sync) below.

---

## Available Skills

Skills are detailed instructions that teach AI assistants how to do specific tasks the ShipitSmarter way.

### General Skills

| Skill | What it helps with |
|-------|-------------------|
| `research` | Finding information online and citing sources |
| `product-documentation` | Writing user guides and help articles for Viya |
| `product-strategy` | Creating product strategy documents |
| `github-issue-creator` | Writing clear GitHub issues with the right template |
| `github-issue-tracker` | Updating issues and moving them on project boards |
| `skill-writer` | Creating new skills for this repository |
| `designer` | Working with Penpot designs |
| `competitive-ads-extractor` | Analyzing competitor advertising |

### Development Skills

These are specifically for working on viya-app and similar Vue/TypeScript projects:

| Skill | What it helps with |
|-------|-------------------|
| `vue-component` | Writing Vue 3 components our way |
| `unit-testing` | Writing tests with Vitest |
| `playwright-test` | Writing end-to-end browser tests |
| `api-integration` | Working with our API types and services |
| `typescript-helpers` | TypeScript types and utility functions |
| `codebase-navigation` | Understanding our project structure |
| `docs-writing` | Writing user-facing documentation |
| `github-workflow` | Pull requests and commit messages |
| `pr-review` | Reviewing code |
| `browser-debug` | Debugging browser issues |

### How to Use Skills

In OpenCode, just mention what you want to do - it will often load the right skill automatically.

You can also load a skill explicitly:
```
/skill vue-component
```

Or ask OpenCode to use it:
```
Use the vue-component skill to create a button component
```

---

## Available Commands

Commands are shortcuts that start a specific workflow.

| Command | What it does |
|---------|-------------|
| `/research <topic>` | Research something and create a document with sources |
| `/document <topic>` | Write documentation for a Viya feature |
| `/designer` | Start working with Penpot designs |
| `/product-strategy` | Create a product strategy document |

**Example:**
```
/research MongoDB Atlas pricing for small teams
```

---

## Keeping Up to Date

### OpenCode

Get the latest skills and commands:

```bash
cd ~/.shipitsmarter/ai-knowledgebase && git pull
```

Or use the update script:
```bash
~/.shipitsmarter/ai-knowledgebase/tools/update.sh
```

**Tip:** Do this every few weeks to get new skills and improvements.

### Copilot

Re-run the curl command from the setup instructions to get the latest version.

---

## Adding Your Own Skills

Found yourself explaining the same thing to AI over and over? Turn it into a skill!

### Quick Guide

1. Create a folder: `skills/my-skill-name/`
2. Create a file inside called `SKILL.md`
3. Start with this template:

```markdown
---
name: my-skill-name
description: One sentence explaining when to use this skill
---

# My Skill Name

Explain what this skill helps with.

## When to Use This

- Situation 1
- Situation 2

## How to Do It

Step-by-step instructions...

## Examples

Show examples of good output...
```

4. Test it locally, then submit a pull request

**Need help?** Look at existing skills in the `skills/` folder for inspiration, or use:
```
/skill skill-writer
```

---

## Troubleshooting

### "Skills aren't showing up in OpenCode"

1. Check that the setup worked:
   ```bash
   echo $OPENCODE_CONFIG_DIR
   ```
   Should print: `/Users/yourname/.shipitsmarter/ai-knowledgebase` (or similar)

2. If it's empty, you need to restart your terminal after setup

3. Still not working? Run the setup script again

### "Commands like /research don't work"

Same as above - check `$OPENCODE_CONFIG_DIR` is set and restart your terminal.

### "Copilot isn't following the instructions"

1. Make sure `.github/copilot-instructions.md` exists in your repository
2. The file must be committed (not just saved locally)
3. Try restarting VS Code

### Getting Help

Ask in the team Slack channel, or create an issue in this repository.

---

## Advanced Topics

### What's Actually in This Repository?

```
ai-knowledgebase/
├── skills/                  # AI skill definitions (18 skills)
├── commands/                # Slash command definitions
├── copilot/                 # Copilot instructions to copy to repos
├── shared-config.json       # OpenCode settings (plugins, integrations)
├── research/                # Research documents we've created
└── tools/                   # Setup and update scripts
```

### Advanced: Automated Copilot Sync

If you want a repository to automatically update its Copilot instructions weekly, add this file:

**`.github/workflows/sync-copilot-instructions.yml`**

```yaml
name: Sync Copilot Instructions

on:
  schedule:
    - cron: '0 6 * * 1'  # Every Monday at 6 AM
  workflow_dispatch:      # Allows manual trigger

jobs:
  sync:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Download latest instructions
        run: |
          mkdir -p .github
          curl -fsSL -o .github/copilot-instructions.md \
            https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/copilot/copilot-instructions.md
      
      - name: Create PR if changed
        uses: peter-evans/create-pull-request@v5
        with:
          title: "Update Copilot instructions"
          commit-message: "Update Copilot instructions from ai-knowledgebase"
          branch: update-copilot-instructions
          delete-branch: true
```

This creates a pull request whenever the shared instructions change, so you can review before merging.

### Advanced: Enabling Extra Integrations

Some integrations are available but disabled by default (they need API keys):

| Integration | What it does | How to enable |
|-------------|--------------|---------------|
| Notion | Search our Notion workspace | Set `NOTION_TOKEN` environment variable |
| PostHog | Query analytics data | Set `POSTHOG_API_KEY` environment variable |
| Web Search | Search the internet | Already enabled |

To enable in a specific project, create `opencode.json` in the project root:

```json
{
  "mcp": {
    "notion": { "enabled": true }
  }
}
```

---

## Questions?

- **Something broken?** Create an issue in this repository
- **Want to add a skill?** Pull requests welcome!
- **Not sure how something works?** Ask in the team Slack
