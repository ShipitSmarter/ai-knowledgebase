# OpenCode Skills

Documentation for skills used in this repository.

## Available Skills

| Skill | Description | Location |
|-------|-------------|----------|
| `research` | Conduct online research with source attribution | `.opencode/skill/research/SKILL.md` |

## How Skills Work

Skills are reusable instructions that OpenCode can load on-demand. They're discovered automatically from:

- `.opencode/skill/<name>/SKILL.md` (project-local)
- `~/.config/opencode/skill/<name>/SKILL.md` (global)

## Using Skills

OpenCode will automatically see available skills and can load them when relevant. You can also explicitly request a skill:

```
Use the research skill to investigate <topic>
```

## Creating New Skills

1. Create a directory: `.opencode/skill/<skill-name>/`
2. Add `SKILL.md` with required frontmatter:

```markdown
---
name: skill-name
description: Brief description (1-1024 chars) for agent to understand when to use
---

# Skill Content

Instructions for the agent...
```

### Naming Rules

- 1-64 characters
- Lowercase alphanumeric with single hyphens
- Must match directory name
- Examples: `research`, `code-review`, `git-release`

## See Also

- [OpenCode Skills Documentation](https://opencode.ai/docs/skills/)
- [Research Agent](../agents/research-agent.md) - Uses the research skill
