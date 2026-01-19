# Agent Skills Research

## Overview

Research on the Agent Skills specification and best practices for creating effective skills for AI agents. The Agent Skills format is an open standard for extending AI agent capabilities with specialized knowledge and workflows.

## Documents

| Date | Topic | Status |
|------|-------|--------|
| 2026-01-19 | [Agent Skills Specification & Best Practices](./2026-01-19-agent-skills-best-practices.md) | final |

## Key Insights

- Skills use **progressive disclosure**: metadata loaded at startup, full instructions on activation, resources on-demand
- Keep SKILL.md under 500 lines - move detailed content to reference files
- Description field is critical for discovery - include what AND when to use
- Conciseness matters: assume the agent is smart, only add unique context
- Match instruction specificity to task fragility (high freedom for flexible tasks, low freedom for critical operations)

## Open Questions

- [ ] How to best test skills across different model sizes (Haiku/Sonnet/Opus)?
- [ ] Best patterns for skills that integrate multiple MCP servers?
