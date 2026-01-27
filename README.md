# AI Knowledgebase

**Shared AI tools and instructions for everyone at ShipitSmarter.**

This repository contains ready-to-use AI skills, commands, and settings that work across all our projects. Whether you're writing code, creating designs, doing research, or building product strategy - these tools help AI assistants understand how we work.

---

## Quick Setup (2 minutes)

### Global Install (all projects)

```bash
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
```

Restart your terminal. **Done!** All skills and commands now work in any project folder.

### Local Install (organization repos only)

Use this if you want skills only in ShipitSmarter repos, not personal projects:

```bash
# Install to custom directory (no global symlinks)
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash -s -- --local

# Or specify exact location
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash -s -- --local --dir ~/Developer/shipitsmarter/ai-knowledgebase
```

Default paths when using `--local` without `--dir`:
- **macOS**: `~/Developer/shipitsmarter/ai-knowledgebase`
- **Linux**: `~/git/shipitsmarter/ai-knowledgebase`

Then enable per-repo using one of these methods:

**Option A: direnv (automatic)**
```bash
# Install direnv: brew install direnv
# Add to shell: eval "$(direnv hook zsh)"  # or bash

# In each ShipitSmarter repo:
cp ~/Developer/shipitsmarter/ai-knowledgebase/.envrc.template .envrc
direnv allow
```

**Option B: Shell alias**
```bash
# Add to ~/.zshrc or ~/.bashrc:
alias oc-ship='OPENCODE_CONFIG_DIR="$HOME/Developer/shipitsmarter/ai-knowledgebase" opencode'

# Then use oc-ship instead of opencode in ShipitSmarter repos
```

**Safety features included:**
- Blocks all `kubectl` commands (prevent accidental cluster changes)
- Asks before git operations (commit, push, pull, rebase, etc.)
- Allows safe git reads (status, log, diff)

---

## Recommended Workflow

Our recommended workflow for building features with AI assistance:

```
Research → Plan → Architect Review → Build → Code Review → Improve
```

| Step | Agent/Tool | What happens |
|------|------------|--------------|
| **Research** | `research` agent | Gather context, explore options, cite sources |
| **Plan** | Default agent | Break down the work, create implementation plan |
| **Architect Review** | `architect` agent | Critical review of the plan - simplicity, trade-offs, risks |
| **Build** | `frontend` agent (or default) | Implement in phases, check work between each phase |
| **Code Review** | `reviewer` agent | Strict review - tests, types, patterns. Missing tests = blocked. |
| **Improve** | `retro` agent | If unhappy with results, analyze what went wrong |

**After a retro:** Use `@ai-coordinator` to implement learnings into skills/agents/commands.

**Tip:** For frontend work, the `frontend` agent has access to both viya-app and viya-ui-warehouse.

---

## Getting Started by Role

| Role | Guide |
|------|-------|
| **Designer** | [AI Tools for Designers](docs/getting-started/designers.md) - Frontend design, UI quality commands |
| **Engineer** | [AI Tools for Engineers](docs/getting-started/engineers.md) - Vue, testing, GitHub workflow |
| **Analyst / Integration Specialist** | [AI Tools for Analysts](docs/getting-started/analysts.md) - Carrier data, troubleshooting |
| **Product** | [AI Tools for Product](docs/getting-started/product.md) - Strategy, documentation, user research |
| **Research** | [AI Tools for Research](docs/getting-started/research.md) - Finding information, citing sources |

---

## What's Included

### Skills (20 total)

Skills teach AI how to do specific tasks the ShipitSmarter way.

**General:**
| Skill | What it helps with |
|-------|-------------------|
| `research` | Finding information online and citing sources |
| `product-documentation` | Writing user guides for Viya |
| `product-strategy` | Creating strategy documents (Playing to Win) |
| `github-issue-creator` | Writing clear, focused GitHub issues |
| `github-issue-tracker` | Updating issues and project boards |
| `skill-writer` | Creating new skills for this repository |
| `designer` | Working with Penpot designs |
| `competitive-ads-extractor` | Analyzing competitor advertising |
| `frontend-design` | Creating distinctive UI that avoids AI slop |
| `github-workflow` | Pull requests and commits |
| `viya-dev-environment` | Managing local dev environment, testing PR builds |

**Frontend Development (viya-app, Vue/TypeScript):**  
*Located in `skills/frontend/`*

| Skill | What it helps with |
|-------|-------------------|
| `vue-component` | Writing Vue 3 components our way |
| `unit-testing` | Writing tests with Vitest |
| `playwright-test` | Writing E2E browser tests |
| `api-integration` | Working with our API types |
| `typescript-helpers` | TypeScript types and utilities |
| `codebase-navigation` | Understanding project structure |
| `docs-writing` | User-facing documentation |
| `pr-review` | Reviewing code |
| `browser-debug` | Debugging browser issues |
| `rates-feature` | Rates module development |

**App Structure (viya-app, viya-ui-warehouse):**  
*Located in `skills/structures/`*

| Skill | What it helps with |
|-------|-------------------|
| `viya-app-structure` | viya-app codebase structure |
| `viya-ui-warehouse-structure` | UI component library structure |

### Commands

Commands are shortcuts that start specific workflows.

**General:**
| Command | What it does |
|---------|-------------|
| `/research <topic>` | Research something and create a sourced document |
| `/document <topic>` | Write Viya user documentation |
| `/designer` | Start working with Penpot designs |
| `/product-strategy` | Create a product strategy document |
| `/test-pr <repo> <pr>` | Test a backend service PR in local dev environment |

**Design Quality (Impeccable):**
| Command | What it does |
|---------|-------------|
| `/i-audit` | Technical quality check (a11y, performance, responsive) |
| `/i-critique` | UX design review (hierarchy, clarity) |
| `/i-polish` | Final pass before shipping |
| `/i-simplify` | Remove unnecessary complexity |
| `/i-bolder` | Amplify boring designs |
| `/i-quieter` | Tone down aggressive designs |
| `/i-animate` | Add purposeful motion |
| `/i-colorize` | Add strategic color |
| `/i-delight` | Add moments of joy |
| `/i-harden` | Add error handling, i18n |
| `/i-optimize` | Improve performance |
| `/i-clarify` | Improve unclear UX copy |
| `/i-extract` | Pull into reusable components |
| `/i-adapt` | Adapt for different devices |
| `/i-onboard` | Design onboarding flows |
| `/i-normalize` | Align with design system |
| `/i-teach-impeccable` | Set up project design context |

### Agents

Agents are specialized personas for different types of work. Select an agent to change how AI approaches your task.

| Agent | What it's for |
|-------|---------------|
| `architect` | Technical planning, architecture reviews, infrastructure decisions. Critical and concise - asks "what's the simplest thing that could work?" |
| `reviewer` | Thorough code review (Vue/TypeScript or C#/.NET). Analyzes full commit history, uncompromising on tests and types, educational feedback. |
| `retro` | Retrospectives on AI-assisted work. Analyzes what went wrong, identifies root causes with Five Whys, proposes improvements to skills/agents/commands. |
| `frontend` | Frontend development specialist for Vue/TypeScript work. Has access to both viya-app and viya-ui-warehouse. |
| `research` | Research tasks without shell access (safer for exploration). |
| `ai-coordinator` | Quality gate for AI automation. `@ai-coordinator` before creating new skills/agents/commands to check for duplicates. Also answers OpenCode questions. |

### Plugins

Plugins extend OpenCode with automatic behaviors.

| Plugin | What it does |
|--------|-------------|
| `session-title` | Automatically names sessions based on your first message using AI. PR reviews become "review PR #123", feature work becomes "feat(scope): description", etc. |

---

## How It Works

### OpenCode (Terminal AI)

After setup, just run `opencode` in any project folder. Skills load automatically based on context.

**Load a skill explicitly:**
```
/skill vue-component
```

**Use a command:**
```
/research MongoDB pricing for small teams
```

### GitHub Copilot (VS Code)

Copilot requires instructions in each repository. Copy our shared instructions:

```bash
curl -fsSL -o .github/copilot-instructions.md \
  https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/copilot/copilot-instructions.md
git add .github/copilot-instructions.md && git commit -m "Add Copilot instructions"
```

---

## Keeping Up to Date

```bash
cd ~/git/ai-knowledgebase && git pull  # or wherever you installed it
```

---

## Repository Structure

```
ai-knowledgebase/
├── .opencode/               # OpenCode project configuration
│   ├── agents -> ../agents  # Symlink to agents
│   ├── commands -> ../commands
│   ├── plugins -> ../plugins
│   ├── skill/               # Individual skill symlinks
│   └── config.json          # OpenCode settings
├── agents/                  # Agent definitions (7 agents)
├── commands/                # Slash commands (21 commands)
├── skills/                  # Skill definitions (33 skills)
│   ├── codebase-structures/ # App structure skills (rates, shipping, viya-app, etc.)
│   ├── design/              # Design skills (designer, frontend-design)
│   ├── documentation/       # Docs skills (docs-writing, skill-writer, etc.)
│   ├── frontend-development/# Vue/TypeScript skills (vue-component, api-integration, etc.)
│   ├── github-workflow/     # GitHub skills (pr-review, issue-creator, etc.)
│   ├── infrastructure/      # Infrastructure skills (mongodb, dev-environment)
│   ├── research-strategy/   # Research & planning skills
│   └── testing/             # Testing skills (unit, playwright, browser-debug)
├── opencode/                # OpenCode ecosystem documentation
│   ├── github/              # GitHub integration docs
│   ├── ide/                 # IDE integration (VSCode, terminal)
│   ├── mcp-servers/         # MCP server configurations
│   └── plugins/             # Plugin documentation
├── copilot/                 # GitHub Copilot instructions
├── docs/
│   ├── getting-started/     # Role-specific guides
│   └── repository-map.md    # All ShipitSmarter repositories explained
├── research/                # Research documents (15 topics)
├── knowledgebase/           # Company context, personas, competitors
├── architecture/            # Architecture decisions
├── architect-reviews/       # Architecture review documents
├── ideas/                   # Feature ideas and proposals
├── plan/                    # Planning documents
├── prompts/                 # Reusable prompt templates
└── tools/                   # Setup and update scripts
```

**Looking for a specific repository?** See the [Repository Map](docs/repository-map.md) for a guide to all ~100 ShipitSmarter GitHub repos.

---

## Contributing

### Add a New Skill

1. Create a folder: `skills/my-skill-name/` (or `skills/frontend/my-skill-name/` for Vue/TypeScript skills)
2. Create `SKILL.md` inside with frontmatter:

```markdown
---
name: my-skill-name
description: One sentence explaining when to use this skill
---

# My Skill Name

Explain what this skill helps with...
```

3. Submit a pull request

**Need help?** Use `/skill skill-writer` for guidance.

---

## Troubleshooting

### "Skills aren't showing up"

**Global install:** Check the symlinks exist:
```bash
ls -la ~/.config/opencode/
```
You should see symlinks for `skills`, `commands`, `agents`, `plugins` pointing to your ai-knowledgebase folder.

**Local install:** Check OPENCODE_CONFIG_DIR is set:
```bash
echo $OPENCODE_CONFIG_DIR
```
Should show your ai-knowledgebase path. If using direnv, run `direnv allow` in the repo.

### "OpenCode won't start" or "Plugin errors"

Reset by running the uninstall script, then reinstall:
```bash
# Uninstall (removes symlinks, keeps your config)
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/uninstall.sh | bash

# Reinstall (global)
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash

# Or reinstall (local)
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash -s -- --local
```

### "Copilot ignores instructions"

1. Ensure `.github/copilot-instructions.md` exists and is committed
2. Restart VS Code

### Verify Setup

Run the setup script with `--verify` to check status:
```bash
./tools/setup.sh --verify
```

---

## Questions?

- Create an issue in this repository
- Ask in the team Slack
- Check the [role-specific guides](#getting-started-by-role) for detailed help
