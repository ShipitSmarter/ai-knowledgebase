# Ideas Backlog

Ideas for future skills, research, and improvements. Add new ideas at the top.

## Skills to Build

*(No pending skills)*

---

## Research to Do

### Viya Data Model Completion
From `research/viya-data-model/`:
- Document FTP database collections in detail
- Map all event types and their payloads
- Document index strategies per collection
- Add collection size estimates for production

### MongoDB Development Setup
From `research/mongodb-development/`:
- Configure MCP for multiple ShipitSmarter databases
- Document common shipping database aggregation patterns
- Set up Atlas API service account with minimal permissions

### Testing Best Practices
From `research/testing-strategy/`:
- Best patterns for testing authentication flows in Playwright
- Strategies for testing real-time features (WebSockets, SignalR)
- Test data management for integration tests
- Measuring and reducing test flakiness

### Git Co-Author Attribution for AI Sessions
- How to use `Co-authored-by` trailers in git commits
- Best practices for attributing AI-assisted code
- Options for saving session metadata (AI model, conversation context)
- Potential formats: commit trailers, `.ai-session` files, PR descriptions
- Team conventions for transparency about AI involvement
- Reference: [GitHub docs on commits with multiple authors](https://docs.github.com/en/pull-requests/committing-changes-to-your-project/creating-and-editing-commits/creating-a-commit-with-multiple-authors)

### AI Primitives: Skills, Agents, and Commands
- **Atomic skills**: How to decompose skills into smaller, composable units
- **Skill composition**: Patterns for skills calling other skills
- **Agent vs skill vs command**: When to use each primitive
  - Commands: User-triggered actions (slash commands)
  - Skills: Reusable knowledge/workflows loaded on demand
  - Agents: Autonomous actors with goals and tool access
- **Current landscape**: How Claude, OpenCode, Cursor, Copilot handle these concepts
- **Interoperability**: Can skills be shared across AI tools?
- **Design principles**: Single responsibility, clear interfaces, testability

---

## Improvements

### ~~Use OpenCode Remote Config (.well-known/opencode)~~ - NOT VIABLE
- **Finding**: Remote config is an **enterprise feature** tied to SSO/authentication
- It's not a self-serve "point to a public repo URL" solution
- Requires contacting Anomaly for enterprise setup
- Reference: [OpenCode enterprise docs](https://opencode.ai/docs/enterprise/)
- **Current approach (symlinks via setup.sh) remains best option for team sharing**

### ~~Add $schema to OpenCode Config~~ - DONE
- Already present in `.opencode/config.json`
- Schema URL: `https://opencode.ai/config.json`

---
