# GitHub Copilot Research

## Overview
Research on GitHub Copilot features, customization options, and enterprise capabilities.

## Documents
| Date | Topic | Status |
|------|-------|--------|
| 2026-01-19 | [Custom Instructions - External Repository References](./2026-01-19-custom-instructions-external-repos.md) | draft |

## Key Insights

### Custom Instructions Architecture
- Three-tier system: Personal > Repository > Organization
- No native cross-repository instruction imports
- Organization instructions only work on GitHub.com (not IDEs)

### Workarounds for Shared Instructions
1. Git submodules
2. GitHub Actions sync workflows
3. Repository templates
4. Manual synchronization

### Alternative: Copilot Spaces
- Can aggregate context from multiple repositories
- Available on GitHub.com and via MCP in IDEs
- Different purpose than custom instructions

## Open Questions
- [ ] Future roadmap for cross-repo instructions?
- [ ] MCP-based instruction injection possibilities?
