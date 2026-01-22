# Research Projects

This folder contains all research projects organized by topic.

## Structure

```
research/
├── <project-name>/
│   ├── _index.md              # Project overview
│   ├── YYYY-MM-DD-topic.md    # Research documents
│   └── sources/               # Downloaded files (optional)
└── ...
```

## Creating a New Project

1. Use the `/research` command with a new topic
2. The agent will suggest a project name
3. Confirm or provide your own name
4. Research files will be created in the new project folder

## Projects

| Project | Description | Documents |
|---------|-------------|-----------|
| [agent-skills](./agent-skills/) | Agent Skills specification and best practices | 2 |
| [company-context](./company-context/) | ShipitSmarter/Viya company overview and competitors | 2 |
| [github-copilot](./github-copilot/) | GitHub Copilot custom instructions research | 1 |
| [marketing-content](./marketing-content/) | AI prompting and copywriting for marketing | 2 |
| [mongodb-development](./mongodb-development/) | MongoDB AI development tools (MCP servers) | 1 |
| [mongodb-kubernetes](./mongodb-kubernetes/) | MongoDB deployment options for Kubernetes | 1 |
| [product-strategy](./product-strategy/) | Writing product strategy, team organization | 4 |
| [shipitsmarter-repos](./shipitsmarter-repos/) | Repository catalog and service architecture | 2 |
| [testing-strategy](./testing-strategy/) | Modern testing with Playwright and Vitest | 2 |
| [tms-competitors](./tms-competitors/) | TMS competitor analysis (Transporeon, etc.) | 1 |
| [viya-data-model](./viya-data-model/) | MongoDB data model documentation | 1 |
| [viya-reporting](./viya-reporting/) | Reporting and materialized views research | 1 |

## Best Practices

### Naming
- Use lowercase with hyphens: `ai-agent-memory`
- Be specific but concise
- Avoid dates in project names (dates go in filenames)

### Organization
- One topic per research file
- Use `_index.md` to track project progress
- Link related research across projects

### Sources
- Always include URLs
- Prefer primary sources
- Note when sources conflict
