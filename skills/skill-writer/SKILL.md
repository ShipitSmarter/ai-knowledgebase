---
name: skill-writer
description: Create and refine Agent Skills following the agentskills.io specification. Use when user asks to write a skill, create a skill, or build automation workflows for AI agents.
---

# Skill Writer

Create well-structured Agent Skills following the [agentskills.io specification](https://agentskills.io/specification). Skills are reusable instruction sets that extend AI agent capabilities with specialized knowledge and workflows.

## Trigger

When user asks to:
- Create a new skill
- Write a skill for a specific workflow
- Build an agent automation
- Document a repeatable process as a skill
- Refine or improve an existing skill

## Core Principles

### 1. Concise is Key

The context window is a shared resource. Every token in your skill competes with conversation history and other context.

**Default assumption**: Claude is already very smart. Only add context Claude doesn't already have.

Challenge each piece of information:
- "Does Claude really need this explanation?"
- "Can I assume Claude knows this?"
- "Does this paragraph justify its token cost?"

### 2. Set Appropriate Degrees of Freedom

Match specificity to the task's fragility:

| Freedom Level | When to Use | Example |
|---------------|-------------|---------|
| **High** (text instructions) | Multiple approaches valid, context-dependent | Code review guidelines |
| **Medium** (pseudocode/templates) | Preferred pattern exists, some variation OK | Report generation |
| **Low** (specific scripts) | Fragile operations, consistency critical | Database migrations |

### 3. Progressive Disclosure

Structure skills so agents load only what they need:

1. **Metadata** (~100 tokens): Name and description loaded at startup
2. **Instructions** (<5000 tokens): Full SKILL.md loaded when activated
3. **Resources** (as needed): Reference files loaded only when required

## Process

### Step 1: Understand the Skill's Purpose

Ask clarifying questions:
- What task or workflow does this skill automate?
- Who is the target user/audience?
- What tools or MCP servers are required?
- Are there existing scripts or templates to bundle?
- What's the expected output or outcome?

### Step 2: Choose the Skill Name

Requirements:
- Max 64 characters
- Lowercase letters, numbers, and hyphens only
- Must not start or end with hyphen
- No consecutive hyphens (`--`)
- Directory name must match skill name

**Naming conventions** (prefer gerund form):
- `processing-pdfs` (gerund - preferred)
- `pdf-processing` (noun phrase - acceptable)
- `process-pdfs` (action-oriented - acceptable)

**Avoid**: `helper`, `utils`, `tools` (too vague)

### Step 3: Write the Description

The description is critical for skill discovery. Claude uses it to select the right skill from potentially 100+ available skills.

Requirements:
- Max 1024 characters
- Non-empty
- **Always write in third person** (not "I can help" or "You can use")
- Include both what the skill does AND when to use it
- Include specific keywords/triggers

**Good example**:
```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Bad example**:
```yaml
description: Helps with documents.
```

### Step 4: Structure the SKILL.md

Use this template:

```markdown
---
name: <skill-name>
description: <what it does and when to use it>
---

# <Skill Title>

<1-2 sentence overview>

## Trigger

When user asks to:
- <trigger 1>
- <trigger 2>

## Process

### Step 1: <First Step>

<Instructions>

### Step 2: <Second Step>

<Instructions>

## Output to User

<What to provide when complete>

## Error Handling

<How to handle failures>
```

### Step 5: Apply Best Practices

**Keep SKILL.md under 500 lines**. Move detailed content to reference files:

```
my-skill/
├── SKILL.md              # Main instructions (<500 lines)
├── references/
│   ├── REFERENCE.md      # Detailed API/technical docs
│   └── EXAMPLES.md       # Extended examples
├── scripts/              # Executable utilities
│   └── validate.py
└── assets/               # Templates, schemas
    └── template.json
```

**Use workflows for complex tasks** with checklists:

```markdown
## Workflow

Copy this checklist:

- [ ] Step 1: Analyze input
- [ ] Step 2: Validate
- [ ] Step 3: Process
- [ ] Step 4: Verify output
```

**Implement feedback loops** for quality:

```markdown
1. Make changes
2. Run validation: `python scripts/validate.py`
3. If errors, fix and repeat step 2
4. Only proceed when validation passes
```

**Provide concrete examples** (input/output pairs):

```markdown
**Example:**
Input: "Update the user model"
Output:
  feat(models): add email validation to User model
```

### Step 6: Handle Optional Features

**For skills with scripts**:
- Scripts should handle errors explicitly (don't punt to Claude)
- Document all "magic constants" with rationale
- List required packages
- Use Unix-style paths (forward slashes)

**For skills using MCP tools**:
- Use fully qualified tool names: `ServerName:tool_name`
- Example: `BigQuery:bigquery_schema`, `notion:search`

**For skills with large reference docs**:
- Add table of contents to files >100 lines
- Keep references one level deep (no nested chains)

### Step 7: Validate the Skill

Quality checklist:

**Core Quality**:
- [ ] Description is specific with keywords
- [ ] Description includes what + when to use
- [ ] SKILL.md body <500 lines
- [ ] No time-sensitive information
- [ ] Consistent terminology
- [ ] Concrete examples (not abstract)
- [ ] File references one level deep
- [ ] Clear workflow steps

**If includes scripts**:
- [ ] Scripts handle errors explicitly
- [ ] No unexplained constants
- [ ] Required packages documented
- [ ] Unix-style paths only

### Step 8: Create the Skill Directory

Create the skill in `.opencode/skill/<skill-name>/`:

```bash
mkdir -p .opencode/skill/<skill-name>
```

Write the SKILL.md file and any additional resources.

## Output to User

After creating a skill, provide:
1. The complete SKILL.md content
2. Directory structure created
3. Summary of what the skill does
4. Any MCP tools or dependencies required
5. Suggested test scenarios

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Too verbose | Wastes context tokens | Assume Claude knows basics |
| Too many options | Confuses the agent | Provide sensible default |
| Vague description | Poor skill discovery | Include specific keywords |
| Windows paths | Cross-platform issues | Always use `/` not `\` |
| Nested references | Partial reads | Keep one level deep |
| Time-sensitive info | Becomes outdated | Use "old patterns" section |
| Magic numbers | Unclear intent | Document all constants |

## Skill Templates by Type

### Workflow Automation Skill

```markdown
---
name: <workflow-name>
description: <Automate X process>. Use when user asks to <trigger>.
---

# <Workflow Name>

## Trigger

When user asks to <action>.

## Prerequisites

- Tool/MCP: <required>
- Access: <required permissions>

## Process

### Step 1: Gather Input
<...>

### Step 2: Execute Workflow
<...>

### Step 3: Verify Results
<...>

## Output to User

<summary of what was done>
```

### Tool Integration Skill

```markdown
---
name: <tool-name>-integration
description: <Integrate with X tool>. Use when user works with <tool>.
---

# <Tool> Integration

## Trigger

When user asks to use <tool> or <related tasks>.

## Setup

<One-time setup instructions>

## Available Operations

| Operation | Command/Tool | Description |
|-----------|--------------|-------------|
| <op1> | `<command>` | <desc> |

## Process

<Step-by-step for common operations>

## Troubleshooting

<Common issues and fixes>
```

### Research/Analysis Skill

```markdown
---
name: <topic>-research
description: <Research X topic>. Use when user asks to research <topic>.
---

# <Topic> Research

## Trigger

When user asks to research <topic> or <related queries>.

## Process

### Step 1: Check Existing Knowledge
<memory/knowledge base search>

### Step 2: Conduct Research
<web search, API calls>

### Step 3: Synthesize Findings
<combine sources>

### Step 4: Create Output
<document template>

## Output Format

<template for research documents>

## Sources

<how to attribute sources>
```

## Reference: Specification Summary

From [agentskills.io/specification](https://agentskills.io/specification):

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | Max 64 chars, lowercase alphanumeric + hyphens |
| `description` | Yes | Max 1024 chars, non-empty |
| `license` | No | License name or file reference |
| `compatibility` | No | Max 500 chars, environment requirements |
| `metadata` | No | Key-value pairs for custom data |
| `allowed-tools` | No | Space-delimited pre-approved tools (experimental) |

**Optional directories**:
- `scripts/` - Executable code
- `references/` - Additional documentation
- `assets/` - Templates, schemas, static resources
