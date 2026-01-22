---
topic: "OpenCode Skills, Agents & Commands Organization - Exploration Plan"
date: 2026-01-22
project: opencode-organization
sources_count: 8
status: planning
tags: [exploration, opencode, skills, agents, commands, architecture]
---

# OpenCode Skills, Agents & Commands Organization - Exploration Plan

## Discovery Summary

This research explores how to optimally organize skills, agents, and commands in OpenCode. The discovery phase revealed that OpenCode provides three distinct mechanisms for extending AI agent behavior, each with specific purposes and tradeoffs.

**Key insight from discovery**: The three mechanisms form a hierarchy of abstraction:
- **Commands** = User entry points (shortcuts to prompts)
- **Agents** = Persistent personas with tool/permission configurations  
- **Skills** = Reusable knowledge/workflows loaded on-demand

Your current repository already demonstrates sophisticated patterns, with 25+ skills, 19 commands, and 1 agent. The challenge is understanding when to use each and where prompts should live.

### Prior Knowledge Found

- **Memory**: OpenCode skill loading research (2026-01-19) - Skills must be on local filesystem. Key mechanisms include `~/.config/opencode/skills/`, `OPENCODE_CONFIG_DIR`, and git submodules for team sharing.
- **Existing Setup**: Your repo has symlinks from `.opencode/skills` → `skills/`, `.opencode/command` → `commands/`, `.opencode/agent` → `agents/` - good centralized organization.

### Initial Sources Consulted

| Source | Type | Key Insight |
|--------|------|-------------|
| [OpenCode Skills Docs](https://opencode.ai/docs/skills/) | Official | Skills loaded on-demand via native `skill` tool, progressive disclosure (metadata → instructions → resources) |
| [OpenCode Agents Docs](https://opencode.ai/docs/agents/) | Official | Two types: primary (Tab-switch) and subagents (Task tool or @mention). Configure model, tools, permissions per agent |
| [OpenCode Commands Docs](https://opencode.ai/docs/commands/) | Official | Prompt shortcuts with argument placeholders, can target specific agents/models |
| [agentskills.io Specification](https://agentskills.io/specification) | Official | Format standard: SKILL.md with frontmatter, optional scripts/references/assets dirs |
| Your skills/skill-writer/SKILL.md | Internal | Best practices: concise prompts, progressive disclosure, degrees of freedom matching task fragility |
| Your agents/research.md | Internal | Example of agent with tools config, mode, and skill references |
| Your commands/deep-research.md | Internal | Example of thin command that loads a skill |

## Proposed Subtopics

### 1. Skills vs Agents vs Commands - When to Use Each
**Why:** Core architectural question - understanding the right abstraction for each use case prevents duplication and confusion
**Questions to answer:**
- What is the mental model for choosing between them?
- When does knowledge belong in a skill vs embedded in an agent prompt?
- Can commands replace some skill uses or vice versa?

### 2. Prompt Location Strategy
**Why:** Your main question - where should the actual prompts/instructions live?
**Questions to answer:**
- Agent prompt field vs separate SKILL.md vs command template?
- How to share prompts across multiple agents?
- When to use file references (`{file:./prompts/x.txt}`) vs inline?

### 3. Subagent Design Patterns
**Why:** Subagents (via Task tool) enable parallel work and specialization
**Questions to answer:**
- When to create a custom subagent vs use built-in `general`/`explore`?
- How to design subagent descriptions for good auto-selection?
- Subagent vs skill: which is better for specific workflows?

### 4. Skill Organization & Discovery
**Why:** With 25+ skills, discoverability becomes critical
**Questions to answer:**
- How to write descriptions that help the model select the right skill?
- Naming conventions and categorization strategies
- Reference file organization (when to split, how deep)

### 5. Permission & Tool Configuration Patterns
**Why:** Agents differ primarily in what they can do (tools) and what they must ask about (permissions)
**Questions to answer:**
- Standard permission profiles (read-only, full-access, etc.)
- How to configure agents that load skills with different tool needs?
- Glob patterns for bash permissions

### 6. Command-Skill Integration Patterns
**Why:** Your `/deep-research` command loads a skill - is this the recommended pattern?
**Questions to answer:**
- Thin commands that load skills vs commands with full prompts?
- When to use `subtask: true` to run as subagent?
- Argument passing between commands and skills

## Flagged Uncertainties

- [ ] **Skill vs Agent prompt precedence** - When an agent loads a skill, does the skill prompt override, augment, or merge with the agent's system prompt? (Need to verify behavior)
- [ ] **Multiple skill loading** - Can/should an agent load multiple skills in one session? How does that affect context?
- [ ] **Primary agent skill loading** - Can the Build/Plan agents load skills, or only custom agents? (Docs unclear)
- [ ] **Command model override** - If a command specifies a model but targets an agent that also specifies a model, which wins?

## Your Current Setup Analysis

**Strengths:**
1. Centralized skill repository with symlinks - enables team sharing
2. Skills follow agentskills.io spec with proper frontmatter
3. Progressive disclosure used (SKILL.md < 500 lines, references/ folders)
4. Clear separation: commands are thin triggers, skills contain instructions

**Potential issues to investigate:**
1. Only 1 agent defined - could subagents reduce context pollution?
2. Some commands (i-*) seem to be full prompts vs skill loaders - inconsistent pattern?
3. No permission configuration visible - all skills/tools allowed?

## Recommended Research Order

1. **Skills vs Agents vs Commands** - Foundation for all other decisions
2. **Prompt Location Strategy** - Directly answers your question
3. **Subagent Design Patterns** - May reveal better patterns than current setup
4. **Command-Skill Integration** - Clarify the thin-command pattern
5. **Skill Organization & Discovery** - Important for scaling
6. **Permission & Tool Configuration** - Polish for production use

## Next Steps

Awaiting user approval to proceed with subtopic research.

**Options:**
- Approve all 6 subtopics → Parallel research via Task agents
- Remove subtopics you don't need
- Add specific questions you want answered
- Request more discovery on specific areas
