---
topic: Command-Skill Integration Patterns
date: 2026-01-22
project: opencode-organization
sources_count: 17
status: draft
tags: [commands, skills, integration, patterns, opencode]
---

# Command-Skill Integration Patterns

## Summary

OpenCode commands and skills serve complementary but distinct roles. Commands are lightweight triggers (slash commands like `/research`) while skills are comprehensive instruction sets with full workflows, error handling, and tool references. Two primary patterns emerge: **thin commands** that simply load a skill, and **embedded prompt commands** that contain complete instructions inline.

Analysis of 19 commands in this repository reveals a clear 2:17 ratio favoring embedded prompts. However, this ratio is misleading - the thin command pattern is used for complex multi-phase workflows (like `deep-research` and `test-pr`) while embedded prompts dominate for focused, single-purpose design operations (the `i-*` Impeccable commands). The choice between patterns depends on workflow complexity, reusability needs, and maintenance considerations.

Both patterns have valid use cases, and the repository demonstrates effective use of each. The key insight is that commands and skills solve different problems: commands optimize for invocation convenience, while skills optimize for instruction completeness and reusability.

## Key Findings

1. **Thin commands are ideal for complex, multi-phase workflows** - When a workflow has multiple phases, error handling, and tool coordination (like `deep-research`), putting it in a skill makes maintenance easier and enables the skill to be loaded by other means (programmatically, via the skill tool).

2. **Embedded prompts work well for focused, single-purpose operations** - The `i-*` commands are self-contained design operations that don't need to be composed or reused elsewhere. Embedding the prompt keeps the command self-documenting and avoids indirection.

3. **Hybrid pattern exists: embedded prompts that reference skills** - Commands like `i-critique`, `i-polish`, and `i-simplify` have embedded prompts but explicitly instruct to "Use the frontend-design skill" first. This combines immediate instructions with shared reference material.

4. **The `subtask: true` option and agents don't affect this pattern** - Neither pattern in the user's commands uses `subtask: true`. This option is for spawning commands as background tasks, orthogonal to whether the command is thin or embedded.

5. **Arguments pass naturally through context** - Both patterns receive arguments via the frontmatter `args` definition. The user prompt following the command includes the argument values, available to both the embedded prompt and any loaded skill.

## Pattern Comparison

### Thin Command Pattern

```markdown
---
description: Start a deep research exploration on a topic
---

Load the `deep-research` skill and begin Phase 1 (Discovery) for the specified topic.
```

**Characteristics:**
- 1-2 sentences of instruction
- Delegates entirely to a skill
- Command is just a convenient trigger
- All logic lives in the skill

**Examples in repo:**
- `deep-research.md` - "Load the `deep-research` skill..."
- `test-pr.md` - "Load the viya-dev-environment skill..."

### Embedded Prompt Pattern

```markdown
---
name: i-simplify
description: Strip designs to their essence by removing unnecessary complexity.
args:
  - name: target
    description: The feature or component to simplify (optional)
    required: false
---

Remove unnecessary complexity from designs, revealing the essential elements...

## MANDATORY PREPARATION
### Context Gathering (Do This First)
...
[100+ lines of detailed instructions]
```

**Characteristics:**
- Complete instructions inline (typically 50-200+ lines)
- Self-contained workflow
- May reference skills for shared context ("Use the frontend-design skill")
- No indirection - what you see is what executes

**Examples in repo:**
- All 17 `i-*.md` commands (i-critique, i-simplify, i-polish, etc.)

### Hybrid Pattern (Embedded + Skill Reference)

```markdown
---
name: i-critique
description: Evaluate design effectiveness from a UX perspective.
---

Conduct a holistic design critique...

**First**: Use the frontend-design skill for design principles and anti-patterns.

## Design Critique
[Detailed instructions follow...]
```

**Characteristics:**
- Has its own complete instructions
- References one or more skills for shared context/principles
- Instructions are specific to this command's purpose
- Skill provides supporting knowledge, not workflow

**Examples in repo:**
- `i-critique.md`, `i-polish.md`, `i-simplify.md`, `i-audit.md` - All reference `frontend-design` skill

### When to Use Each

| Scenario | Pattern | Rationale |
|----------|---------|-----------|
| Multi-phase workflow with state | Thin command | Skill can track phases, handle errors, coordinate tools |
| Complex workflow used in multiple contexts | Thin command | Single source of truth for the workflow |
| Simple, focused operation | Embedded | Self-documenting, no indirection overhead |
| Operation needing shared reference material | Hybrid | Specific instructions + skill for context |
| Workflow with extensive error handling | Thin command | Error handling in skill, not duplicated |
| Quickly iterable prompt | Embedded | Edit one file, not two |
| Operation likely to evolve independently | Embedded | Changes don't affect other consumers |
| Operation that composes with others | Thin command | Other commands can also load the skill |

## Current Setup Analysis

### The `i-*` Commands (Impeccable Design System)

The 17 `i-*` commands form a cohesive design operation toolkit. Each is a self-contained embedded prompt that:

1. **Defines its purpose** clearly in the description
2. **Accepts optional arguments** via frontmatter `args`
3. **References the `frontend-design` skill** for shared design principles (in most cases)
4. **Provides complete workflow** from assessment to implementation to verification

This is the correct pattern for these commands because:
- Each operation is distinct and focused
- They don't need to be invoked programmatically by other commands
- The shared `frontend-design` skill provides the common context
- Keeping instructions inline makes each command self-documenting

### The Thin Commands (`deep-research`, `test-pr`)

These commands delegate to skills because:
- `deep-research` has 4 phases, needs state tracking, spawns parallel agents
- `test-pr` has conditional logic (check build status, construct versions)
- Both workflows might be needed outside the command context

### Naming Conventions

| Convention | Observed Pattern |
|------------|-----------------|
| `i-*` prefix | Impeccable design commands |
| `test-*` prefix | Testing/QA operations |
| Verb-based names | `deep-research` (action-oriented) |
| No prefix | General utility commands |

## Argument Passing

Both patterns handle arguments the same way:

```yaml
args:
  - name: target
    description: The feature or component to simplify
    required: false
  - name: context  
    description: Additional context
    required: false
```

When user types `/i-simplify the checkout flow`, the argument value "the checkout flow" is available in the conversation context. Both embedded prompts and skills receive this naturally - no special passing mechanism needed.

For skills loaded by thin commands, the same applies. The command prompt can contextualize: "Load the `deep-research` skill and begin Phase 1 for the specified topic" - the topic from user input flows through.

## Recommendations

### 1. Keep the current structure for `i-*` commands

The embedded prompt pattern with skill references is appropriate. Don't refactor to thin commands - the indirection adds complexity without benefit since these are self-contained operations.

### 2. Use thin commands for workflows that:
- Have multiple distinct phases
- Need to spawn subtasks or parallel agents  
- Might be invoked programmatically (by other commands/skills)
- Have complex error handling and recovery

### 3. Use the hybrid pattern when:
- The command needs specific instructions but also shared context
- You want to maintain a single source of truth for principles/anti-patterns
- The skill is reference material, not a workflow

### 4. Document the pattern choice

In complex skill systems, consider adding a comment at the top of commands explaining why a pattern was chosen:

```markdown
---
description: Start deep research
---
<!-- Thin command pattern: workflow has 4 phases, spawns parallel agents -->
Load the `deep-research` skill...
```

### 5. Consider creating a command template skill

Given the prevalence of the `i-*` pattern, a skill like `skill-writer` could include templates for command creation with the hybrid pattern.

## Sources

| # | Source | Type | Key Contribution |
|---|--------|------|------------------|
| 1 | `commands/deep-research.md` | Local file | Example of thin command pattern |
| 2 | `commands/test-pr.md` | Local file | Example of thin command with steps |
| 3 | `commands/i-critique.md` | Local file | Example of hybrid pattern (embedded + skill ref) |
| 4 | `commands/i-simplify.md` | Local file | Example of comprehensive embedded prompt |
| 5 | `commands/i-extract.md` | Local file | Example of embedded prompt without skill ref |
| 6 | `commands/i-polish.md` | Local file | Example of detailed embedded workflow |
| 7 | `commands/i-adapt.md` | Local file | Example of context-specific embedded prompt |
| 8 | `commands/i-onboard.md` | Local file | Longest embedded prompt (243 lines) |
| 9 | `commands/i-audit.md` | Local file | Example of hybrid with structured output |
| 10 | `skills/deep-research/SKILL.md` | Local file | Complex multi-phase skill |
| 11 | `skills/research/SKILL.md` | Local file | Simpler research skill for comparison |
| 12 | All 17 `i-*.md` commands | Local files | Pattern analysis dataset |
| 13 | All 23 skills in `skills/` | Local files | Skill complexity comparison |
| 14 | OpenCode documentation | Implied | Command/skill architecture |
| 15 | Prior memory: OpenCode skill loading | Memory | Skills must be on local filesystem |
| 16 | Prior memory: Copilot instructions | Memory | Context on instruction file patterns |
| 17 | `AGENTS.md` | Local file | Repository conventions |

## Questions for Further Research

- [ ] How does the `subtask: true` option work in practice? No examples found in current commands.
- [ ] Can commands target specific agents? If so, how does that affect pattern choice?
- [ ] What's the performance difference between thin commands and embedded prompts?
- [ ] How do other OpenCode users organize their commands and skills?

## Related Research

- [2026-01-22 Exploration Plan](./2026-01-22-exploration-plan.md) - Initial discovery
- [2026-01-19 Agent Skills Research](../agent-skills/) - Skill loading mechanisms
