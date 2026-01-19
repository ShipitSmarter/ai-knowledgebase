---
name: github-issue-tracker
description: Update and maintain GitHub issues during development. Add progress comments, handle blockers, link PRs, and close issues with summaries. Use when user asks to update an issue, add a comment, mark progress, or close an issue.
---

# GitHub Issue Tracker

Help engineers keep GitHub issues updated and stakeholders informed during development.

## Trigger

When user asks to:
- Update issue #X with progress
- Add a comment to an issue
- Mark an issue as blocked or in progress
- Close an issue with a summary
- Link a PR to an issue
- Change issue labels or assignees

## Prerequisites

Requires GitHub CLI (`gh`) authenticated. See [GitHub Setup](../../opencode/github/SETUP.md).

## Process

### Step 1: Identify the Issue

Get the issue number and repository. If not provided, ask:
- What's the issue number?
- Which repository? (default to recent or ask)

Verify the issue exists:
```bash
gh issue view <number> --repo ShipitSmarter/<repo> --json title,state,labels
```

### Step 2: Determine Operation

| Operation | When to Use |
|-----------|-------------|
| **Add comment** | Progress update, findings, questions |
| **Update labels** | Status change (wip, blocked) |
| **Edit body** | Add technical details or update requirements |
| **Close** | Work complete, with summary |
| **Reopen** | Issue needs more work |
| **Link PR** | Connect implementation to issue |

### Step 3: Execute Operation

#### Add Progress Comment

```bash
gh issue comment <number> --repo ShipitSmarter/<repo> --body "$(cat <<'EOF'
### Progress Update

**Status**: In progress

**Completed**:
- [x] <what's done>

**Next**:
- [ ] <what's remaining>

**Notes**: <any findings or context>
EOF
)"
```

#### Add Blocker Comment

```bash
gh issue comment <number> --repo ShipitSmarter/<repo> --body "$(cat <<'EOF'
### Blocked

**Blocked by**: <reason or link to blocking issue>

**Impact**: <what this delays>

**Need**: <what's required to unblock>
EOF
)"
```

#### Add Question/Discussion Comment

```bash
gh issue comment <number> --repo ShipitSmarter/<repo> --body "$(cat <<'EOF'
### Question

<question or topic for discussion>

**Context**: <relevant background>

**Options**:
1. <option A>
2. <option B>

cc @<stakeholder>
EOF
)"
```

#### Update Labels

Add label:
```bash
gh issue edit <number> --repo ShipitSmarter/<repo> --add-label "wip"
```

Remove label:
```bash
gh issue edit <number> --repo ShipitSmarter/<repo> --remove-label "wip"
```

Common status labels:
| Label | Meaning |
|-------|---------|
| `wip` | Work in progress |
| `blocked` | Waiting on something |
| `discussion` | Needs feedback |

#### Edit Issue Body

```bash
gh issue edit <number> --repo ShipitSmarter/<repo> --body "<new body>"
```

Use this to:
- Add technical implementation notes
- Update requirements based on findings
- Add links to related resources

#### Close Issue

With comment:
```bash
gh issue close <number> --repo ShipitSmarter/<repo> --comment "$(cat <<'EOF'
### Completed

**PR**: #<pr-number>

**Summary**: <what was implemented>

**Notes**: <any follow-up items or caveats>
EOF
)"
```

Without comment:
```bash
gh issue close <number> --repo ShipitSmarter/<repo>
```

#### Reopen Issue

```bash
gh issue reopen <number> --repo ShipitSmarter/<repo>
```

Optionally add comment explaining why:
```bash
gh issue comment <number> --repo ShipitSmarter/<repo> --body "Reopening because <reason>"
```

#### Link PR to Issue

Option 1: In PR description, use closing keywords:
- `Fixes #<number>`
- `Closes #<number>`
- `Resolves #<number>`

Option 2: Add comment on issue:
```bash
gh issue comment <number> --repo ShipitSmarter/<repo> --body "Implementation PR: #<pr-number>"
```

Option 3: When creating PR:
```bash
gh pr create --title "feat: <title>" --body "Fixes #<number>"
```

### Step 4: Confirm Success

After executing, verify the update:
```bash
gh issue view <number> --repo ShipitSmarter/<repo> --json title,state,labels,comments --comments
```

## Comment Templates

### Progress Update
```markdown
### Progress Update

**Status**: In progress | Ready for review | Blocked

**Completed**:
- [x] Item 1
- [x] Item 2

**Remaining**:
- [ ] Item 3
- [ ] Item 4

**Notes**: <findings, decisions, or context>
```

### Blocker
```markdown
### Blocked

**Blocked by**: <issue link or external dependency>

**Impact**: <what this delays or affects>

**Need**: <what's required to unblock>

**ETA**: <when we expect to be unblocked>
```

### Technical Findings
```markdown
### Technical Notes

**Investigation**: <what was looked into>

**Findings**:
- <finding 1>
- <finding 2>

**Recommendation**: <proposed approach>

**Risks**: <potential issues to consider>
```

### Completion Summary
```markdown
### Completed

**PR**: #<number>

**What was done**:
- <change 1>
- <change 2>

**Testing**: <how it was verified>

**Notes**: <caveats, follow-ups, or documentation>
```

### Scope Change
```markdown
### Scope Update

**Original scope**: <what was planned>

**Change**: <what's being added/removed>

**Reason**: <why the change>

**Impact**: <effect on timeline or other work>

cc @<stakeholder>
```

## Output to User

After each operation:
1. Confirm what was done
2. Show link to updated issue
3. Note any warnings (e.g., label not found)

## Error Handling

**Issue not found:**
- Verify issue number and repository
- Check if issue was transferred or deleted

**Permission denied:**
- Verify repository access
- Check if issue is locked

**Label not found:**
- Skip adding that label
- Inform user of available labels

## Tool Reference

| Command | Purpose |
|---------|---------|
| `gh issue view <n>` | View issue details |
| `gh issue comment <n>` | Add comment |
| `gh issue edit <n>` | Edit title, body, labels |
| `gh issue close <n>` | Close issue |
| `gh issue reopen <n>` | Reopen issue |
| `gh issue list` | Find issues |
