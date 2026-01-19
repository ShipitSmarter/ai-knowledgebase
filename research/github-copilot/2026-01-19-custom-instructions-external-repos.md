---
topic: GitHub Copilot Custom Instructions - External Repository References
date: 2026-01-19
project: github-copilot
sources_count: 5
status: draft
tags: [github-copilot, custom-instructions, enterprise, organization, shared-context]
---

# GitHub Copilot Custom Instructions - External Repository References

## Summary

GitHub Copilot does **not natively support referencing custom instructions from external repositories**. Custom instructions are strictly scoped to three levels: personal, repository, and organization. Each level has its own mechanism and none allow importing or referencing instructions from another repository.

However, GitHub provides several alternative mechanisms for sharing context across repositories: **Organization Custom Instructions** (for Copilot Business/Enterprise), **Copilot Spaces** (for context sharing), and indirect methods like git submodules or manual synchronization.

## Key Findings

1. **No cross-repo instruction imports**: The `.github/copilot-instructions.md` file cannot reference or import instructions from another repository. Instructions must exist within the repository itself.

2. **Organization Custom Instructions** (Preview): Copilot Business/Enterprise users can set organization-wide instructions via organization settings, which apply to all members across all repositories.

3. **Three-tier instruction hierarchy**: Personal > Repository (path-specific > repo-wide > agents.md) > Organization. All applicable instructions are combined and sent to Copilot.

4. **Copilot Spaces**: A new feature allowing users to organize context from multiple repositories, files, and custom content into shareable collections.

5. **Workarounds exist**: Git submodules, GitHub Actions for sync, or manual copy can be used to share instruction files across repositories.

## Detailed Analysis

### How `.github/copilot-instructions.md` Works

The repository custom instructions file is read from:
- **Location**: `.github/copilot-instructions.md` (repository-wide)
- **Path-specific**: `.github/instructions/*.instructions.md` (with glob patterns)
- **Agent instructions**: `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md` files

The file contains natural language instructions in Markdown format that are automatically appended to Copilot prompts when working in that repository context.

**Example structure:**
```markdown
# Project Overview
This project uses React and TypeScript...

## Coding Standards
- Use functional components
- Prefer early returns
- Use camelCase for variables
```

**Path-specific instructions** use frontmatter with glob patterns:
```markdown
---
applyTo: "**/*.ts,**/*.tsx"
---
Use TypeScript strict mode conventions...
```

### Can Copilot Reference Instructions from Another Repository?

**No.** There is no built-in mechanism to:
- Import instructions from external repositories
- Reference instructions via URL
- Inherit instructions from a parent/template repository

Each repository must contain its own `.github/copilot-instructions.md` file.

### Organization-Wide Instructions (Copilot Business/Enterprise)

Organizations with Copilot Business or Enterprise can set **organization custom instructions** that apply to all members:

**Setup:**
1. Go to Organization Settings > Copilot > Custom Instructions
2. Add natural language instructions in the text box
3. Click "Save changes"

**Limitations:**
- Currently only supported for:
  - Copilot Chat on GitHub.com
  - Copilot code review on GitHub.com
  - Copilot coding agent on GitHub.com
- **NOT supported** in VS Code, JetBrains, or other IDEs (as of Jan 2026)

**Precedence order:**
1. Personal instructions (highest priority)
2. Repository path-specific instructions
3. Repository-wide instructions (`.github/copilot-instructions.md`)
4. Agent instructions (`AGENTS.md`)
5. Organization instructions (lowest priority)

### Copilot Spaces - Cross-Repository Context Sharing

**Copilot Spaces** is a newer feature that partially addresses the need for shared context:

- Organize context from **multiple repositories** in one place
- Include code, PRs, issues, files, images, and free-text notes
- Share spaces with team members or publicly
- Context stays in sync as files change

**Use cases:**
- Cross-repo project context
- Team onboarding materials
- Shared documentation and standards

**Limitations:**
- Available only in Copilot Chat on GitHub.com
- Can be used in IDEs via GitHub MCP server
- Does not replace custom instructions (different purpose)

### Workarounds for Sharing Instructions Across Repos

#### 1. Git Submodules
```bash
# Add shared instructions as a submodule
git submodule add https://github.com/org/shared-copilot-instructions .github/shared
```

Then reference or symlink the instructions file.

#### 2. GitHub Actions Sync
Create a workflow that copies instructions from a central repository:

```yaml
name: Sync Copilot Instructions
on:
  schedule:
    - cron: '0 0 * * *'
  workflow_dispatch:

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Fetch shared instructions
        run: |
          curl -o .github/copilot-instructions.md \
            https://raw.githubusercontent.com/org/shared-instructions/main/copilot-instructions.md
      - name: Commit changes
        run: |
          git config user.name "github-actions"
          git config user.email "actions@github.com"
          git add .github/copilot-instructions.md
          git diff --staged --quiet || git commit -m "Sync Copilot instructions"
          git push
```

#### 3. Repository Templates
Include `.github/copilot-instructions.md` in your organization's repository templates so new repositories inherit the base instructions.

#### 4. Manual Copy with Version Control
Maintain a "source of truth" repository and manually update other repos when instructions change.

### Enterprise Policy Controls

Enterprise owners can control Copilot features via policies:

- Navigate to Enterprise Settings > AI Controls > Copilot
- Configure which features are enabled/disabled
- Set organization-level delegation

Policies control availability but **do not provide shared instruction mechanisms**.

## Feature Support Matrix

| Instruction Type | VS Code | JetBrains | GitHub.com | Coding Agent |
|-----------------|---------|-----------|------------|--------------|
| Repository-wide | Yes | Yes | Yes | Yes |
| Path-specific | Yes | No | Yes | Yes |
| Agent instructions | Yes | Yes | Yes | Yes |
| Organization | No | No | Yes | Yes |
| Personal | Yes | Yes | Yes | N/A |

## Sources

| # | Source | Key Contribution |
|---|--------|------------------|
| 1 | [GitHub Docs - Repository Custom Instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions) | Official documentation on copilot-instructions.md |
| 2 | [GitHub Docs - Organization Custom Instructions](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-organization-instructions) | Enterprise/org-level instruction setup |
| 3 | [GitHub Docs - Response Customization](https://docs.github.com/en/copilot/concepts/prompting/response-customization) | Overview of all customization options |
| 4 | [GitHub Docs - Managing Enterprise Policies](https://docs.github.com/en/copilot/how-tos/administer-copilot/manage-for-enterprise/manage-enterprise-policies) | Enterprise policy configuration |
| 5 | [GitHub Docs - Copilot Spaces](https://docs.github.com/en/copilot/concepts/context/spaces) | Cross-repo context sharing via Spaces |

## Questions for Further Research

- [ ] Will GitHub add cross-repository instruction references in the future?
- [ ] Can MCP servers be used to inject shared instructions?
- [ ] How do prompt files (`.prompt.md`) interact with custom instructions?
- [ ] Are there plans to support organization instructions in IDEs?

## Related Research

- GitHub Copilot Extensions may provide additional customization options
- Model Context Protocol (MCP) could enable dynamic instruction injection
