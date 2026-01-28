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
| [code-review](./github-workflow/code-review/SKILL.md) | Code review patterns and checklists | github-workflow |
| [diff-refactor](./frontend-development/diff-refactor/SKILL.md) | Diff branch and refactor to standards | frontend-development |
| [logistics-entities](./frontend-development/logistics-entities/SKILL.md) | Shipment, consignment, handling unit patterns | frontend-development |
| [deep-research](./research-strategy/deep-research/SKILL.md) | Multi-phase exploration and synthesis | research-strategy |
| [designer](./design/designer/SKILL.md) | Penpot MCP integration for design workflows | design |
| [docs-writing](./documentation/docs-writing/SKILL.md) | User-facing documentation for non-technical users | documentation |
| [frontend-design](./design/frontend-design/SKILL.md) | Production-grade UI interfaces | design |
| [opencode-knowledge](./documentation/opencode-knowledge/SKILL.md) | OpenCode concepts, configuration, best practices | documentation |
| [git-branch-update](./github-workflow/git-branch-update/SKILL.md) | Branch management and rebasing | github-workflow |
| [github-issue-creator](./github-workflow/github-issue-creator/SKILL.md) | Create focused GitHub issues | github-workflow |
| [github-issue-tracker](./github-workflow/github-issue-tracker/SKILL.md) | Update and maintain GitHub issues | github-workflow |
| [github-workflow](./github-workflow/github-workflow/SKILL.md) | PR workflow, releases, conventions | github-workflow |
| [mongodb-development](./infrastructure/mongodb-development/SKILL.md) | MongoDB queries, aggregations, schema analysis | infrastructure |
| [mongodb-performance](./infrastructure/mongodb-performance/SKILL.md) | MongoDB performance diagnostics (N+1, explain, batching) | infrastructure |
| [playwright-test](./testing/playwright-test/SKILL.md) | E2E testing with Playwright | testing |
| [pr-review](./github-workflow/pr-review/SKILL.md) | Senior engineer PR review patterns | github-workflow |
| [product-documentation](./documentation/product-documentation/SKILL.md) | Product docs for Viya TMS | documentation |
| [product-strategy](./research-strategy/product-strategy/SKILL.md) | Playing to Win strategy framework | research-strategy |
| [rates-feature](./codebase/cross-repo/rates-feature/SKILL.md) | Rates module development patterns | codebase/cross-repo |
| [rates-structure](./codebase/repo-structures/rates-structure/SKILL.md) | Rates codebase structure | codebase/repo-structures |
| [research](./research-strategy/research/SKILL.md) | Online research with source attribution | research-strategy |
| [shipping-structure](./codebase/repo-structures/shipping-structure/SKILL.md) | Shipping microservice structure | codebase/repo-structures |
| [skill-writer](./documentation/skill-writer/SKILL.md) | Create and refine agent skills | documentation |
| [technical-architect](./research-strategy/technical-architect/SKILL.md) | Architecture review and planning | research-strategy |
| [typescript-helpers](./frontend-development/typescript-helpers/SKILL.md) | TypeScript patterns and type guards | frontend-development |
| [unit-testing](./testing/unit-testing/SKILL.md) | Vitest and vue-test-utils patterns | testing |
| [viya-app-structure](./codebase/repo-structures/viya-app-structure/SKILL.md) | Viya app codebase structure | codebase/repo-structures |
| [viya-dev-environment](./infrastructure/viya-dev-environment/SKILL.md) | Local dev environment management | infrastructure |
| [viya-ui-warehouse-structure](./codebase/repo-structures/viya-ui-warehouse-structure/SKILL.md) | Warehouse UI structure | codebase/repo-structures |
| [webhooks](./codebase/cross-repo/webhooks/SKILL.md) | Webhook/event system across repos | codebase/cross-repo |
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
| [code-review](./github-workflow/code-review/SKILL.md) | Code review patterns and checklists |

### Frontend Development (`frontend-development/`)

| Skill | Description |
|-------|-------------|
| [vue-component](./frontend-development/vue-component/SKILL.md) | Vue 3 components following project conventions |
| [viya-app-coding-standards](./frontend-development/viya-app-coding-standards/SKILL.md) | Coding standards for TypeScript, Vue, and Playwright |
| [diff-refactor](./frontend-development/diff-refactor/SKILL.md) | Diff branch and refactor changed files |
| [logistics-entities](./frontend-development/logistics-entities/SKILL.md) | Shipment, consignment, handling unit entity patterns |
| [api-integration](./frontend-development/api-integration/SKILL.md) | API types and service integration patterns |
| [typescript-helpers](./frontend-development/typescript-helpers/SKILL.md) | TypeScript patterns, interfaces, type guards |

> **Note**: Large skills have reference material in `reference/` subfolders. For example:
> - `typescript-helpers/reference/utility-types.md` - detailed type patterns
> - `vue-component/reference/conventions.md` - script order and lessons learned

### Testing (`testing/`)

| Skill | Description |
|-------|-------------|
| [unit-testing](./testing/unit-testing/SKILL.md) | Vitest and vue-test-utils patterns |
| [playwright-test](./testing/playwright-test/SKILL.md) | Playwright E2E testing patterns |
| [browser-debug](./testing/browser-debug/SKILL.md) | Headless browser debugging for QA failures |

> **Note**: `playwright-test/reference/patterns.md` contains detailed locator strategies and common patterns.

### Documentation (`documentation/`)

| Skill | Description |
|-------|-------------|
| [product-documentation](./documentation/product-documentation/SKILL.md) | Product docs for Viya TMS |
| [docs-writing](./documentation/docs-writing/SKILL.md) | User-facing documentation for non-technical users |
| [skill-writer](./documentation/skill-writer/SKILL.md) | Create and refine agent skills |
| [opencode-knowledge](./documentation/opencode-knowledge/SKILL.md) | OpenCode concepts, configuration, best practices |

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
| [mongodb-performance](./infrastructure/mongodb-performance/SKILL.md) | MongoDB performance diagnostics (N+1, explain, batching) |
| [viya-dev-environment](./infrastructure/viya-dev-environment/SKILL.md) | Local dev environment management |

### Codebase (`codebase/`)

#### Repo Structures (`codebase/repo-structures/`)

Skills for understanding single-repository codebases.

| Skill | Description |
|-------|-------------|
| [viya-app-structure](./codebase/repo-structures/viya-app-structure/SKILL.md) | Main viya-app codebase structure (includes navigation patterns) |
| [viya-ui-warehouse-structure](./codebase/repo-structures/viya-ui-warehouse-structure/SKILL.md) | Warehouse UI structure |
| [rates-structure](./codebase/repo-structures/rates-structure/SKILL.md) | Rates microservice codebase structure |
| [shipping-structure](./codebase/repo-structures/shipping-structure/SKILL.md) | Shipping microservice codebase structure |

#### Cross-Repo (`codebase/cross-repo/`)

Generic knowledge about features and flows that span multiple repositories.

| Skill | Description |
|-------|-------------|
| [rates-feature](./codebase/cross-repo/rates-feature/SKILL.md) | Rates module development patterns |
| [webhooks](./codebase/cross-repo/webhooks/SKILL.md) | Webhook/event system across repositories |

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

## Usage Tracking

Track which skills are used and how helpful they are in [USAGE.md](./USAGE.md). This helps identify:
- Most valuable skills
- Skills needing improvement
- Missing skill opportunities

## Directory Structure

```
skills/
├── README.md                   # This file
├── USAGE.md                    # Skill usage tracking
├── research-strategy/          # Research & Strategy (4 skills)
│   ├── deep-research/
│   ├── research/
│   ├── product-strategy/
│   └── technical-architect/
├── github-workflow/            # GitHub & Workflow (6 skills)
│   ├── code-review/
│   ├── github-issue-creator/
│   ├── github-issue-tracker/
│   ├── github-workflow/
│   ├── git-branch-update/
│   └── pr-review/
├── frontend-development/       # Frontend Development (6 skills)
│   ├── api-integration/
│   ├── diff-refactor/
│   ├── logistics-entities/
│   ├── typescript-helpers/
│   │   └── reference/          # Utility types
│   ├── viya-app-coding-standards/
│   └── vue-component/
│       └── reference/          # Conventions, lessons learned
├── testing/                    # Testing (3 skills)
│   ├── browser-debug/
│   ├── playwright-test/
│   │   └── reference/          # Locator patterns
│   └── unit-testing/
├── documentation/              # Documentation (4 skills)
│   ├── docs-writing/
│   ├── opencode-knowledge/
│   ├── product-documentation/
│   └── skill-writer/
├── design/                     # Design (2 skills)
│   ├── designer/
│   └── frontend-design/
│       └── reference/          # Design guides
├── infrastructure/             # Infrastructure & Tools (2 skills)
│   ├── mongodb-development/
│   └── viya-dev-environment/
└── codebase/                   # Codebase Knowledge (6 skills)
    ├── repo-structures/        # Single-repo structure knowledge
    │   ├── rates-structure/
    │   ├── shipping-structure/
    │   ├── viya-app-structure/
    │   └── viya-ui-warehouse-structure/
    └── cross-repo/             # Multi-repo features and flows
        ├── rates-feature/
        └── webhooks/
```

## Contributing

When adding a new skill:
1. Identify the appropriate category folder
2. Create a subfolder with the skill name
3. Add a `SKILL.md` file following the pattern of existing skills
4. For large skills with detailed patterns, extract reference material to `reference/` subfolder
5. Update this README with the new skill in both the Quick Reference table and appropriate category section
6. Keep descriptions concise (under 60 characters)
