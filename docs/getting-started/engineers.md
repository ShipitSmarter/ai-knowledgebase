# AI Tools for Engineers

**Get AI help writing code, tests, and documentation for Viya.**

This guide covers the AI tools for developers working on viya-app, shipping services, and other ShipitSmarter repositories.

---

## Quick Setup

Run this in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/ShipitSmarter/ai-knowledgebase/main/tools/setup.sh | bash
```

Then restart your terminal. All skills and commands are now available in any project.

---

## Your Main Tools

### Development Skills

These skills teach AI our patterns and conventions:

| Skill | What it helps with |
|-------|-------------------|
| `vue-component` | Writing Vue 3 components with our patterns |
| `unit-testing` | Writing Vitest tests |
| `playwright-test` | Writing E2E browser tests |
| `api-integration` | Working with our API types and services |
| `typescript-helpers` | TypeScript types and utility functions |
| `codebase-navigation` | Understanding project structure |
| `github-workflow` | Pull requests and commit messages |
| `pr-review` | Reviewing code |
| `browser-debug` | Debugging browser issues |
| `viya-dev-environment` | Managing local dev environment, testing PR builds |

**Example prompts:**
```
Create a Vue component for displaying carrier profiles

Write unit tests for the shipment service

Help me debug why the tracking page isn't loading
```

### GitHub Workflow

| Skill/Command | What it does |
|---------------|-------------|
| `github-issue-creator` | Create well-structured issues |
| `github-issue-tracker` | Update issues and move them on project boards |
| `github-workflow` | PR and commit conventions |

**Creating issues:**
```
Create an issue for adding PDF export to the reports page
```

Issues should be **one per feature** - implementation details go in a branch `PLAN.md`, not fragmented across multiple issues.

---

## Frontend Design Commands

When working on UI, these commands help ensure quality:

| Command | When to use |
|---------|-------------|
| `/i-audit` | Check accessibility, performance, responsive issues |
| `/i-polish` | Final cleanup before shipping |
| `/i-simplify` | Remove unnecessary complexity |
| `/i-harden` | Add error handling, i18n, edge cases |
| `/i-optimize` | Improve performance |
| `/i-extract` | Pull code into reusable components |

**Example:**
```
/i-audit the new shipment form

/i-harden - add proper error states and loading indicators
```

---

## Testing Backend PRs Locally

When you need to test a shipping, auditor, or other backend service PR against the local viya-app:

### Quick Method

```
/test-pr shipping 1277
```

This will:
1. Check if the PR build succeeded
2. Get the correct image version
3. Update your `dev/.env`
4. Offer to restart the service

### Manual Method

1. **Get the PR build version:**
   ```bash
   gh pr checks <PR_NUMBER> --repo ShipitSmarter/<repo>
   gh run list --repo ShipitSmarter/<repo> --branch <branch> --limit 1 --json databaseId
   ```
   Version format: `0.0.0-pr.<PR_NUMBER>.<RUN_ID>`

2. **Update `/home/wouter/git/viya-app/dev/.env`:**
   ```
   SHIPPING_VERSION=0.0.0-pr.1277.21150237490
   ```

3. **Restart the service:**
   ```bash
   cd /home/wouter/git/viya-app/dev
   docker compose stop shipping && docker compose rm -f shipping && docker compose pull shipping && docker compose up -d shipping
   ```

### Reset to Latest
Edit `dev/.env` and set versions back to `latest`, then restart.

---

## Workflow: Feature Development

### 1. Start with an Issue

```
Create an issue for: Users can filter consignments by date range
```

This creates ONE focused issue with acceptance criteria.

### 2. Create a Branch with a Plan

```bash
git checkout -b feature/123-date-range-filter
```

Ask AI to create a plan:
```
Create a PLAN.md for implementing the date range filter feature
```

This creates `docs/PLAN.md` in your branch with:
- Technical approach
- Files to modify
- Step-by-step tasks
- Testing strategy

### 3. Implement with AI Help

```
Following the plan, let's start with the API integration

Now create the Vue component for the date picker

Write tests for the date range filter logic
```

### 4. Polish Before PR

```
/i-audit

/i-polish
```

### 5. Create PR

```
Create a PR for this branch
```

---

## Testing Workflow

### Unit Tests
```
Write unit tests for the ConsignmentService.filterByDateRange method
```

The AI uses our Vitest patterns and mocking conventions.

### E2E Tests
```
Write a Playwright test for the shipment creation flow
```

The AI knows our page object patterns and test utilities.

### Test Coverage
```
What's the test coverage for the shipment module? What's missing?
```

---

## Debugging

### Browser Issues
```
The tracking map isn't rendering. Here's the console error: [paste error]
```

### API Issues
```
The consignment endpoint returns 500. Here's the request and response: [paste]
```

### Performance Issues
```
The shipment list is slow with 1000+ items. How can we optimize it?
```

---

## Code Review Help

### Reviewing Someone Else's PR
```
Review this PR: https://github.com/ShipitSmarter/viya-app/pull/123
```

### Getting Your Code Reviewed
```
Review my changes in the current branch for potential issues
```

---

## Repository-Specific Context

Skills automatically adapt to the repository you're working in:

| Repository | Additional Context |
|------------|-------------------|
| `viya-app` | Vue 3, TypeScript, Vite, our component patterns |
| `shipping` | C#, .NET, our API conventions |
| `stitch` | Integration engine patterns |

---

## Tips for Better Results

### Be Specific About the Context
```
Good: "Create a composable for managing shipment filters that integrates with the existing useShipmentList"
Bad: "Create a composable"
```

### Reference Existing Code
```
"Follow the same pattern as the ConsignmentTable component"
```

### Explain the Why
```
"We need to batch these API calls because the carrier has rate limits of 10 requests/second"
```

### Ask for Explanations
```
"Explain why you chose this approach over using a computed property"
```

---

## Troubleshooting

### "Skills aren't loading"
```bash
echo $OPENCODE_CONFIG_DIR
# Should show: ~/.shipitsmarter/ai-knowledgebase
```

If empty, restart your terminal after setup.

### "AI doesn't know our patterns"
Make sure you're in a project directory. Skills work best when AI can see your codebase.

### "Generated code doesn't match our style"
Reference a specific file:
```
"Follow the code style in src/components/ShipmentCard.vue"
```

---

## Getting Help

- **Setup issues?** Check the troubleshooting section or ask in Slack
- **Missing a skill?** Create an issue or PR in this repository
- **Bug in generated code?** The AI learns from feedback - tell it what went wrong
