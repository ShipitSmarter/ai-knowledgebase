---
topic: Prompt Location Strategy
date: 2026-01-22
project: opencode-organization
sources_count: 7
status: draft
tags: [prompts, organization, best-practices, skills, agents]
---

# Prompt Location Strategy

## Summary

OpenCode provides four distinct locations for prompts: agent system prompts, skill instructions (SKILL.md), command templates, and global config instructions. Each serves a different purpose and has different characteristics. The key insight is that **agents define identity and capabilities**, while **skills provide on-demand specialized workflows** that can be loaded by any agent.

Understanding when to use each location depends on prompt permanence, reusability, and context window efficiency. Agent prompts are always loaded and should be kept concise. Skills are loaded on-demand, making them ideal for detailed workflows that aren't always needed. Commands are thin triggers that invoke agents or skills with specific inputs.

The user's repository demonstrates a well-organized pattern: agents define personas (research specialist), skills provide detailed workflows (research, deep-research), and commands act as quick-start triggers. This separation keeps context windows efficient while enabling sophisticated multi-step workflows.

## Key Findings

1. **Agent prompts define identity, skills define workflows**: An agent's system prompt should establish *who it is* and its general approach (research.md: "You are a research specialist"). Detailed step-by-step workflows belong in skills that can be loaded when needed.

2. **Skills are lazy-loaded, agents are always-loaded**: Agent system prompts consume context in every conversation. Skill content only enters the context when explicitly loaded via the `skill` tool. This makes skills ideal for detailed reference material and multi-step processes.

3. **Commands are triggers, not content**: Commands should be thin - they specify what agent/model to use and provide a brief prompt. The heavy lifting should happen in skills. Example: `/deep-research` is just 6 lines that says "Load the deep-research skill and begin Phase 1".

4. **Reference folders extend skill context**: Skills can include `reference/` folders with supplementary content (see frontend-design with 7 reference files). These provide domain knowledge without cluttering the main SKILL.md.

5. **Prompt composition is additive**: When an agent loads a skill, both prompts are active. The agent prompt provides personality/constraints, while the skill provides specific methodology. This layering allows reuse - one skill can work with multiple agents.

6. **Global instructions are minimal**: Config `instructions` should be very brief - just enough to establish repo context. Example: "This is the AI knowledgebase repository... use /research skill for research."

## Prompt Location Decision Matrix

| Scenario | Location | Rationale |
|----------|----------|-----------|
| Agent identity/personality | Agent `prompt` field | Always needed, shapes all interactions |
| Always-active constraints | Agent `prompt` field | Must apply to every response |
| Detailed multi-step workflow | Skill SKILL.md | Loaded only when needed, keeps context efficient |
| Domain reference material | Skill `reference/` folder | Supplements skill without cluttering main instructions |
| Quick command shortcut | Command markdown | Thin trigger to invoke agent/skill combo |
| Repo-wide context | Config `instructions` | Brief, applies to all agents |
| Reusable across agents | Skill SKILL.md | Any agent can load any skill |
| Template with variables | Command markdown | Supports $ARGUMENTS and !`shell` |

## Detailed Analysis

### Agent System Prompts

Agent prompts define the agent's identity, capabilities, and any constraints that should *always* apply. They are loaded at the start of every conversation.

**Location options:**
- Inline in agent frontmatter: Good for short prompts
- File reference `{file:./prompts/x.txt}`: Better for longer prompts, enables sharing

**User's example (research.md):**
```markdown
You are a research specialist. Your role is to conduct thorough, 
well-sourced research and organize findings systematically.

## Research Approach
1. Check existing knowledge first
2. Gather new information
3. Synthesize and organize
4. Store for future recall
```

This is a good length for an agent prompt - establishes identity and general approach (~61 lines) without detailed step-by-step instructions.

**Best practices:**
- Keep under ~100 lines to minimize context overhead
- Focus on "who you are" and "what you value", not "exactly how to do X"
- Reference available skills so the agent knows what it can load
- Use file reference for prompts shared across agents

### Skill Instructions (SKILL.md)

Skills are the primary location for detailed workflows. They're discovered at startup but only loaded into context when an agent calls `skill({ name: "..." })`.

**Structure:**
```
skills/<name>/
  SKILL.md          # Main instructions (required)
  reference/        # Optional supplementary content
    template.md
    examples.md
```

**User's research skill example:**
- 209 lines of detailed step-by-step workflow
- Includes tool examples, templates, error handling
- Would be wasteful to load for non-research conversations

**User's frontend-design skill example:**
- 127 lines of design principles
- 7 reference files for typography, color, motion, etc.
- References loaded as needed: `→ *Consult [typography reference](reference/typography.md)*`

**Best practices:**
- Put detailed workflows here, not in agent prompts
- Use `reference/` folders for supplementary content
- Include concrete examples and templates
- Document when the skill should be used ("Trigger" section)
- Keep the main SKILL.md focused; split into references if >300 lines

### Command Templates

Commands are thin triggers that send a specific prompt to the LLM. They can specify which agent and model to use.

**User's example (deep-research.md):**
```markdown
---
description: Start a deep research exploration on a topic
---

Load the `deep-research` skill and begin Phase 1 (Discovery) for the specified topic.
```

This is ideal - the command is just 6 lines. All the actual workflow lives in the skill.

**User's Impeccable commands (i-critique.md):**
```markdown
---
name: i-critique
description: Evaluate design effectiveness from a UX perspective...
---

**First**: Use the frontend-design skill for design principles and anti-patterns.

## Design Critique
[... detailed critique process ...]
```

This command is longer (~118 lines) because it adds critique-specific process on top of the skill. This is valid when the command adds unique workflow.

**Best practices:**
- Commands should be thin triggers when possible
- Use `agent:` frontmatter to specify which agent handles it
- Support arguments with `$ARGUMENTS` or `$1`, `$2`
- Can include shell output with `!`backtick syntax`
- Can reference files with `@path/to/file`

### Shared/Reusable Prompts

**Pattern 1: Skills for cross-agent reuse**
Any agent can load any skill. The research skill works equally well from the Build agent or a custom Research agent.

**Pattern 2: File references for shared agent prompts**
```json
{
  "agent": {
    "build": { "prompt": "{file:./prompts/shared-base.txt}\n\n## Build-specific..." },
    "plan": { "prompt": "{file:./prompts/shared-base.txt}\n\n## Plan-specific..." }
  }
}
```

**Pattern 3: Reference folders for domain knowledge**
The frontend-design skill's `reference/` folder contains domain knowledge that could theoretically be used by multiple skills.

### Context Window Considerations

**Always loaded (minimize):**
- Agent system prompt
- Config `instructions`
- Tool descriptions (including skill list)

**Loaded on-demand (can be detailed):**
- Skill SKILL.md content (only when `skill()` called)
- Skill reference files (manually referenced)
- Command template (only when `/command` invoked)

**Efficiency strategy:**
1. Keep agent prompts focused on identity (~50-100 lines)
2. Put detailed workflows in skills
3. Use reference folders for supplementary content
4. Make commands thin triggers that load skills

**Example from user's setup:**
- research.md agent: 61 lines (always loaded)
- research SKILL.md: 209 lines (only when doing research)
- deep-research SKILL.md: 516 lines (only for deep research)

Total potential: 786 lines, but a typical non-research conversation only loads 61 lines.

## Recommendations for User's Setup

### Current Setup (Good)

The user's organization is well-structured:
- **agents/research.md** - Correctly focused on identity and general approach
- **skills/research/** - Detailed workflow loaded on-demand
- **skills/deep-research/** - Extended workflow for complex research
- **commands/deep-research.md** - Thin trigger

### Suggested Improvements

1. **Add reference folders to research skills**: The research and deep-research skills could benefit from reference files:
   ```
   skills/research/
     SKILL.md
     reference/
       document-template.md
       source-quality-criteria.md
   ```

2. **Consider extracting shared patterns**: Both research and deep-research have similar source quality criteria and document templates. These could live in a shared reference.

3. **Review agent prompt length**: The research.md agent prompt (61 lines) is reasonable, but the "Skills Available" section at the end could be removed - the agent will see available skills in the tool description.

4. **Command pattern**: The `/deep-research` command pattern is ideal. Consider adding `/research` as well for consistency.

### When to Create New Skills vs Agents

**Create a new SKILL when:**
- You have a detailed workflow that's only sometimes needed
- The workflow could be useful to multiple agents
- The content is >100 lines

**Create a new AGENT when:**
- You need different tool permissions (e.g., read-only auditor)
- You need a distinct personality/approach
- You want a separate context (subagent for parallel work)

**User's setup correctly:**
- Has ONE research agent with a focused prompt
- Has TWO research skills (research, deep-research) for different complexity levels
- Skills are reusable by other agents if needed

## Sources

| # | Source | Key Contribution |
|---|--------|------------------|
| 1 | [OpenCode Skills Docs](https://opencode.ai/docs/skills) | Official skill structure, frontmatter, discovery |
| 2 | [OpenCode Agents Docs](https://opencode.ai/docs/agents) | Agent types, prompt options, file references |
| 3 | [OpenCode Commands Docs](https://opencode.ai/docs/commands) | Command syntax, arguments, shell output |
| 4 | User's agents/research.md | Real-world agent prompt pattern |
| 5 | User's skills/research/SKILL.md | Real-world skill structure |
| 6 | User's skills/deep-research/SKILL.md | Complex skill with multi-phase workflow |
| 7 | User's skills/frontend-design/SKILL.md | Skill with reference folder pattern |

## Questions for Further Research

- [ ] How do permissions interact when a skill instructs the agent to use tools the agent doesn't have access to?
- [ ] What's the optimal balance between skill granularity (many small skills vs few large skills)?
- [ ] How do teams coordinate skill development across multiple repositories?
- [ ] Should reference folders use absolute or relative paths for cross-skill references?
