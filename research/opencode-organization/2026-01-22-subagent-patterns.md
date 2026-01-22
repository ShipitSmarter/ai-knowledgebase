---
topic: Subagent Design Patterns
date: 2026-01-22
project: opencode-organization
sources_count: 6
status: draft
tags: [subagents, agents, design-patterns, opencode]
---

# Subagent Design Patterns

## Summary

Subagents in OpenCode are specialized assistants that primary agents invoke via the Task tool or users invoke via @mentions. Unlike skills (which are loaded instructions) and commands (which are prompt shortcuts), subagents are persistent configurations with their own model, tools, permissions, and system prompt that spawn as isolated child sessions.

The key insight is that **subagents are for delegation**, while **skills are for knowledge**. A subagent runs in its own session with its own tool restrictions, making it ideal for parallel work or constrained operations. A skill injects instructions into the current session, sharing the same context and tools. Choose subagents when you need isolation (tool restrictions, parallel execution, or different model) and skills when you need the agent to learn a workflow while retaining its full capabilities.

The user's current setup (25+ skills, 1 agent) is appropriate for knowledge-heavy workflows but could benefit from 2-3 specialized subagents for truly parallel research tasks, security-sensitive operations, and read-only exploration.

## Key Findings

1. **Subagents spawn isolated sessions** - Each Task tool invocation creates a child session with its own context window, tool access, and permissions. The primary agent doesn't see the subagent's internal reasoning, only the returned result.

2. **Skills inject into current session** - When an agent loads a skill, the instructions are added to the current context. The agent retains all its tools and continues the same conversation.

3. **Subagent descriptions drive auto-selection** - Primary agents choose which subagent to invoke based on the `description` field. Write descriptions as "when to use" statements, not "what it does" summaries.

4. **Built-in subagents cover most cases** - `general` (full tools except todo) and `explore` (read-only, fast) handle 80%+ of delegation needs. Only create custom subagents when you need specific tool/permission restrictions or a specialized model.

5. **Hidden subagents are for orchestration** - Use `hidden: true` for subagents that should only be invoked by other agents via Task tool, not by users via @mention.

6. **Task permissions control delegation scope** - Use `permission.task` to restrict which subagents an agent can invoke, preventing accidental delegation to wrong specialists.

## Subagent vs Skill Comparison

| Factor | Subagent Better | Skill Better |
|--------|-----------------|--------------|
| **Isolation needed** | Yes - constrained tools/permissions | No - shares current session |
| **Parallel execution** | Yes - multiple Tasks run concurrently | No - sequential loading |
| **Context separation** | Yes - own context window | No - adds to current context |
| **Tool restrictions** | Yes - can limit tools per task | No - inherits agent's tools |
| **Different model** | Yes - can specify cheaper/faster model | No - uses current model |
| **Complex workflow** | Split - subagent runs it isolated | Yes - step-by-step guidance |
| **Reusable knowledge** | No - config only, no detailed instructions | Yes - detailed procedures |
| **User invokable** | Yes - @mention or auto-selection | Yes - via skill tool |
| **Maintainability** | Medium - JSON/MD config | High - markdown procedures |

### Decision Framework

Use a **subagent** when:
- Task can run **in parallel** with other work
- Task needs **different tool access** (read-only, no bash, etc.)
- Task benefits from a **different model** (faster for exploration, smarter for code review)
- Task output is a **discrete result** that feeds back to parent
- You want **isolation** to prevent context pollution

Use a **skill** when:
- Task requires **step-by-step guidance** with user interaction
- Task needs **full context** of current conversation
- Task is **knowledge-based** (how to do X, patterns for Y)
- Task may **branch conditionally** based on findings
- Instructions need **frequent updates** (easier to edit SKILL.md)

## When to Create a Subagent

### Create a Custom Subagent When:

1. **You need specific tool restrictions**
   ```yaml
   # Security auditor - read-only, no writes
   tools:
     write: false
     edit: false
     bash: false
   ```

2. **You want a different model for cost/speed**
   ```yaml
   # Fast exploration with cheaper model
   model: anthropic/claude-haiku-4-20250514
   ```

3. **You need custom permissions**
   ```yaml
   # Only allow specific git commands
   permission:
     bash:
       "*": deny
       "git log*": allow
       "git diff*": allow
   ```

4. **You're orchestrating parallel research**
   - The `deep-research` skill spawns multiple Task agents for subtopic research
   - Each researches independently, returns findings to orchestrator

5. **You want to hide internal implementation details**
   ```yaml
   hidden: true  # Only invokable by other agents via Task tool
   ```

### Use Built-in `general` or `explore` When:

- **`general`**: Full tool access, general-purpose tasks, multi-step work
- **`explore`**: Read-only exploration, finding files, understanding codebase

Most delegation doesn't need custom subagents. The built-ins are sufficient unless you have specific restrictions.

## Description Writing Best Practices

Subagent descriptions determine when primary agents auto-select them. Write for discoverability:

### Good Patterns

```yaml
# Action-oriented, specific triggers
description: "Reviews code for security vulnerabilities and suggests fixes. Use for PR reviews or security audits."

# Clear scope boundaries  
description: "Fast, read-only exploration of codebase structure. Cannot modify files. Use when finding or understanding code."

# Problem-based framing
description: "Investigates flaky tests and CI failures using trace analysis. Use when tests pass locally but fail in CI."
```

### Anti-patterns

```yaml
# Too vague - when would this be selected?
description: "A helpful assistant for various tasks"

# Feature list instead of use case
description: "Has access to bash, write, and edit tools"

# Overlapping scope with other agents
description: "General purpose coding assistant"  # Conflicts with 'general'
```

### Structure Template

```
[What it does] + [When to use it] + [What it cannot do] (optional)
```

Examples:
- "Writes and maintains documentation. Use when creating docs, READMEs, or API references. Does not modify source code."
- "Performs security audits on code changes. Use for reviewing PRs or analyzing dependencies. Read-only access."

## Configuration Patterns

### Tools Configuration

| Pattern | Tools Config | Use Case |
|---------|-------------|----------|
| **Full access** | (default, inherit from parent) | Implementation work |
| **Read-only** | `write: false, edit: false, bash: false` | Analysis, exploration |
| **Bash-restricted** | `bash: false` | File operations only |
| **MCP-restricted** | `mymcp_*: false` | Exclude specific integrations |

Example read-only auditor:
```yaml
---
description: Security auditor - reviews code for vulnerabilities
mode: subagent
tools:
  write: false
  edit: false
  bash: false
---
```

### Permission Profiles

| Profile | Permissions | Use Case |
|---------|------------|----------|
| **Safe defaults** | `edit: ask, bash: ask` | Cautious automation |
| **Git-only bash** | `bash: { "*": deny, "git *": allow }` | Version control tasks |
| **Trusted** | `edit: allow, bash: allow` | Speed over safety |

Example git-only:
```yaml
permission:
  bash:
    "*": deny
    "git status": allow
    "git diff*": allow
    "git log*": allow
```

### Hidden vs Visible

| Setting | Visibility | Use Case |
|---------|-----------|----------|
| `hidden: false` (default) | Shows in @autocomplete | User-invokable specialists |
| `hidden: true` | Hidden from @autocomplete | Internal orchestration helpers |

Use `hidden: true` for:
- Subagents that are only invoked by orchestrator agents
- Internal helpers with sensitive permissions
- Implementation details users shouldn't invoke directly

Example:
```yaml
---
description: Internal helper for parallel research tasks
mode: subagent
hidden: true
---
```

### Task Permissions

Control what subagents an agent can invoke:

```json
{
  "agent": {
    "orchestrator": {
      "permission": {
        "task": {
          "*": "deny",
          "research-*": "allow",
          "explore": "allow"
        }
      }
    }
  }
}
```

Rules are evaluated in order, last match wins.

## Recommendations for User's Setup

### Current State Analysis

| Aspect | Current | Observation |
|--------|---------|-------------|
| Skills | 25+ | Rich knowledge base - appropriate |
| Agents | 1 (research) | Minimal - may be underutilizing subagents |
| Commands | 19 | Mix of skill-loaders and direct prompts |

The research agent is well-designed as a **primary agent** with skill references. However, there are opportunities for subagents.

### Recommended Subagents to Add

#### 1. `security-auditor` (read-only)
```yaml
---
description: Reviews code for security issues and vulnerabilities. Use for PR security reviews or dependency audits. Read-only - cannot modify files.
mode: subagent
tools:
  write: false
  edit: false
  bash: false
---
You are a security specialist. Focus on:
- Input validation vulnerabilities
- Authentication and authorization flaws  
- Data exposure risks
- Dependency vulnerabilities
```

**Rationale**: The `technical-architect` skill could benefit from delegating security reviews to a constrained subagent that can't accidentally modify code.

#### 2. `docs-writer` (limited tools)
```yaml
---
description: Creates and maintains documentation. Use for writing READMEs, API docs, or user guides. Only writes markdown files.
mode: subagent
permission:
  edit:
    "*.md": allow
    "*": deny
---
You are a technical writer. Create clear, comprehensive documentation.
```

**Rationale**: The `docs-writing` skill could be complemented by a subagent that's constrained to only edit markdown files, reducing risk when delegating documentation tasks.

#### 3. `parallel-researcher` (hidden, for deep-research)
```yaml
---
description: Internal agent for parallel research subtopics. Invoked by deep-research orchestrator.
mode: subagent
hidden: true
model: anthropic/claude-haiku-4-20250514
---
Research the assigned subtopic thoroughly. Return findings as JSON summary.
```

**Rationale**: The `deep-research` skill spawns Task agents for subtopic research. A dedicated hidden subagent with a faster/cheaper model would make this more efficient.

### Skills That Should Stay Skills

| Skill | Why Keep as Skill |
|-------|-------------------|
| `technical-architect` | Needs full context, interactive Q&A |
| `browser-debug` | Requires user interaction with browser |
| `codebase-navigation` | Knowledge-based, not task-based |
| `vue-component` | Step-by-step guidance, user decisions |
| `deep-research` | Orchestrates subagents, needs full control |

These skills require interactivity, full context, or orchestration capabilities that would be lost in a subagent's isolated session.

### Configuration Improvements

Add to `.opencode/config.json`:

```json
{
  "agent": {
    "research": {
      "permission": {
        "task": {
          "*": "allow",
          "parallel-researcher": "allow"
        }
      }
    }
  }
}
```

## Sources

| Source | Type | Key Contribution |
|--------|------|------------------|
| [OpenCode Agents Docs](https://opencode.ai/docs/agents/) | Official | Subagent types, configuration options, Task permissions |
| [OpenCode Skills Docs](https://opencode.ai/docs/skills/) | Official | Skill loading mechanism, description requirements |
| User's `agents/research.md` | Internal | Example primary agent with skill references |
| User's `skills/deep-research/SKILL.md` | Internal | Task tool orchestration pattern |
| User's `skills/technical-architect/SKILL.md` | Internal | Complex skill that benefits from context |
| Exploration plan | Internal | Context on current setup analysis |

---

## Open Questions

- [ ] **Context window management** - When a subagent completes, how much of its reasoning is returned to the parent? Full result or summary?
- [ ] **Subagent skill loading** - Can subagents load skills themselves, or is that only for primary agents?
- [ ] **Model inheritance** - If no model specified on subagent, does it inherit from invoking agent or use global default?
