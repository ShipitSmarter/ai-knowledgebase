---
name: github-issue-creator
description: Create well-structured GitHub issues with appropriate templates for bugs, features, papercuts, and tasks. Automatically adds issues to Viya project board. Use when user asks to create an issue, write a user story, report a bug, or request a feature.
---

# GitHub Issue Creator

Create well-structured GitHub issues for ShipitSmarter repositories with appropriate templates based on issue type. Issues are automatically added to the Viya project board.

## Trigger

When user asks to:
- Create a new issue or user story
- Report a bug
- Request a feature
- Log a papercut (small UI issue)
- Create a task

## Prerequisites

Requires GitHub CLI (`gh`) authenticated with project scope. See [GitHub Setup](../../opencode/github/SETUP.md).

```bash
# Add project scope (required for project board integration)
gh auth refresh -s project
```

**Verify auth:**
```bash
gh auth status
# Should show 'project' in Token scopes
```

## Project Board

All issues are added to the **Viya Project Board**:
- **Organization**: ShipitSmarter
- **Project Number**: 10
- **URL**: https://github.com/orgs/ShipitSmarter/projects/10

## Process

### Step 1: Determine Issue Type

Ask the user what type of issue they want to create:

| Type | Description | Template |
|------|-------------|----------|
| **Bug** | Something isn't working correctly | Problem-focused with repro steps |
| **Feature** | New functionality request | User story format with acceptance criteria |
| **Papercut** | Small UI/UX polish item | Brief description with location |
| **Task** | Technical work without user-facing change | Requirements and done criteria |

### Step 2: Gather Information

Based on issue type, ask clarifying questions:

**For Bug:**
- What is happening? (actual behavior)
- What should happen? (expected behavior)
- Steps to reproduce?
- Any error messages or screenshots?
- Which environment? (URL if applicable)

**For Feature:**
- Who is the user? (role/persona)
- What do they want to do?
- Why? (the benefit/value)
- Acceptance criteria? (how do we know it's done)
- Any mockups or examples?

**For Papercut:**
- What's the UI issue?
- Where in the app? (page/component)
- Screenshot if possible?
- Suggested improvement?

**For Task:**
- What technical work is needed?
- Why is it needed? (context)
- What are the requirements?
- How do we know it's done?

### Step 3: Select Repository

Ask which repository the issue belongs to:

| Repository | Purpose |
|------------|---------|
| `ShipitSmarter/viya-app` | Frontend Vue.js application |
| `ShipitSmarter/shipping` | Backend shipping microservice |
| `ShipitSmarter/stitch` | Integration engine |
| `ShipitSmarter/viya-core` | Shared core libraries |
| `ShipitSmarter/hooks` | Webhooks & scheduler service |
| `ShipitSmarter/rates` | Rate management |
| `ShipitSmarter/ftp` | SFTP functionality |
| `ShipitSmarter/authorizing` | Authorization service |
| `ShipitSmarter/stitch-integrations` | Carrier integrations |

### Step 4: Format Issue

Use the appropriate template from [TEMPLATES.md](references/TEMPLATES.md).

**Label Mapping:**
| Type | Labels |
|------|--------|
| Bug | `bug` |
| Feature | `enhancement` or `feature 🏆` |
| Papercut | `papercut` |
| Task | (none by default) |

### Step 5: Preview with User

Before creating, show the formatted issue:

```
## Preview

**Repository:** ShipitSmarter/<repo>
**Title:** <title>
**Labels:** <labels>

---
<formatted body>
---

Create this issue? (yes/no/edit)
```

### Step 6: Create Issue

```bash
gh issue create \
  --repo ShipitSmarter/<repo> \
  --title "<title>" \
  --label "<labels>" \
  --body "<body>"
```

Capture the issue URL from the output.

### Step 7: Add to Viya Project Board

**Always add the issue to the Viya project board:**

```bash
gh project item-add 10 --owner ShipitSmarter --url <issue-url>
```

This returns a project item ID that can be used for status updates.

**If project scope is missing**, the command will fail. Inform the user:
```
Issue created successfully, but could not add to project board.
Run: gh auth refresh -s project
Then manually add at: https://github.com/orgs/ShipitSmarter/projects/10
```

## Output to User

After creating the issue:
1. Confirm creation with issue number and URL
2. Show which labels were applied
3. Confirm added to Viya project board (or provide manual instructions)
4. Suggest next steps (assign, update status in project board)

## Error Handling

**If repository doesn't exist or no access:**
- List available repositories
- Ask user to select from list

**If label doesn't exist:**
- Create issue without that label
- Inform user the label wasn't found

**If project scope missing:**
- Create issue successfully
- Inform user to run `gh auth refresh -s project` for project board features

## Tool Reference

| Command | Purpose |
|---------|---------|
| `gh issue create` | Create the issue |
| `gh issue list --repo <repo> --search "<query>"` | Check for duplicates |
| `gh label list --repo <repo>` | List available labels |
| `gh repo list ShipitSmarter` | List available repositories |
| `gh project item-add` | Add issue to project board |
