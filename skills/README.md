# Skills Library

This directory contains reusable AI agent skills for OpenCode and similar AI coding tools. Skills provide specialized knowledge and step-by-step workflows for specific tasks.

## What Are Skills?

Skills are markdown-based instruction sets that teach AI agents how to perform specific tasks consistently. Each skill contains:
- **When to use**: Trigger conditions and use cases
- **Workflow steps**: Detailed instructions for the agent to follow
- **Conventions**: Project-specific patterns and standards
- **Examples**: Reference implementations and templates

## Quick Reference

| Skill | Description | Category |
|-------|-------------|----------|
| [api-integration](./frontend-development/api-integration/SKILL.md) | API types and service integration | frontend-development |
| [browser-debug](./testing/browser-debug/SKILL.md) | Headless browser debugging and visual testing | testing |
| [code-review](./testing/code-review/SKILL.md) | Code review patterns and checklists | testing |
| [codebase-navigation](./frontend-development/codebase-navigation/SKILL.md) | Understanding project structure | frontend-development |
| [deep-research](./research-strategy/deep-research/SKILL.md) | Multi-phase exploration and synthesis | research-strategy |
| [designer](./design/designer/SKILL.md) | Penpot MCP integration for design workflows | design |
| [docs-writing](./documentation/docs-writing/SKILL.md) | User-facing documentation for non-technical users | documentation |
| [frontend-design](./design/frontend-design/SKILL.md) | Production-grade UI interfaces | design |
| [git-branch-update](./github-workflow/git-branch-update/SKILL.md) | Branch management and rebasing | github-workflow |
| [github-issue-creator](./github-workflow/github-issue-creator/SKILL.md) | Create focused GitHub issues | github-workflow |
| [github-issue-tracker](./github-workflow/github-issue-tracker/SKILL.md) | Update and maintain GitHub issues | github-workflow |
| [github-workflow](./github-workflow/github-workflow/SKILL.md) | PR workflow, releases, conventions | github-workflow |
| [mongodb-development](./infrastructure/mongodb-development/SKILL.md) | MongoDB queries, aggregations, schema analysis | infrastructure |
| [playwright-test](./testing/playwright-test/SKILL.md) | E2E testing with Playwright | testing |
| [pr-review](./github-workflow/pr-review/SKILL.md) | Senior engineer PR review patterns | github-workflow |
| [product-documentation](./documentation/product-documentation/SKILL.md) | Product docs for Viya TMS | documentation |
| [product-strategy](./research-strategy/product-strategy/SKILL.md) | Playing to Win strategy framework | research-strategy |
| [rates-feature](./frontend-development/rates-feature/SKILL.md) | Rates module development patterns | frontend-development |
| [rates-structure](./codebase-structures/rates-structure/SKILL.md) | Rates codebase structure | codebase-structures |
| [research](./research-strategy/research/SKILL.md) | Online research with source attribution | research-strategy |
| [shipping-structure](./codebase-structures/shipping-structure/SKILL.md) | Shipping microservice structure | codebase-structures |
| [skill-writer](./documentation/skill-writer/SKILL.md) | Create and refine agent skills | documentation |
| [technical-architect](./research-strategy/technical-architect/SKILL.md) | Architecture review and planning | research-strategy |
| [typescript-helpers](./frontend-development/typescript-helpers/SKILL.md) | TypeScript patterns and type guards | frontend-development |
| [unit-testing](./testing/unit-testing/SKILL.md) | Vitest and vue-test-utils patterns | testing |
| [viya-app-structure](./codebase-structures/viya-app-structure/SKILL.md) | Viya app codebase structure | codebase-structures |
| [viya-dev-environment](./infrastructure/viya-dev-environment/SKILL.md) | Local dev environment management | infrastructure |
| [viya-ui-warehouse-structure](./codebase-structures/viya-ui-warehouse-structure/SKILL.md) | Warehouse UI structure | codebase-structures |
| [viya-app-coding-standards](./frontend-development/viya-app-coding-standards/SKILL.md) | Viya-app coding standards | frontend-development |
| [vue-component](./frontend-development/vue-component/SKILL.md) | Vue 3 component conventions | frontend-development |

## Skills by Category

### Research & Strategy (`research-strategy/`)

| Skill | Description |
|-------|-------------|
| [deep-research](./research-strategy/deep-research/SKILL.md) | Multi-phase exploration agent for broad research and validation |
| [research](./research-strategy/research/SKILL.md) | Online research with source attribution and Notion integration |
| [product-strategy](./research-strategy/product-strategy/SKILL.md) | Product strategy using Playing to Win framework |
| [technical-architect](./research-strategy/technical-architect/SKILL.md) | Senior architect perspective for technical planning |

### GitHub & Workflow (`github-workflow/`)

| Skill | Description |
|-------|-------------|
| [github-issue-creator](./github-workflow/github-issue-creator/SKILL.md) | Create focused GitHub issues as work summaries |
| [github-issue-tracker](./github-workflow/github-issue-tracker/SKILL.md) | Update issues, add comments, change status |
| [github-workflow](./github-workflow/github-workflow/SKILL.md) | PR workflow, commit messages, release notes |
| [git-branch-update](./github-workflow/git-branch-update/SKILL.md) | Branch management, rebasing, conflict resolution |
| [pr-review](./github-workflow/pr-review/SKILL.md) | Senior engineer code review patterns |

### Frontend Development (`frontend-development/`)

| Skill | Description |
|-------|-------------|
| [vue-component](./frontend-development/vue-component/SKILL.md) | Vue 3 components following project conventions |
| [viya-app-coding-standards](./frontend-development/viya-app-coding-standards/SKILL.md) | Coding standards for TypeScript, Vue, and Playwright |
| [api-integration](./frontend-development/api-integration/SKILL.md) | API types and service integration patterns |
| [typescript-helpers](./frontend-development/typescript-helpers/SKILL.md) | TypeScript patterns, interfaces, type guards |
| [codebase-navigation](./frontend-development/codebase-navigation/SKILL.md) | Understanding viya-app project structure |
| [rates-feature](./frontend-development/rates-feature/SKILL.md) | Rates module development patterns |

### Testing (`testing/`)

| Skill | Description |
|-------|-------------|
| [unit-testing](./testing/unit-testing/SKILL.md) | Vitest and vue-test-utils patterns |
| [playwright-test](./testing/playwright-test/SKILL.md) | Playwright E2E testing patterns |
| [browser-debug](./testing/browser-debug/SKILL.md) | Headless browser debugging for QA failures |
| [code-review](./testing/code-review/SKILL.md) | Code review patterns and checklists |

### Documentation (`documentation/`)

| Skill | Description |
|-------|-------------|
| [product-documentation](./documentation/product-documentation/SKILL.md) | Product docs for Viya TMS |
| [docs-writing](./documentation/docs-writing/SKILL.md) | User-facing documentation for non-technical users |
| [skill-writer](./documentation/skill-writer/SKILL.md) | Create and refine agent skills |

### Design (`design/`)

| Skill | Description |
|-------|-------------|
| [frontend-design](./design/frontend-design/SKILL.md) | Production-grade UI interfaces (includes reference guides) |
| [designer](./design/designer/SKILL.md) | Penpot MCP integration for AI-assisted design |

The `frontend-design` skill includes reference files for:
- Color and contrast
- Interaction design
- Motion design
- Responsive design
- Spatial design
- Typography
- UX writing

### Infrastructure & Tools (`infrastructure/`)

| Skill | Description |
|-------|-------------|
| [mongodb-development](./infrastructure/mongodb-development/SKILL.md) | MongoDB queries, aggregations, schema analysis |
| [viya-dev-environment](./infrastructure/viya-dev-environment/SKILL.md) | Local dev environment management |

### Codebase Structures (`codebase-structures/`)

| Skill | Description |
|-------|-------------|
| [viya-app-structure](./codebase-structures/viya-app-structure/SKILL.md) | Main viya-app codebase structure |
| [viya-ui-warehouse-structure](./codebase-structures/viya-ui-warehouse-structure/SKILL.md) | Warehouse UI structure |
| [rates-structure](./codebase-structures/rates-structure/SKILL.md) | Rates microservice codebase structure |
| [shipping-structure](./codebase-structures/shipping-structure/SKILL.md) | Shipping microservice codebase structure |

## Using Skills in OpenCode

### Loading a Skill

In OpenCode, use the `skill` tool to load a skill:

```
Load the vue-component skill
```

The skill instructions will be added to the agent's context for the current task.

### Skill Locations

OpenCode looks for skills in:
1. `.opencode/skills/` in the current project (symlinked to `skills/`)
2. `~/.config/opencode/skills/` for global skills
3. Custom paths via `OPENCODE_CONFIG_DIR` environment variable
4. Multiple paths via the `opencode-skillful` plugin

### Creating New Skills

Use the [skill-writer](./documentation/skill-writer/SKILL.md) skill to create new skills following the agentskills.io specification.

## Directory Structure

```
skills/
├── README.md                   # This file
├── research-strategy/          # Research & Strategy (4 skills)
│   ├── deep-research/
│   ├── research/
│   ├── product-strategy/
│   └── technical-architect/
├── github-workflow/            # GitHub & Workflow (5 skills)
│   ├── github-issue-creator/
│   ├── github-issue-tracker/
│   ├── github-workflow/
│   ├── git-branch-update/
│   └── pr-review/
├── frontend-development/       # Frontend Development (5 skills)
│   ├── vue-component/
│   ├── api-integration/
│   ├── typescript-helpers/
│   ├── codebase-navigation/
│   └── rates-feature/
├── testing/                    # Testing (4 skills)
│   ├── unit-testing/
│   ├── playwright-test/
│   ├── browser-debug/
│   └── code-review/
├── documentation/              # Documentation (3 skills)
│   ├── product-documentation/
│   ├── docs-writing/
│   └── skill-writer/
├── design/                     # Design (2 skills)
│   ├── frontend-design/        # Includes reference/ subfolder
│   └── designer/
├── infrastructure/             # Infrastructure & Tools (2 skills)
│   ├── mongodb-development/
│   └── viya-dev-environment/
└── codebase-structures/        # Codebase Structures (4 skills)
    ├── viya-app-structure/
    ├── viya-ui-warehouse-structure/
    ├── rates-structure/
    └── shipping-structure/
```

## Contributing

When adding a new skill:
1. Identify the appropriate category folder
2. Create a subfolder with the skill name
3. Add a `SKILL.md` file following the pattern of existing skills
4. Update this README with the new skill in both the Quick Reference table and appropriate category section
5. Keep descriptions concise (under 60 characters)
