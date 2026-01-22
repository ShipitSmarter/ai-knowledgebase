---
topic: "OpenCode Skills, Agents & Commands - Synthesis & Recommendations"
date: 2026-01-22
project: opencode-organization
sources_count: 6
status: final
tags: [synthesis, recommendations, opencode, skills, agents, commands]
---

# OpenCode Organization - Synthesis & Recommendations

## Executive Summary

This research analyzed the three primary extension mechanisms in OpenCode—Skills, Agents, and Commands—to establish best practices for organizing AI workflows. After examining official documentation and this repository's 23 skills, 19 commands, and 1 agent, we established clear decision frameworks for when to use each mechanism.

**Core insight**: These mechanisms form a hierarchy of abstraction:
- **Commands** = User entry points (shortcuts to prompts)
- **Agents** = Persistent personas with tool/permission configurations
- **Skills** = Reusable knowledge/workflows loaded on-demand

The recommended pattern: **Thin commands load skills, agents define capabilities**. Commands should be lightweight triggers (~10 lines). Detailed instructions belong in skills. Agents define who does the work (with what permissions), while skills define how to do the work.

## Key Findings Across All Subtopics

### 1. Skills vs Agents vs Commands

| Mechanism | Purpose | When to Use |
|-----------|---------|-------------|
| **Command** | User trigger | Frequent actions, argument passing, model/agent routing |
| **Agent** | Persona + permissions | Different tool access, specialized roles, parallel work (subagents) |
| **Skill** | Reusable knowledge | Detailed workflows (>50 lines), cross-agent reusable procedures |

**Anti-pattern**: Commands with 100+ lines of embedded instructions. These are skills masquerading as commands.

### 2. Prompt Location Strategy

| Content Type | Best Location | Rationale |
|--------------|---------------|-----------|
| Agent identity/personality | Agent system prompt | Always active, shapes behavior |
| Detailed workflows | Skill SKILL.md | Loaded on-demand, context efficient |
| Reference material | Skill `references/` folder | Progressive disclosure |
| Quick actions | Command template | Thin trigger with routing |
| Repo context | Config `instructions` | Brief, universal |

**Key insight**: Agent prompts define WHO (identity), skills define HOW (procedures). Skills are lazy-loaded; agents are always-loaded.

### 3. Subagent Design Patterns

| Factor | Use Subagent | Use Skill |
|--------|--------------|-----------|
| Need tool restrictions | Yes | No |
| Parallel execution | Yes | No |
| Different model needed | Yes | No |
| Step-by-step guidance | No | Yes |
| Frequent instruction updates | No | Yes |

**Built-in subagents** (`general`, `explore`) cover 80%+ of delegation needs. Only create custom subagents for specific tool/permission restrictions.

### 4. Skill Organization & Discovery

**Naming patterns**: kebab-case, optionally domain-prefixed (`github-*`, `viya-*`)

**Description formula**: "WHAT it does. WHEN to use it."
- Good: "Writing Playwright E2E tests. Use when creating new tests, debugging failures..."
- Weak: "Manage dev environment" (missing WHEN triggers)

**Size distribution**: 127-1050 lines. Skills >500 lines should extract content to `references/` folder.

**References underutilized**: Only 1 of 23 skills uses `references/`. Opportunity for large skills (pr-review, playwright-test).

### 5. Command-Skill Integration

**Two valid patterns**:
1. **Thin commands** (2 examples): Load skill, brief trigger. Best for complex multi-phase workflows.
2. **Embedded prompts** (17 examples): Complete instructions inline. Best for focused single-purpose operations.

**Hybrid pattern**: Embedded prompts that reference skills for shared context (e.g., "Use the frontend-design skill first").

### 6. Permission Configuration

**Three profiles**:
1. **Full access** (Build): All tools enabled
2. **Planning** (Plan): Tools enabled but require asking
3. **Read-only** (Explore): Modification tools disabled

**Glob patterns** enable fine-grained control: `git *: allow` but `git push: ask`

**Skill permissions** for team governance: `internal-*: deny`

## Consolidated Recommendations

### Immediate Actions

1. **Improve skill descriptions** (2 skills)
   - `designer`: Add WHEN triggers
   - `viya-dev-environment`: Add WHEN triggers and specific use cases

2. **Extract references for large skills** (3 skills)
   - `pr-review` (1050 lines): Extract checklists to `references/`
   - `playwright-test` (640 lines): Extract fixture examples
   - `typescript-helpers` (555 lines): Extract type patterns

3. **Distinguish related skills in descriptions**
   - `research` vs `deep-research`: Clarify when to use each
   - `docs-writing` vs `product-documentation`: Clarify scope differences

### Pattern Decisions

Based on this research, adopt these patterns going forward:

| Pattern | Decision | Rationale |
|---------|----------|-----------|
| Command style | **Keep both** thin and embedded | Each serves valid use cases |
| Skill naming | **Use domain prefixes** for related skills | Aids discovery (github-*, viya-*) |
| Agent creation | **Minimal** - only for different permissions/personas | Built-in agents cover most needs |
| Skill size | **Target 300-500 lines**, use references for more | Balances detail vs context efficiency |
| Subagents | **Use built-in** general/explore; custom only for restrictions | Reduces maintenance |

### Future Considerations

1. **Create `_index.md`** in `skills/` listing all skills with one-line descriptions
2. **Consider skill categories via tags** in frontmatter for filtering
3. **Establish skill versioning** pattern for breaking changes (`skill-v2`)
4. **Monitor the `i-*` commands** - if reuse is needed, refactor to skills

## Decision Flowchart

```
User wants to extend OpenCode behavior
│
├─ Need different tool permissions?
│   └─ YES → Create AGENT with permission config
│
├─ Frequent user-triggered action?
│   └─ YES → Create COMMAND (thin or embedded)
│
├─ Detailed reusable workflow (>50 lines)?
│   └─ YES → Create SKILL
│
├─ Different model for specific tasks?
│   └─ YES → Create AGENT or specify model in COMMAND
│
├─ Parallel execution needed?
│   └─ YES → Create SUBAGENT (or use built-in general/explore)
│
└─ Simple prompt customization?
    └─ YES → Use COMMAND with $ARGUMENTS
```

## Repository Health Assessment

| Metric | Status | Notes |
|--------|--------|-------|
| Skill count | 23 | Good variety covering research, dev, testing |
| Skill quality | Good | Most follow WHAT+WHEN pattern |
| Command count | 19 | Mix of thin (2) and embedded (17) |
| Agent count | 1 | Appropriate - built-ins cover most needs |
| References usage | Low | Only 1 skill uses references/ |
| Description quality | Mixed | 2 skills need improvement |

## Sources Summary

| Document | Key Contribution |
|----------|------------------|
| 2026-01-22-skills-agents-commands.md | Decision framework, comparison table |
| 2026-01-22-prompt-location-strategy.md | Where to put prompts, context efficiency |
| 2026-01-22-subagent-patterns.md | When subagent vs skill, isolation patterns |
| 2026-01-22-skill-organization.md | Naming conventions, description quality |
| 2026-01-22-command-skill-integration.md | Thin vs embedded patterns |
| 2026-01-22-permission-configuration.md | Permission profiles, glob patterns |

## Open Questions for Future Research

- [ ] How does skill loading affect context window usage quantitatively?
- [ ] Can agents auto-load specific skills on session start?
- [ ] How do other teams organize large skill libraries (100+ skills)?
- [ ] Would skill tagging/categorization improve model auto-selection?
- [ ] Performance comparison: thin command + skill vs embedded command
