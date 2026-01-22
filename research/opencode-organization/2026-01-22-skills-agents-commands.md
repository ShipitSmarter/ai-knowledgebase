---
topic: Skills vs Agents vs Commands - Decision Framework
date: 2026-01-22
project: opencode-organization
sources_count: 7
status: draft
tags: [skills, agents, commands, decision-framework, opencode]
---

# Skills vs Agents vs Commands - Decision Framework

## Summary

OpenCode provides three distinct mechanisms for extending AI agent behavior: **Commands**, **Agents**, and **Skills**. Each serves a different purpose in the workflow hierarchy. Commands are user-facing entry points triggered by `/name` that define what to execute, with which agent and model. Agents are persistent personas with configured tool permissions, system prompts, and operating modes (primary vs subagent). Skills are reusable instruction sets loaded on-demand via the `skill` tool that provide specialized workflows without changing the agent's identity.

The mental model follows a hierarchy: Commands trigger → Agents execute → Skills provide instructions. A command is a shortcut that routes work to an agent with a predefined prompt. An agent is a configured persona that persists across the conversation. A skill is a knowledge module that an agent can "read" mid-task to learn how to perform specialized work. The key insight is that commands and agents define *who does the work*, while skills define *how to do the work*.

Understanding when to use each mechanism prevents duplication, reduces maintenance burden, and creates a more ergonomic workflow. The current repository setup (23 skills, 19 commands, 1 agent) suggests skills are the primary organizational unit, with commands serving as quick-access triggers for common workflows.

## Key Findings

1. **Commands are user-facing shortcuts, not knowledge stores** - Commands should be lightweight triggers that route to agents/skills. The `deep-research.md` command (6 lines) exemplifies this: it simply loads a skill and starts a workflow. Commands that embed detailed instructions (like the `i-*` family) are essentially skills masquerading as commands.

2. **Skills are stateless instruction sets; agents are stateful personas** - Skills provide workflow instructions that any agent can follow. The `research` agent demonstrates proper separation: it has its own system prompt defining *personality* and *approach*, while pointing to skills (`research`, `deep-research`) for *detailed procedures*.

3. **The skill tool enables dynamic context loading** - Unlike agents (which are configured at startup) or commands (which run once), skills can be loaded mid-conversation. This allows agents to "learn on demand" without bloating the initial context window.

4. **Tool permissions distinguish agent types more than prompts** - The Plan vs Build agent distinction isn't about different knowledge but different *permissions*. Plan has write/edit/bash set to `ask`, while Build allows them. Skills don't control permissions; agents do.

5. **Commands can specify agent + model, creating flexible routing** - The command `agent: plan` and `model: anthropic/claude-haiku` options allow commands to route work to specific agent/model combinations, which is impossible with skills alone.

6. **Skills have a token budget consideration** - The skill-writer skill emphasizes keeping SKILL.md under 500 lines and using progressive disclosure. Skills are loaded into context, so verbosity has a cost. Agents and commands don't have this constraint.

## Decision Framework

### Quick Reference Table

| Characteristic | Command | Agent | Skill |
|----------------|---------|-------|-------|
| **Entry point** | User-triggered (`/name`) | Tab-switch or `@mention` | `skill()` tool call |
| **Persistence** | Single prompt | Session-long | Loaded on-demand |
| **Context cost** | Low (prompt only) | Fixed (system prompt) | Variable (loaded when needed) |
| **Tool control** | Via agent reference | Yes - permissions | No - inherits from agent |
| **Identity** | N/A | Yes - persona | N/A |
| **Reusability** | Per-project/global | Per-project/global | Per-project/global |
| **Best for** | Quick actions, routing | Specialized personas | Detailed workflows |

### Decision Flowchart

```
START: I want to extend OpenCode behavior
    │
    ├─ Does it need different tool permissions?
    │   └─ YES → Create an AGENT
    │       (e.g., read-only reviewer, restricted planner)
    │
    ├─ Is it a quick trigger for an existing workflow?
    │   └─ YES → Create a COMMAND
    │       (e.g., /deep-research → loads skill)
    │
    ├─ Is it a detailed procedure ANY agent might need?
    │   └─ YES → Create a SKILL
    │       (e.g., vue-component conventions, research workflow)
    │
    ├─ Does it define a persona with a distinct approach?
    │   └─ YES → Create an AGENT
    │       (e.g., security auditor, technical architect)
    │
    ├─ Will the user invoke it frequently by name?
    │   └─ YES → Create a COMMAND (pointing to skill)
    │       (e.g., /test-pr, /i-simplify)
    │
    └─ Is it domain knowledge for specific tasks?
        └─ YES → Create a SKILL
            (e.g., api-integration, playwright-test)
```

### When to Use Each

| Use Case | Mechanism | Rationale |
|----------|-----------|-----------|
| "Run tests with this specific prompt" | Command | Quick user trigger |
| "Always analyze code without changing it" | Agent | Different tool permissions |
| "Here's how to write Vue components" | Skill | Reusable domain knowledge |
| "Start a deep research session" | Command → Skill | Trigger loads detailed workflow |
| "Security-focused code review" | Agent | Distinct persona/perspective |
| "How to create GitHub issues" | Skill | Procedure any agent can follow |
| "Review PR with our conventions" | Command → Agent + Skill | Routes to agent that loads skill |

## Detailed Analysis

### Skills: When and Why

Skills are the right choice when you have **domain knowledge or procedures** that:

1. **Multiple agents might need** - The `vue-component` skill provides conventions any agent (build, plan, or custom) might need when working with Vue files.

2. **Are too detailed for a system prompt** - Skills can be 200-400 lines of detailed instructions. The `deep-research` skill is 516 lines - this would bloat an agent's context.

3. **Are invoked situationally** - The `technical-architect` skill provides a review perspective only needed during planning/design, not every conversation.

4. **Focus on "how" not "who"** - Skills don't have identity. `research` skill teaches how to research; `research` agent IS a researcher.

**Good skill examples from repo:**
- `vue-component` - Coding conventions (loaded when writing components)
- `research` / `deep-research` - Detailed research workflows
- `github-issue-creator` - Step-by-step procedure for creating issues
- `playwright-test` - Testing patterns and fixtures

**Anti-pattern:** Skills that define persona/personality (use agents instead).

### Agents: When and Why

Agents are the right choice when you need:

1. **Different tool permissions** - A read-only "explorer" agent, a restricted "planner" agent.

2. **A persistent persona** - The `research` agent IS a "research specialist" with a specific approach to information gathering. This identity persists across the conversation.

3. **Model override** - Agents can specify a different model. Use a fast model for exploration, a capable model for complex tasks.

4. **Subagent orchestration** - Agents can be `mode: subagent` for parallel work. The Task tool spawns agents, not skills.

**Good agent examples:**
- `research` agent - Specialist persona with defined approach
- Built-in `plan` - Same as build but restricted permissions
- Built-in `explore` - Fast, read-only for codebase exploration

**Anti-pattern:** Agents that are just skill wrappers. If the agent prompt just says "use the X skill", it should probably be a command.

### Commands: When and Why

Commands are the right choice when you need:

1. **User-facing entry points** - Users type `/command`, they don't type `skill({ name: "x" })`.

2. **Quick routing with predefined prompts** - The `test-pr` command is 19 lines that load a skill and provide a specific workflow.

3. **Agent/model overrides for specific tasks** - A command can specify `agent: plan` to use the restricted agent for that specific task.

4. **Argument handling** - Commands support `$ARGUMENTS`, `$1`, `$2` for parameterized prompts.

**Good command patterns:**
- **Thin triggers**: `deep-research.md` (6 lines) - just loads a skill
- **Task-specific routing**: `test-pr.md` - loads skill + specifies workflow
- **Parameterized actions**: Commands with `args` that customize behavior

**Anti-pattern:** Commands with 100+ lines of instructions. That's a skill pretending to be a command.

### Overlaps and Substitutions

**Commands can load skills** - Common pattern. `/deep-research` command loads `deep-research` skill. The command provides the trigger; the skill provides the knowledge.

**Agents can load skills** - The `research` agent mentions it can use `research` and `deep-research` skills. The agent defines the persona; skills provide specialized procedures.

**Commands can specify agents** - `/test-pr` could specify `agent: build` to ensure full tool access. Commands don't have their own permissions.

**Skills can reference other skills** - `skill-writer` references `agentskills.io` spec. The `deep-research` skill spawns Task agents that load the `research` skill.

**What can't be substituted:**
- Only agents can change tool permissions
- Only commands provide `/name` user entry points
- Only skills can be loaded mid-conversation by the `skill()` tool

## Examples from Current Setup

### Good Patterns

| Item | Type | Why It Works |
|------|------|--------------|
| `deep-research.md` command | Command | Thin trigger (6 lines) that loads detailed skill |
| `research` agent | Agent | Distinct persona with skills reference, not duplicated instructions |
| `vue-component` skill | Skill | Detailed domain knowledge any agent might need |
| `technical-architect` skill | Skill | Specialized perspective loaded on-demand |
| `test-pr.md` command | Command | Specific workflow with clear steps, loads skill |

### Questionable Patterns

| Item | Type | Concern | Recommendation |
|------|------|---------|----------------|
| `i-simplify` command | Command | 137 lines of detailed instructions | Extract to skill, make command a trigger |
| `i-critique` command | Command | 118 lines embedding a design review process | Extract to skill, command loads it |
| `i-extract` command | Command | 95 lines of detailed procedure | Same - should be skill + thin command |
| All `i-*` commands | Commands | Detailed instructions in commands | Pattern suggests these should be skills |

The `i-*` family (from Impeccable design system) are essentially skills stored as commands. This works but creates inconsistency: `/deep-research` loads a skill, `/i-simplify` IS the instructions. Recommendation: Create `frontend-design` skill (which exists) and have `i-*` commands load it with specific modes.

### Suggested Refactoring

```
Current: commands/i-simplify.md (137 lines of instructions)
Better:  commands/i-simplify.md (10 lines)
         - Load frontend-design skill
         - Set mode: simplify
         
Current: Single research agent with skills reference
Good:    Keep this pattern for other specialized agents
```

## Sources

| # | Source | Key Contribution |
|---|--------|------------------|
| 1 | [OpenCode Skills Docs](https://opencode.ai/docs/skills/) | Official skill mechanism: on-demand loading, discovery, frontmatter |
| 2 | [OpenCode Agents Docs](https://opencode.ai/docs/agents/) | Primary vs subagent modes, tool permissions, configuration |
| 3 | [OpenCode Commands Docs](https://opencode.ai/docs/commands/) | Command structure, agent/model routing, argument handling |
| 4 | Repository `skills/` folder | 23 real-world skill implementations showing patterns |
| 5 | Repository `commands/` folder | 19 commands showing thin vs thick patterns |
| 6 | Repository `agents/research.md` | Example of agent with skill references |
| 7 | `skills/skill-writer/SKILL.md` | Meta-skill documenting skill best practices |

### Source Details

1. **[OpenCode Skills Documentation](https://opencode.ai/docs/skills/)**
   - Org: Anomaly (OpenCode team)
   - Date: Current (Jan 2026)
   - Key: Skills are loaded via `skill()` tool, discovered from `.opencode/skills/`, `~/.config/opencode/skills/`

2. **[OpenCode Agents Documentation](https://opencode.ai/docs/agents/)**
   - Org: Anomaly (OpenCode team)
   - Date: Current (Jan 2026)
   - Key: Agents have modes (primary/subagent), tool permissions, can override models

3. **[OpenCode Commands Documentation](https://opencode.ai/docs/commands/)**
   - Org: Anomaly (OpenCode team)
   - Date: Current (Jan 2026)
   - Key: Commands are user triggers with optional agent/model routing

4. **Repository Analysis**
   - 23 skills covering research, development, review workflows
   - 19 commands (many embedding detailed instructions - anti-pattern)
   - 1 agent (research) demonstrating persona + skill reference pattern

## Questions for Further Research

- [ ] How do token limits affect skill size in practice? Is 500 lines a hard recommendation?
- [ ] What's the performance difference between skill-per-request vs agent system prompt?
- [ ] How does the opencode-skillful plugin affect skill discovery and sharing?
- [ ] Should the `i-*` commands be refactored to thin triggers + skill, or is current pattern acceptable?
- [ ] How do other teams organize large skill libraries (100+ skills)?
