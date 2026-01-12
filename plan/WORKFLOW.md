# AI Knowledgebase Workflow

## Suggested Repository Structure

```
ai-knowledgebase/
├── opencode/                    # OpenCode configurations (IDE-agnostic)
│   ├── plugins/                 # Plugin configurations & guides
│   ├── themes/                  # Custom themes
│   ├── agents/                  # Agent presets & prompts
│   ├── mcp-servers/             # MCP server configurations
│   ├── skills/                  # Custom skills/slash commands
│   └── ide/                     # IDE-specific setups
│       ├── vscode/              # VS Code integration
│       ├── neovim/              # Neovim integration
│       ├── zed/                 # Zed integration
│       ├── jetbrains/           # IntelliJ/PyCharm/etc.
│       └── terminal/            # Pure terminal workflows
├── agents/                      # Generic agent configurations
│   ├── prompts/                 # System prompts and templates
│   ├── configs/                 # Agent configuration files
│   └── examples/                # Working agent examples
├── workflows/                   # Reusable AI workflows
│   ├── coding/                  # Code generation, review, refactoring
│   ├── research/                # Information gathering, summarization
│   └── automation/              # Task automation patterns
├── research/                    # Research notes and findings
│   ├── papers/                  # Paper summaries and notes
│   ├── experiments/             # Experiment logs and results
│   └── benchmarks/              # Performance comparisons
├── ideas/                       # Ideas backlog
│   └── proposals/               # Fleshed-out proposals
├── tools/                       # MCP servers, scripts, utilities
└── plan/                        # Planning documents (you are here)
```

## OpenCode Setup Guide

### Recommended Plugins (from awesome-opencode)

| Category | Plugin | Description |
|----------|--------|-------------|
| **Memory** | opencode-mem | Persistent memory with vector database |
| **Context** | context-analysis | Token usage analysis |
| **Auth** | gemini-auth | Google account authentication |
| **Auth** | antigravity-auth | Free Gemini/Anthropic via Google IDE |
| **Notifications** | opencode-notify | Native OS notifications |
| **Skills** | opencode-skills | Manage skills and capabilities |
| **Workflow** | smart-title | Auto-generate session titles |
| **Safety** | cc-safety-net | Block destructive commands |
| **Background** | background-agents | Async agent delegation |

### Plugin Configuration

Store plugin configs in `opencode/plugins/`:

```jsonc
// opencode/plugins/recommended.jsonc
{
  "plugins": [
    "opencode-mem",           // Persistent memory
    "opencode-notify",        // Desktop notifications
    "opencode-skills",        // Skills management
    "smart-title",            // Auto session titles
    "cc-safety-net"           // Safety guardrails
  ]
}
```

### MCP Server Configurations

Store in `opencode/mcp-servers/`:

```yaml
# opencode/mcp-servers/development.yaml
servers:
  - name: with-context-mcp
    description: Project-specific markdown notes
    repo: boxpositron/with-context-mcp
  - name: filesystem
    description: File system access
    builtin: true
```

### IDE-Specific Configurations

Each IDE folder should contain:

```
opencode/ide/<ide-name>/
├── README.md           # Setup instructions
├── settings.json       # IDE-specific settings
├── keybindings.json    # Keyboard shortcuts
└── tasks.json          # Task runners (if applicable)
```

#### Example: VS Code Setup

```jsonc
// opencode/ide/vscode/settings.json
{
  "terminal.integrated.defaultProfile.linux": "bash",
  "terminal.integrated.env.linux": {
    "OPENCODE_AUTO_START": "true"
  }
}
```

#### Example: Neovim Setup

```lua
-- opencode/ide/neovim/init.lua
-- Terminal integration for opencode
vim.keymap.set('n', '<leader>oc', ':terminal opencode<CR>')
```

### Skills/Commands

Store custom skills in `opencode/skills/`:

```markdown
<!-- opencode/skills/code-review.md -->
# /code-review

Review the current file or selection for:
- Code quality and best practices
- Potential bugs or edge cases
- Performance considerations
- Security vulnerabilities

Output a structured review with severity levels.
```

## Contribution Workflow

### 1. Capture Ideas
- Add quick ideas to `ideas/` as simple markdown files
- Use format: `YYYY-MM-DD-short-title.md`
- Include: problem, proposed solution, potential impact

### 2. Research & Validate
- Move validated ideas to `research/experiments/`
- Document findings, what works, what doesn't
- Link to relevant papers in `research/papers/`

### 3. Build Reusable Workflows
- Extract proven patterns to `workflows/`
- Each workflow should include:
  - Purpose and use case
  - Required tools/models
  - Step-by-step instructions
  - Example inputs/outputs

### 4. Create Agent Configurations
- Production-ready agent setups go to `agents/`
- Include system prompts, tool configs, and usage guides

### 5. Share OpenCode Setups
- Add IDE-specific configs to `opencode/ide/<ide>/`
- Generic configs go to `opencode/` root folders
- Include installation and usage instructions

## Naming Conventions

- Files: `kebab-case.md`
- Directories: `lowercase`
- Dates in filenames: `YYYY-MM-DD`

## Tags/Categories

Use YAML frontmatter for organization:

```yaml
---
tags: [coding, automation, research, opencode]
status: draft | experimental | production
models: [claude, gpt-4, gemini, local]
ide: [vscode, neovim, terminal]
---
```

## Next Steps

1. [ ] Create the directory structure
2. [ ] Add base opencode configuration
3. [ ] Add first IDE-specific setup (pick your primary IDE)
4. [ ] Document recommended plugin stack
5. [ ] Add first workflow example
6. [ ] Add first agent configuration
