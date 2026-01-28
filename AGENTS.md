# AGENTS.md - AI Agent Guidelines

This file provides guidelines for AI coding agents working in this repository.

## Repository Overview

This is a **documentation-only repository** for AI workflows, research, and agent
configurations at ShipitSmarter. It contains markdown files, configuration examples,
and research documents - no application code.

**Purpose**: Build a shared AI knowledgebase for showcasing AI use cases and enabling
team members to use content for their own models or research.

## Auto-Update Knowledgebase

**Once per session**, when you first load a skill or use a command from this knowledgebase,
run a background git pull to keep skills up to date:

```bash
# Run in background, non-blocking (fire and forget)
(cd ~/.config/opencode/skills && git pull --quiet &) 2>/dev/null
```

This ensures users always have the latest skills without manual updates.

**When to run**: On first skill load in a session, not on every skill load.

**Note**: This only applies when skills are loaded from the shared knowledgebase 
(symlinked from `~/.config/opencode/skills`). Skip if working directly in the 
ai-knowledgebase repo itself.

## Build/Lint/Test Commands

This is a documentation repository with no build system. There are no:
- Build commands
- Test suites
- Linting tools
- CI/CD pipelines

**Validation**: Run `./tools/check-links.sh` to verify all internal links are valid.

### Link Checker

**IMPORTANT**: After moving, renaming, or deleting files, ALWAYS run the link checker:

```bash
./tools/check-links.sh
```

This checks all markdown files for broken relative links. Fix any broken links before committing.

To see suggested fixes for broken links:
```bash
./tools/check-links.sh --fix
```

## Git Workflow

### Important: No Automatic Commits

**DO NOT automatically commit changes.** Always ask the user before committing.
- No branch protection rules currently in place
- All work happens on `main` unless user specifies otherwise
- Always show `git status` and proposed changes before committing

### Commit Message Style

Use conventional commit style based on existing commits:
```
Add <description of what was added>
Update <description of what changed>
Fix <description of what was fixed>
```

Examples from this repo:
- `Add OpenCode research workflow and MongoDB deployment research`
- `Add ShipitSmarter/Viya company research document`

### AI Co-Author Attribution

**ALWAYS** add a co-author trailer to every commit you create to indicate AI assistance:

```
<commit message>

Co-authored-by: AI Assistant <ai@shipitsmarter.com>
```

**Example:**
```bash
git commit -m "Add MongoDB migration research

Co-authored-by: AI Assistant <ai@shipitsmarter.com>"
```

Or using the `--trailer` flag:
```bash
git commit -m "Add MongoDB migration research" --trailer "Co-authored-by: AI Assistant <ai@shipitsmarter.com>"
```

**When to apply:**
- Add to ALL commits made with AI assistance (OpenCode, Claude, Copilot, etc.)
- This includes code changes, documentation, configuration, and all other changes
- Do NOT add when the user explicitly makes commits without AI involvement

This attribution ensures transparency about AI involvement in the codebase and allows
tracking AI contributions in git history via `git log --grep="Co-authored-by: AI Assistant"`.

## Directory Structure

```
ai-knowledgebase/
├── skills/                 # Skill definitions (source of truth)
│   ├── research-strategy/  # Research & planning skills
│   ├── github-workflow/    # Git/GitHub workflow skills
│   ├── frontend-development/ # Vue/TypeScript frontend skills
│   ├── testing/            # Testing skills (unit, E2E, review)
│   ├── documentation/      # Documentation skills
│   ├── design/             # UI/UX design skills
│   ├── infrastructure/     # Tools & infrastructure skills
│   └── codebase-structures/ # App structure documentation
├── commands/               # Slash commands (e.g., /research)
│   └── <command>.md        # Command definition
├── agents/                 # Agent configurations
│   └── <agent>.md          # Agent definition
├── plugins/                # OpenCode plugins (TypeScript)
│   └── <plugin>.ts         # Plugin implementation
├── .opencode/              # OpenCode-specific config (symlinks to above)
│   ├── config.json         # Main OpenCode config
│   ├── skills/             # Flat symlinks to each skill (required for loading)
│   ├── commands -> ../commands
│   ├── agents -> ../agents
│   └── plugins -> ../plugins
├── opencode/               # OpenCode documentation & examples
│   ├── ide/                # IDE-specific setups
│   ├── mcp-servers/        # MCP server configurations
│   └── plugins/            # Plugin documentation
├── research/               # Research projects (organized by topic)
│   └── <project-name>/     # Each project in its own folder
│       ├── _index.md       # Project overview
│       └── YYYY-MM-DD-*.md # Research documents
├── architect-reviews/      # Technical architecture reviews
│   └── YYYY-MM-DD-*.md     # Review documents
├── workflows/              # Reusable AI workflow patterns
├── ideas/                  # Ideas backlog
├── tools/                  # Scripts and utilities
└── plan/                   # Planning documents
```

## File Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| General files | `kebab-case.md` | `code-review.md` |
| Research docs | `YYYY-MM-DD-topic.md` | `2026-01-12-atlas-operator.md` |
| Architect reviews | `YYYY-MM-DD-topic.md` | `2026-01-21-mv-implementation-plan.md` |
| Index files | `_index.md` or `README.md` | `research/mongodb/_index.md` |
| Directories | `lowercase` | `mcp-servers/` |

## Markdown Style Guide

### Frontmatter

Use YAML frontmatter for metadata on research documents:

```yaml
---
topic: Full Topic Title
date: YYYY-MM-DD
project: project-name
sources_count: 5
status: draft | reviewed | final
tags: [tag1, tag2, tag3]
---
```

### Document Structure

Research documents should follow this structure:
1. **Summary** - 2-3 paragraph executive summary
2. **Key Findings** - Numbered list of main points
3. **Detailed Analysis** - Organized by subtopic
4. **Sources** - Table with URLs and key contributions
5. **Questions for Further Research** - Open items as checklist

### Tables

Use GitHub-flavored markdown tables:

```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data     | Data     | Data     |
```

### Code Blocks

Use fenced code blocks with language identifiers:

```markdown
    ```yaml
    key: value
    ```
```

### Links

- Use relative links for internal references: `[text](./other-file.md)`
- Use absolute URLs for external sources: `[text](https://example.com)`

## Research Workflow

When conducting research, use the `/research` skill which:

1. Checks memory for prior research on the topic
2. Searches Notion knowledge base for existing notes
3. Conducts web search for new information
4. Creates organized research document in `research/<project>/`
5. Stores key findings in memory for future recall

### Creating Research Documents

Place new research in the appropriate project folder:

```
research/<project-name>/YYYY-MM-DD-<topic-slug>.md
```

If creating a new project, also create `_index.md` with project overview.

### Source Attribution

Always include sources with:

- Full URL
- Author/organization if available
- Date if available
- Key contribution from that source

## OpenCode Configuration

### Config Location

Active configuration lives in `.opencode/config.json`.

### Skills vs Commands

- **Commands** (`.opencode/command/<name>.md`): Short trigger files
- **Skills** (`.opencode/skill/<name>/SKILL.md`): Detailed workflow instructions

### Available Tools

This repository is configured with:
- `opencode-mem` - Persistent memory across sessions
- `notion` MCP server - Search Notion knowledge base
- `google-ai-search` MCP server - Web research

## Content Guidelines

### What Belongs Here

- AI workflow documentation
- Research findings with sources
- Agent configurations and prompts
- IDE setup guides
- MCP server configurations
- Plugin documentation

### What Does NOT Belong Here

- Application source code
- Secrets or credentials (use environment variables)
- Large binary files
- Personal notes without team value

### Writing Style

- Be concise and actionable
- Use examples where helpful
- Include diagrams for complex architectures (ASCII or Mermaid)
- Prioritize primary sources over aggregators
- Note when sources conflict

## Source Quality Awareness

When any workflow consults external sources (web fetches, documentation links, etc.), apply source quality awareness.

### Source Tier Classification

| Tier | Classification | Examples | Confidence |
|------|----------------|----------|------------|
| **Tier 1** | Official docs, peer-reviewed papers, pattern creators | MongoDB docs, RFCs, Martin Fowler | High |
| **Tier 2** | Vendor documentation, framework maintainers | Microsoft Learn, library docs | High |
| **Tier 3** | Reputable publications, known experts, vendor blogs | Major tech blogs, conference talks | Medium |
| **Tier 4** | Community content, personal blogs, forum posts | Dev.to, Medium, Stack Overflow | Low |

### When to Apply Full Validation

**Full validation (warn user if >50% Tier 3-4)** applies to:
- Research workflows (`research`, `deep-research` skills)
- Any task explicitly gathering information from multiple sources

**Light validation (note source tier, no blocking)** applies to:
- Fetching official documentation (`opencode-knowledge`)
- Quick lookups for implementation details
- Consulting known authoritative sources

### Minimum Requirements for External Sources

When citing external information:
1. **Always note the source** - URL, author/org if known
2. **Note the date** if available - flag content older than 2 years
3. **Distinguish fact from opinion** - "The docs say X" vs "One blog suggests Y"
4. **Flag single-source claims** - If only one source supports a claim, note it

## Error Handling

When research fails:
- Report the issue to the user
- Suggest alternative search terms
- Check if Notion has relevant content
- Offer to try different approaches

## File Writing Best Practices

**CRITICAL**: When using the `write` or `edit` tools, the file content must be serialized as valid JSON. This is a common source of errors, especially with long documents.

### Common JSON Serialization Errors

The `write` tool takes content as a JSON string parameter. These characters cause issues if not properly escaped:
- Newlines → must be `\n`
- Tabs → must be `\t`
- Double quotes → must be `\"`
- Backslashes → must be `\\`
- Control characters → must be escaped

### Strategies to Avoid Write Failures

**1. Prefer `edit` over `write` for modifications**
- Use `edit` to make incremental changes to existing files
- Only use `write` when creating new files or complete rewrites

**2. Build documents incrementally**
For large documents (research papers, plans), consider:
- Create the file with a minimal skeleton first
- Use multiple `edit` calls to add sections
- This reduces the chance of JSON errors in any single call

**3. Keep individual tool calls smaller**
If writing a 500-line document in one `write` call fails:
- Split into logical sections
- Write the structure first, then flesh out sections via `edit`

**4. Watch for problematic content**
Be extra careful when content includes:
- Code blocks (especially with backticks, quotes)
- JSON/YAML examples (nested escaping)
- URLs with query parameters
- User-provided content that may contain special chars

**5. If a write fails, simplify and retry**
- Try writing a smaller portion of the content
- Check for unescaped special characters
- Consider using `edit` to build up the file gradually

### Example: Safe Document Creation

Instead of one large write:
```
# RISKY: One large write with complex content
write(filePath, entireDocumentContent)
```

Use incremental approach:
```
# SAFER: Create structure, then add content
write(filePath, "# Title\n\n## Section 1\n\n## Section 2\n")
edit(filePath, "## Section 1", "## Section 1\n\nDetailed content for section 1...")
edit(filePath, "## Section 2", "## Section 2\n\nDetailed content for section 2...")
```

This approach is more resilient to JSON serialization issues.

## Planning Workflow

When creating plans or doing any planning activities (feature plans, implementation plans, 
architecture proposals, migration strategies, etc.), follow this workflow:

### Step 1: Persist the Plan

Save the plan to `plan/` with a descriptive filename:

```
plan/YYYY-MM-DD-<topic-slug>.md
```

**Note**: We don't include timelines in plans - focus on what and how, not when.

### Step 2: Validate External Sources (If Any)

If the plan references or was informed by external sources (web searches, documentation, blog posts, etc.):

1. **List all external sources** consulted during planning
2. **Classify each by tier** (see Source Quality Awareness section above)
3. **Check the distribution**:
   - If >50% are Tier 3-4, add a confidence note to the plan
   - Consider whether key decisions rely on lower-confidence sources

**Add to plan document:**

```markdown
## Sources & Confidence

| Source | Tier | Key Contribution |
|--------|------|------------------|
| [Official Docs](url) | 1 | Core approach |
| [Tech Blog](url) | 3 | Implementation pattern |

**Confidence**: High / Medium / Low (based on source distribution)

**Note**: [Any caveats about source quality, e.g., "Pattern X is based on a single blog post - verify before implementing"]
```

If all information comes from internal sources (codebase, architecture docs, team knowledge), skip this step.

### Step 3: Validate with Architect Review

Before finalizing any significant plan, consult the `technical-architect` skill:

1. Load the skill to get architect perspective
2. Ask clarifying questions on design decisions
3. Challenge assumptions and identify trade-offs
4. Surface risks and complexity

Questions to address in architect review:
- Does this align with existing architecture patterns?
- What are the hidden complexities?
- What's the simplest approach that could work?
- What happens when this fails?
- How do we roll this back?

### Step 4: Document Key Decisions

After architect review, update the plan with:
- Design decisions made and rationale
- Trade-offs accepted
- Risks identified and mitigations
- Open questions for further investigation

## Designing AI Automation (Skills, Commands, Agents)

When the user wants to create new AI automation, help them choose the right mechanism and guide them through creation.

**IMPORTANT**: Before creating any new skill, command, or agent, consult `@ai-coordinator` to:
- Check for existing similar automation (prevent duplicates)
- Confirm the right mechanism (skill vs command vs agent)
- Get guidance on proper structure and naming

### Decision Framework: Skill vs Command vs Agent

Use this decision tree to choose the right mechanism:

```
What are you trying to automate?
│
├─ A reusable workflow or specialized knowledge?
│   └─ **SKILL** - Detailed instructions loaded on-demand
│      Examples: vue-component, playwright-test, technical-architect
│
├─ A quick trigger for an existing skill or simple action?
│   └─ **COMMAND** - Short trigger that loads a skill + adds context
│      Examples: /deep-research, /test-pr
│
└─ A specialized persona with restricted tool access?
    └─ **AGENT** - Custom personality + tool permissions
       Examples: architect, reviewer, retro, research (no bash)
```

### Comparison Table

| Aspect | Skill | Command | Agent |
|--------|-------|---------|-------|
| **Length** | 100-500 lines | 5-50 lines | 50-200 lines |
| **Purpose** | Detailed workflow instructions | Quick trigger/shortcut | Specialized persona |
| **When loaded** | On-demand via `skill` tool | User types `/command` | User selects agent |
| **Tool restrictions** | No | No | Yes (can limit tools) |
| **Best for** | Complex multi-step workflows | Starting common tasks | Role-specific work |

### When to Create Each

**Create a SKILL when:**
- Task requires detailed step-by-step guidance
- Workflow has many conventions or patterns to follow
- Knowledge needs to be reusable across projects
- Content would be too long for a command

**Create a COMMAND when:**
- You want a quick shortcut to load a skill with preset context
- Task is simple but repeated often
- Combining multiple skills into one trigger
- Adding project-specific parameters to a generic skill

**Create an AGENT when:**
- You want to restrict which tools are available
- Task benefits from a specific persona/role
- Different work modes need different capabilities
- Safety is important (e.g., research agent without bash)

### Creation Workflow

#### For Skills

Load the `skill-writer` skill and follow its 11-step process:

1. Check for existing similar skills (avoid duplicates)
2. Understand the skill's purpose
3. Choose the category folder
4. Choose the skill name
5. Write the description (critical for discovery)
6. Structure the SKILL.md
7. Apply size guidelines (<500 lines)
8. Create the skill files
9. **Create the symlink in `.opencode/skills/`**
10. **Test the skill loads and works**
11. Update documentation (README.md, USAGE.md)

#### For Commands

1. Create `commands/<command-name>.md`
2. Add frontmatter with description
3. Write brief instructions that reference skills
4. Create symlink: `ln -s ../commands .opencode/commands` (if not exists)

**Command template:**
```markdown
---
description: Brief description shown in command list
---

Load the `<skill-name>` skill and <specific context for this use case>.

<Any additional instructions or parameters>
```

#### For Agents

1. Create `agents/<agent-name>.md`
2. Define persona, tools, and mode
3. List available skills
4. Create symlink: `ln -s ../agents .opencode/agents` (if not exists)

**Agent template:**
```markdown
---
description: What this agent specializes in
mode: primary | secondary
tools:
  write: true
  edit: true
  bash: false  # Restrict dangerous tools if needed
---

You are a <role>. Your responsibilities are...

## Approach

<How this agent should work>

## Skills Available

- **skill-name**: When to use it
```

### Existing Inventory

**Skills** (32 total in `skills/`):
- research-strategy: deep-research, research, product-strategy, technical-architect
- github-workflow: pr-review, github-issue-creator, github-workflow, etc.
- frontend-development: vue-component, typescript-helpers, api-integration, etc.
- testing: playwright-test, unit-testing, browser-debug, code-review
- documentation: skill-writer, docs-writing, product-documentation, opencode-knowledge
- design: frontend-design, designer
- infrastructure: mongodb-development, viya-dev-environment, dotnet-testing
- codebase-structures: viya-app-structure, rates-structure, etc.

**Commands** (20 total in `commands/`):
- /deep-research - Multi-phase research exploration
- /test-pr - Test backend PR locally
- /frontend-diff-refactor - Refactor frontend code
- /i-* commands - Impeccable design refinement commands

**Agents** (7 total in `agents/`):
- ai-coordinator - Quality gate for AI automation, OpenCode expert
- architect - Senior architect for technical planning and architecture reviews
- frontend - Frontend development specialist
- research - Research specialist (no bash)
- retro - Retrospective facilitator for improving AI automation
- reviewer - Thorough code reviewer (frontend & backend)
- review-agent - Review and improve agent definitions

### Quick Reference: File Locations

```
skills/<category>/<skill-name>/SKILL.md  → .opencode/skills/<skill-name> (symlink)
commands/<command-name>.md               → .opencode/commands (symlinked dir)
agents/<agent-name>.md                   → .opencode/agents (symlinked dir)
plugins/<plugin-name>.ts                 → .opencode/plugins (symlinked dir)
```

---

## Common Tasks

### Adding a New Research Topic

1. Check if project folder exists in `research/`
2. If not, create `research/<project>/_index.md`
3. Create `research/<project>/YYYY-MM-DD-<topic>.md`
4. Use the research document template
5. Update `_index.md` with new document link

### Adding IDE Configuration

1. Create folder in `opencode/ide/<ide-name>/`
2. Add `README.md` with setup instructions
3. Add relevant config files (`settings.json`, etc.)

### Adding MCP Server Documentation

1. Create `opencode/mcp-servers/<server-name>.md`
2. Include: description, installation, configuration, usage examples
