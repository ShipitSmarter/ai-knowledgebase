---
topic: Agent Skills Specification & Best Practices
date: 2026-01-19
project: agent-skills
sources_count: 4
status: final
tags: [agent-skills, ai-agents, automation, opencode, specification]
---

# Agent Skills Specification & Best Practices

## Summary

Agent Skills are a lightweight, open format for extending AI agent capabilities with specialized knowledge and workflows. At its core, a skill is a folder containing a `SKILL.md` file with YAML frontmatter (metadata) and Markdown instructions. The format uses progressive disclosure to manage context efficiently: only metadata is loaded at startup, full instructions when activated, and additional resources on-demand.

The specification is maintained at agentskills.io and supported by multiple AI platforms including Claude Code and OpenCode. Best practices emphasize conciseness (context is a shared resource), appropriate degrees of freedom (match specificity to task fragility), and iterative development with real usage testing.

## Key Findings

1. **Progressive Disclosure Architecture**: Skills load content in stages - metadata (~100 tokens) at startup, SKILL.md body when activated, and reference files only when needed. This keeps agents fast while providing deep context on demand.

2. **Description is Critical for Discovery**: The description field determines whether an agent selects your skill from potentially 100+ available skills. Must include both what the skill does AND when to use it, using specific keywords.

3. **Conciseness Over Completeness**: The context window is a shared resource. Default assumption should be that the AI is smart - only add context it doesn't already have. Keep SKILL.md under 500 lines.

4. **Degrees of Freedom Pattern**: Match instruction specificity to task fragility:
   - High freedom (text guidance) for context-dependent tasks like code review
   - Medium freedom (templates/pseudocode) when preferred patterns exist
   - Low freedom (specific scripts) for fragile operations like migrations

5. **Validation Loops Improve Quality**: For complex tasks, implement feedback loops: make changes → validate → fix errors → repeat. This catches issues early and improves output reliability.

## Detailed Analysis

### Specification Structure

The Agent Skills format requires a minimal directory structure:

```
skill-name/
├── SKILL.md          # Required: frontmatter + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
└── assets/           # Optional: templates, resources
```

#### Required Frontmatter Fields

| Field | Constraints |
|-------|-------------|
| `name` | Max 64 chars, lowercase alphanumeric + hyphens, must match directory name |
| `description` | Max 1024 chars, non-empty, describes what + when to use |

#### Optional Frontmatter Fields

| Field | Purpose |
|-------|---------|
| `license` | License name or file reference |
| `compatibility` | Environment requirements (max 500 chars) |
| `metadata` | Arbitrary key-value pairs |
| `allowed-tools` | Pre-approved tools (experimental) |

### Best Practices Summary

#### Naming Conventions

Prefer gerund form (verb + -ing) for clarity:
- Good: `processing-pdfs`, `analyzing-spreadsheets`
- Acceptable: `pdf-processing`, `process-pdfs`
- Avoid: `helper`, `utils`, `tools` (too vague)

#### Writing Descriptions

**Always use third person** - descriptions are injected into system prompts.

```yaml
# Good
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.

# Bad
description: I can help you process PDF files.
```

#### Content Organization

Keep main SKILL.md focused, move details to reference files:

```markdown
# SKILL.md - Main instructions

## Quick start
[Essential workflow]

## Advanced features
See [REFERENCE.md](references/REFERENCE.md) for API details
See [EXAMPLES.md](references/EXAMPLES.md) for patterns
```

#### Workflow Design

For complex multi-step tasks, provide checklists:

```markdown
## Workflow

Copy this checklist:
- [ ] Step 1: Analyze input
- [ ] Step 2: Validate
- [ ] Step 3: Process
- [ ] Step 4: Verify output
```

### Anti-Patterns to Avoid

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Verbose explanations | Wastes context tokens | Assume agent knows basics |
| Multiple options without default | Confuses decision-making | Provide sensible default |
| Vague descriptions | Poor skill discovery | Include specific trigger keywords |
| Windows-style paths | Cross-platform failures | Always use forward slashes |
| Deeply nested references | Partial file reads | Keep references one level deep |
| Time-sensitive content | Becomes outdated | Use "old patterns" section |

### Integration Approaches

**Filesystem-based agents** (most capable):
- Skills activated when agent reads `SKILL.md` via shell commands
- Full filesystem access enables progressive disclosure
- Scripts executed without loading into context

**Tool-based agents**:
- Implement custom tools for skill activation
- More limited than filesystem approach
- Tool implementation varies by platform

## Sources

| # | Source | Key Contribution |
|---|--------|------------------|
| 1 | [agentskills.io/specification](https://agentskills.io/specification) | Official format specification with field constraints |
| 2 | [agentskills.io/what-are-skills](https://agentskills.io/what-are-skills) | Conceptual overview of progressive disclosure |
| 3 | [agentskills.io/integrate-skills](https://agentskills.io/integrate-skills) | Integration approaches for agents |
| 4 | [Claude Platform Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) | Comprehensive authoring guidance |

### Source Details

1. **[Agent Skills Specification](https://agentskills.io/specification)**
   - Organization: Agent Skills (open standard)
   - Key details: YAML frontmatter requirements, directory structure, validation rules

2. **[What are Skills?](https://agentskills.io/what-are-skills)**
   - Organization: Agent Skills
   - Key concept: Progressive disclosure - metadata at startup, instructions when activated, resources on-demand

3. **[Integrate Skills](https://agentskills.io/integrate-skills)**
   - Organization: Agent Skills
   - Key patterns: Filesystem-based vs tool-based integration approaches

4. **[Skill Authoring Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)**
   - Organization: Anthropic
   - Key guidance: Conciseness principles, degrees of freedom pattern, iterative development with Claude A/B testing, validation checklist

## Questions for Further Research

- [ ] How do skills perform across different model sizes (Haiku vs Sonnet vs Opus)?
- [ ] What's the optimal strategy for skills that need multiple MCP server integrations?
- [ ] How to version skills and handle breaking changes?
- [ ] Best patterns for skill libraries shared across teams/organizations?

## Related Research

- [OpenCode configuration](../../opencode/) - How skills integrate with OpenCode
- [Product Strategy Skill](../../.opencode/skill/product-strategy/SKILL.md) - Example domain-specific skill
- [Research Skill](../../.opencode/skill/research/SKILL.md) - Example workflow skill
