# OpenCode Organization Research

Research project exploring how to optimally organize skills, agents, and commands in OpenCode.

## Status: Complete

Research completed 2026-01-22.

## Documents

| Document | Description |
|----------|-------------|
| [Exploration Plan](./2026-01-22-exploration-plan.md) | Initial discovery and subtopic planning |
| [Skills vs Agents vs Commands](./2026-01-22-skills-agents-commands.md) | Decision framework for choosing between mechanisms |
| [Prompt Location Strategy](./2026-01-22-prompt-location-strategy.md) | Where to put prompts for context efficiency |
| [Subagent Design Patterns](./2026-01-22-subagent-patterns.md) | When to use subagents vs skills |
| [Skill Organization & Discovery](./2026-01-22-skill-organization.md) | Naming conventions and description quality |
| [Command-Skill Integration](./2026-01-22-command-skill-integration.md) | Thin vs embedded command patterns |
| [Permission Configuration](./2026-01-22-permission-configuration.md) | Tool access and permission profiles |
| [**Synthesis**](./2026-01-22-synthesis.md) | Consolidated findings and recommendations |

## Key Takeaways

1. **Commands** are user entry points - keep them thin, load skills for details
2. **Agents** define permissions and personas - use built-ins when possible
3. **Skills** contain reusable knowledge - the primary organizational unit
4. **Pattern**: Thin commands → load skills → agents define capabilities

## Quick Reference

| Need | Create |
|------|--------|
| User shortcut | Command |
| Different permissions | Agent |
| Detailed workflow | Skill |
| Parallel work | Subagent |

## Related

- [skill-writer skill](../../skills/documentation/skill-writer/SKILL.md) - How to write skills
- [OpenCode Docs](https://opencode.ai/docs/) - Official documentation
