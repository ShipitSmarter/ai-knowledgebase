---
topic: "Skill Organization & Discovery"
date: 2026-01-22
project: opencode-organization
sources_count: 3
status: draft
tags: [skills, organization, discovery, naming, descriptions]
---

# Skill Organization & Discovery

## Summary

This research analyzes the organization patterns of 23 skills in the ai-knowledgebase repository to establish best practices for skill discoverability, naming conventions, and structural organization. The analysis reveals that current skills follow consistent kebab-case naming and most use a WHAT+WHEN description pattern, but there's significant variation in skill size and limited use of the `references/` folder feature.

Key insight: Skill discoverability depends primarily on well-written descriptions that help the AI model auto-select the right skill. The description should clearly state WHAT the skill does and WHEN to use it. Current skills range from 127-1050 lines, with most fitting comfortably in the 300-500 line "sweet spot" recommended by the skill-writer guidelines.

## Key Findings

1. **Description Pattern**: Most effective skills use a "WHAT + WHEN" description format (e.g., "Writing Playwright E2E tests following project patterns. Use when creating new E2E tests..."). This helps the model auto-load skills appropriately.

2. **Naming Conventions**: Three patterns emerged - domain-prefixed (github-*), role-based (technical-architect), and task-based (unit-testing). Domain prefixing creates natural groupings.

3. **Size Distribution**: Skills range from 127 lines (frontend-design) to 1050 lines (pr-review). Most cluster in 300-500 lines. Very large skills may benefit from splitting into references/ files.

4. **References Underutilized**: Only 1 of 23 skills (github-issue-creator) actively uses a `references/` folder, despite this being a key mechanism for progressive disclosure.

## Current Skills Inventory

| Skill Name | Lines | Category | Description Quality | Has References |
|------------|-------|----------|---------------------|----------------|
| api-integration | 352 | Development | Good (WHAT+WHEN) | No |
| browser-debug | 406 | Testing/Debug | Good (WHAT+WHEN) | No |
| codebase-navigation | 367 | Navigation | Good (WHAT+WHEN) | No |
| competitive-ads-extractor | 308 | Marketing | Good (WHAT+WHEN) | No |
| deep-research | 516 | Research | Good (WHAT+WHEN) | No |
| designer | 261 | Design | Brief | No |
| docs-writing | 359 | Documentation | Good (WHAT+WHEN) | No |
| frontend-design | 127 | Development | Good | Mentioned* |
| github-issue-creator | 278 | GitHub | Good (WHAT+WHEN) | Yes (TEMPLATES.md) |
| github-issue-tracker | 433 | GitHub | Good (WHAT+WHEN) | No |
| github-workflow | 349 | GitHub | Good (WHAT+WHEN) | No |
| mongodb-development | 464 | Development | Good (WHAT+WHEN) | No |
| playwright-test | 640 | Testing | Excellent | No |
| pr-review | 1050 | GitHub/Review | Excellent | No |
| product-documentation | 349 | Documentation | Good (WHAT+WHEN) | No |
| product-strategy | 354 | Strategy | Good (WHAT+WHEN) | No |
| research | 209 | Research | Good (WHAT+WHEN) | No |
| skill-writer | 400 | Meta/Tooling | Good (WHAT+WHEN) | No |
| technical-architect | 293 | Architecture | Excellent triggers | No |
| typescript-helpers | 555 | Development | Good (WHAT+WHEN) | No |
| unit-testing | 516 | Testing | Good (WHAT+WHEN) | No |
| viya-dev-environment | 179 | DevOps | Brief | No |
| vue-component | 355 | Development | Good (WHAT+WHEN) | No |

*frontend-design mentions reference files but they may be external to this repo

## Description Writing Guidelines

### The WHAT + WHEN Pattern

Effective skill descriptions follow this structure:

```
<WHAT it does - one sentence>. <WHEN to use it - specific triggers>.
```

**Excellent examples:**
- `technical-architect`: "Senior architect/CTO perspective for technical planning and infrastructure review. Use when planning new features, evaluating technical approaches, reviewing architecture decisions, or assessing infrastructure changes."
- `playwright-test`: "Writing Playwright E2E tests following project patterns and fixtures. Use when creating new E2E tests, debugging test failures, or setting up test helpers and page objects."

**Weak examples:**
- `designer`: "Start Penpot MCP servers and work with designs." (Missing WHEN triggers)
- `viya-dev-environment`: "Manage viya-app local development environment" (Too brief, no triggers)

### Description Optimization Checklist

- [ ] First sentence explains the core capability
- [ ] Second part lists 3-5 specific "use when" triggers
- [ ] Triggers match user intent patterns (how users phrase requests)
- [ ] Avoids jargon that users wouldn't type
- [ ] Distinguishes from related skills (e.g., research vs deep-research)

## Naming Conventions

### Observed Patterns

1. **Domain-prefixed** (creates natural groupings):
   - `github-issue-creator`, `github-issue-tracker`, `github-workflow`
   
2. **Role-based** (persona-centric):
   - `technical-architect`, `designer`
   
3. **Task-based** (action-centric):
   - `unit-testing`, `deep-research`, `pr-review`

4. **Technology-scoped**:
   - `mongodb-development`, `typescript-helpers`, `vue-component`, `playwright-test`

### Recommendations

- Use **kebab-case** consistently (all current skills do)
- Consider **domain prefixing** for related skills (aids mental grouping)
- Avoid abbreviations except well-known ones (pr, api)
- Name should hint at scope: `unit-testing` vs `testing` (specific > generic)

## Organization Strategies

### Current Structure: Flat with Symlinks

```
skills/
├── api-integration/SKILL.md
├── github-issue-creator/SKILL.md
├── github-workflow/SKILL.md
└── ... (23 total)
```

**Pros**: Simple, follows agentskills.io spec, works with OpenCode loading
**Cons**: No visual categorization, harder to browse at scale

### Alternative: Categorized (NOT RECOMMENDED)

```
skills/
├── github/
│   ├── issue-creator/SKILL.md
│   └── workflow/SKILL.md
└── testing/
    └── playwright/SKILL.md
```

**Issue**: OpenCode expects `skills/<name>/SKILL.md` - nested categories break this.

### Recommended: Flat with Naming Conventions

Keep flat structure but use consistent naming prefixes:
- `github-*` for GitHub-related
- `test-*` or `*-testing` for testing-related
- `viya-*` for project-specific

### References Folder Usage

The `references/` folder enables progressive disclosure:
1. SKILL.md loads first (must be < 5000 lines)
2. Agent can read from `references/` when needed

**When to use references/**:
- Templates that vary by context
- Example code that's too long for main file
- Checklists or lookup tables
- Style guides or detailed specifications

**Current usage**: Only github-issue-creator uses TEMPLATES.md in references/

**Opportunity**: Skills over 500 lines (pr-review at 1050, playwright-test at 640) could benefit from extracting examples into references/.

## Recommendations

### Immediate Improvements

1. **Enhance brief descriptions**:
   - Add WHEN triggers to `designer`, `viya-dev-environment`
   - Make triggers more specific and user-intent-aligned

2. **Extract references for large skills**:
   - `pr-review` (1050 lines): Extract checklist templates
   - `playwright-test` (640 lines): Extract fixture examples
   - `typescript-helpers` (555 lines): Extract type patterns

3. **Distinguish related skills**:
   - Clarify `research` vs `deep-research` in descriptions
   - Clarify `docs-writing` vs `product-documentation`

### Long-term Considerations

1. **Adopt domain prefixes** for new skills in same category
2. **Create an index** - Consider a `skills/_index.md` listing all skills with one-line descriptions
3. **Version key skills** - For breaking changes, consider `skill-v2` naming

## Sources

| Source | Key Contribution |
|--------|------------------|
| skills/*/SKILL.md (23 files) | Primary data - all skill definitions analyzed |
| skills/skill-writer/SKILL.md | Best practices for skill authoring |
| [agentskills.io/specification](https://agentskills.io/specification) | Official format specification |

## Questions for Further Research

- [ ] How does skill description length affect auto-selection accuracy?
- [ ] Would a categorization scheme in descriptions (tags) help discovery?
- [ ] How do users actually phrase requests that should load skills?
- [ ] Should skills declare relationships (e.g., "related to: deep-research")?
