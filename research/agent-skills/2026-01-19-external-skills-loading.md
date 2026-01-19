---
topic: Loading Skills from External/Central Repositories
date: 2026-01-19
project: agent-skills
sources_count: 6
status: final
tags: [opencode, skills, configuration, shared-skills, external-repository]
---

# Loading Skills from External/Central Repositories

## Summary

OpenCode provides several mechanisms for loading skills from locations outside the current project repository. The primary methods are: (1) global config directory at `~/.config/opencode/skills/`, (2) the `OPENCODE_CONFIG_DIR` environment variable for custom directories, and (3) Claude-compatible paths at `~/.claude/skills/`. However, **OpenCode does not natively support loading skills from URLs or remote repositories** - skills must exist on the local filesystem.

For organizations needing centralized skill sharing, the recommended approaches are: using symlinks/Git submodules to sync a shared repository, the `OPENCODE_CONFIG_DIR` environment variable pointing to a cloned repo, or the third-party **opencode-skillful** plugin which provides enhanced skill discovery across multiple configurable paths.

## Key Findings

1. **Local Filesystem Only**: OpenCode skills must exist on the local filesystem. There is no built-in support for loading skills from URLs, npm packages, or remote Git repositories directly.

2. **Global Config Directory**: Skills placed in `~/.config/opencode/skills/*/SKILL.md` are available across all projects - this is the simplest path for personal skill sharing across repos.

3. **OPENCODE_CONFIG_DIR Environment Variable**: Specifies a custom config directory that is searched for skills, agents, commands, and plugins. This is the most flexible built-in mechanism for external skill loading.

4. **Hierarchical Discovery**: OpenCode walks up from the current working directory to the git worktree root, loading skills from `.opencode/skills/` and `.claude/skills/` directories found along the way.

5. **opencode-skillful Plugin**: A community plugin (`@zenobius/opencode-skillful`) that provides configurable `basePaths` for skill discovery from multiple directories, with lazy loading and per-model format configuration.

6. **Enterprise Central Config**: OpenCode Enterprise supports organizational config via `.well-known/opencode` endpoint, allowing centralized MCP servers and settings - but this is primarily for enterprise deployments.

## Native OpenCode Skill Discovery

### Skill File Locations

OpenCode searches these locations for `SKILL.md` files:

| Location | Scope | Priority |
|----------|-------|----------|
| `.opencode/skills/<name>/SKILL.md` | Project | High |
| `~/.config/opencode/skills/<name>/SKILL.md` | Global | Medium |
| `.claude/skills/<name>/SKILL.md` | Project (Claude-compatible) | High |
| `~/.claude/skills/<name>/SKILL.md` | Global (Claude-compatible) | Medium |

**Note**: Project-level skills override global skills with the same name.

### Directory Walking

For project-local paths, OpenCode walks **up** from the current working directory until it reaches the git worktree root. It loads matching skills from:
- `.opencode/skills/*/SKILL.md`
- `.claude/skills/*/SKILL.md`

This means skills in parent directories are also discovered, enabling monorepo structures with shared skills.

### OPENCODE_CONFIG_DIR for External Paths

The `OPENCODE_CONFIG_DIR` environment variable is the key mechanism for loading skills from outside the standard locations:

```bash
export OPENCODE_CONFIG_DIR=/path/to/shared-skills-repo
opencode
```

This directory is searched for:
- `agents/`
- `commands/`
- `modes/`
- `plugins/`
- `skills/`
- `tools/`
- `themes/`

**Use case**: Point to a cloned Git repository containing team-shared skills:

```bash
# Clone shared skills repo
git clone https://github.com/myorg/opencode-skills ~/.opencode-shared-skills

# Configure OpenCode to use it
export OPENCODE_CONFIG_DIR=~/.opencode-shared-skills
```

## Workarounds for Shared Skills

Since OpenCode doesn't natively support remote skill loading, here are practical patterns:

### 1. Git Submodule Approach

```bash
# In your project
git submodule add https://github.com/myorg/shared-skills .opencode/skills-shared

# Create symlink
ln -s .opencode/skills-shared/skills/* .opencode/skills/
```

### 2. Symbolic Links to Shared Directory

```bash
# Create global shared skills directory
mkdir -p ~/.config/opencode/skills

# Symlink from a shared repo
ln -s ~/repos/team-skills/code-review ~/.config/opencode/skills/code-review
```

### 3. Git Clone + OPENCODE_CONFIG_DIR

```bash
# Clone shared repository
git clone https://github.com/myorg/opencode-skills ~/.opencode-shared

# In your .bashrc or .zshrc
export OPENCODE_CONFIG_DIR=~/.opencode-shared
```

### 4. Mise/asdf Task for Syncing

If using mise, create a task to sync shared skills:

```bash
# mise.toml
[tasks.sync-skills]
run = "git -C ~/.opencode-shared pull"
```

## opencode-skillful Plugin

The [opencode-skillful](https://github.com/zenobi-us/opencode-skillful) plugin provides enhanced skill management with configurable paths:

### Installation

```json
{
  "plugins": ["@zenobius/opencode-skillful"]
}
```

### Configuration

Create `.opencode-skillful.json`:

```json
{
  "basePaths": [
    "~/.config/opencode/skills",
    ".opencode/skills",
    "~/repos/shared-skills"
  ],
  "promptRenderer": "xml",
  "modelRenderers": {
    "claude-3-5-sonnet": "xml",
    "gpt-4": "json"
  }
}
```

### Key Features

| Feature | Description |
|---------|-------------|
| **Multiple Base Paths** | Configure any number of directories to scan for skills |
| **Lazy Loading** | Skills loaded on-demand via `skill_use` command, not pre-loaded |
| **Search-Based Discovery** | Use `skill_find` to search across all paths |
| **Format Optimization** | Different output formats per model (XML/JSON/Markdown) |
| **Resource Access** | Access skill resources via `skill_resource` command |

### Tools Provided

- `skill_find "query"` - Search for skills by keyword
- `skill_use "skill_name"` - Load a skill into context
- `skill_resource skill_name="x" relative_path="y"` - Read specific resource

This plugin is the most flexible option for teams needing centralized skill repositories with complex discovery requirements.

## Enterprise Configuration

For organizations using OpenCode Enterprise, central configuration is available via:

1. **Remote Config**: Organizations can provide defaults via `.well-known/opencode` endpoint
2. **SSO Integration**: Authentication through existing identity systems
3. **Central Config**: Single config file for entire organization

This primarily handles MCP servers, providers, and settings - not skill sharing directly. However, the central config could set `OPENCODE_CONFIG_DIR` or enable specific plugins organization-wide.

## Comparison of Approaches

| Approach | Pros | Cons |
|----------|------|------|
| **Global ~/.config/opencode/skills** | Simple, built-in | Single location, manual sync |
| **OPENCODE_CONFIG_DIR** | Flexible, built-in | Single extra directory only |
| **Git Submodules** | Version controlled | Complex setup, sync overhead |
| **Symlinks** | Simple, immediate | Fragile, platform-specific |
| **opencode-skillful plugin** | Multiple paths, lazy loading, search | Third-party, additional dependency |
| **Enterprise Central Config** | Organization-wide | Requires enterprise tier |

## Recommendations

### For Individual Developers

Use `~/.config/opencode/skills/` for personal skills that should be available in all projects. Symlink specific skills from other repositories as needed.

### For Small Teams

1. Create a shared Git repository for team skills
2. Clone it to a known location (e.g., `~/.opencode-shared/`)
3. Set `OPENCODE_CONFIG_DIR` in team shell profiles
4. Use a sync script or git alias to keep updated

### For Organizations

Consider the `opencode-skillful` plugin for:
- Multiple skill sources (vendor + internal + personal)
- Search-based discovery across large skill libraries
- Lazy loading to reduce context consumption

## What's NOT Supported

- **Remote URLs**: Cannot specify `https://github.com/...` directly in config
- **npm Packages for Skills**: Skills aren't loaded from npm (plugins can be, but not skills themselves)
- **Dynamic Remote Loading**: No runtime fetching from remote sources
- **Skill Registries**: No centralized skill marketplace or registry

## Sources

| # | Source | Key Contribution |
|---|--------|------------------|
| 1 | [OpenCode Skills Docs](https://opencode.ai/docs/skills/) | Skill file locations, discovery mechanism |
| 2 | [OpenCode Config Docs](https://opencode.ai/docs/config/) | OPENCODE_CONFIG_DIR, config precedence |
| 3 | [opencode-skillful GitHub](https://github.com/zenobi-us/opencode-skillful) | Plugin architecture, configurable basePaths |
| 4 | [OpenCode Plugins Docs](https://opencode.ai/docs/plugins/) | Plugin loading, npm packages |
| 5 | [OpenCode Ecosystem](https://opencode.ai/docs/ecosystem/) | Community plugins list |
| 6 | [OpenCode Enterprise Docs](https://opencode.ai/docs/enterprise/) | Central config for organizations |

## Questions for Further Research

- [ ] Can OpenCode plugins register new skill discovery mechanisms?
- [ ] How to handle skill version conflicts across multiple sources?
- [ ] Best practices for skill dependency management (skill A requires skill B)?
