# AI Agent Skills

This directory contains reusable skills that provide specialized guidance for common development tasks. Skills are compatible with **OpenCode**, **Claude**, and **GitHub Copilot**.

## Quick Reference

| Skill | Use When... |
|-------|-------------|
| [vue-component](#vue-component) | Creating or refactoring Vue components |
| [unit-testing](#unit-testing) | Writing unit tests with vitest |
| [playwright-test](#playwright-test) | Writing E2E tests |
| [api-integration](#api-integration) | Working with API services and generated types |
| [typescript-helpers](#typescript-helpers) | Defining types, interfaces, and type guards |
| [codebase-navigation](#codebase-navigation) | Finding files and understanding project structure |
| [docs-writing](#docs-writing) | Writing user-facing documentation |
| [github-workflow](#github-workflow) | Managing PRs, commits, and releases |
| [pr-review](#pr-review) | Reviewing a PR before merge |
| [browser-debug](#browser-debug) | Debugging UI issues with headless browser |

---

## vue-component

**When to use:** Creating new Vue components, refactoring existing ones, or ensuring code follows project conventions.

### Example Prompts

```
Create a new ShipmentStatusBadge component that displays the shipment status with appropriate colors
```

```
Refactor UserProfileCard.vue to follow the correct script order
```

```
Add a loading state and error handling to the AddressSelector component
```

```
Convert this component to use Tailwind classes instead of scoped CSS
```

### What It Covers
- Script section ordering (types → composables → refs → computed → functions → lifecycle)
- Props/emits patterns with TypeScript
- Tailwind CSS usage (no scoped styles)
- Defensive rendering with `v-if`

---

## unit-testing

**When to use:** Writing unit tests for components, composables, utilities, or stores.

### Example Prompts

```
Write unit tests for the ShipmentStatusBadge component
```

```
Add tests for the formatPrice utility function including edge cases
```

```
Create test mocks for the ShipmentService
```

```
Test the useFormDirtyCheck composable
```

### What It Covers
- vitest + vue-test-utils patterns
- Component mounting with `factory` helper
- Mock data organization in separate files
- Testing stores, composables, and utilities
- Browser API mocks (ResizeObserver, etc.)

---

## playwright-test

**When to use:** Writing E2E tests, debugging test failures, or understanding test patterns.

### Example Prompts

```
Write a Playwright test for the shipment creation flow
```

```
Add a test that verifies the copy-paste functionality in the rates surcharges table
```

```
The pickup scheduling test is flaky - help me debug it
```

```
Create test helpers for the address book page
```

### What It Covers
- Test file structure and naming
- Page Object patterns and helpers
- Waiting strategies and selectors
- Mock data organization
- Debugging flaky tests

---

## api-integration

**When to use:** Working with API services, generated types, or backend integrations.

### Example Prompts

```
Create a service for the new billing API endpoints
```

```
How do I use the generated Shipment types from @/generated/shipping?
```

```
Add error handling to the RatesService.getContract method
```

```
Update the carrier profile service to use the new API response format
```

### What It Covers
- Generated types from OpenAPI specs
- Service class patterns
- Error handling and retries
- Type-safe API calls

---

## typescript-helpers

**When to use:** Defining types, interfaces, type guards, or working with TypeScript patterns.

### Example Prompts

```
Create a type guard for the Shipment interface
```

```
What's the difference between type and interface? When should I use each?
```

```
Help me type this complex function with generics
```

```
How do I properly type a nullable ref in Vue?
```

### What It Covers
- Type vs interface usage
- Generated API types from `@/generated/`
- Type guards for runtime checking
- Utility types (Partial, Pick, Omit, etc.)
- Function and generic typing

---

## codebase-navigation

**When to use:** Finding files, understanding project structure, or exploring the codebase.

### Example Prompts

```
Where are the shipment-related components located?
```

```
How is the router organized in this project?
```

```
Where do I find the API service for addresses?
```

```
What's the directory structure for adding a new feature?
```

### What It Covers
- Project directory structure
- Where to find components, services, stores
- Generated types location
- Test file organization
- Import aliases and patterns

---

## docs-writing

**When to use:** Creating or updating user-facing documentation in the in-app docs system.

### Example Prompts

```
Write documentation for the new bulk shipment export feature
```

```
Update the pickup scheduling docs to include the new recurring pickup option
```

```
Create a troubleshooting guide for common rate calculation issues
```

```
Review the address book documentation for clarity and completeness
```

### What It Covers
- Writing for non-technical users
- Voice and tone guidelines
- Doc structure and navigation
- Screenshots and examples

---

## github-workflow

**When to use:** Managing PRs, writing commit messages, or preparing releases.

### Example Prompts

```
Help me write a good commit message for these changes
```

```
Create a PR description for the bulk actions feature
```

```
What should the release notes look like for this PR?
```

```
Review my branch naming - is 'feature/new-thing' correct?
```

### What It Covers
- Conventional commit format
- Branch naming conventions
- PR descriptions and checklists
- Release notes formatting

---

## pr-review

**When to use:** Reviewing a PR before merge, verifying checklist items, or writing release notes.

### Example Prompts

```
Review this PR
```

```
Check if PR #2629 is ready to merge
```

```
Verify the checklist items for my current PR
```

```
Write release notes for PR #2580
```

### What It Covers
- Automated checks (lint, types, build)
- Code quality review
- Test coverage evaluation
- Plan completion verification
- Release notes generation

---

## browser-debug

**When to use:** Debugging UI issues, investigating visual problems, or when tests fail unexpectedly.

### Example Prompts

```
The shipment list isn't rendering - can you check what's happening in the browser?
```

```
Take a screenshot of the rates configuration page after loading
```

```
Debug why the modal isn't closing when clicking outside
```

```
Check the network requests when the address lookup fails
```

### What It Covers
- Chrome DevTools MCP integration
- Screenshot capture
- Console log inspection
- Network request analysis
- DOM inspection

---

## How Skills Work

### In OpenCode

Skills are loaded automatically when you use specific prompts, or you can load them explicitly:

```
/skill vue-component
```

### In GitHub Copilot

Skills are available as path-specific instructions in `.github/instructions/`. Copilot loads them based on the files you're working with.

### In Claude

Reference the skill file directly or copy the relevant sections into your conversation context.

---

## Skill Format

Skills follow the [Agent Skills Specification](https://agentskills.io/specification), an open standard for portable AI agent skills.

### SKILL.md Structure

Each skill requires a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: skill-name                    # Required: lowercase, hyphens only
description: What it does and when  # Required: explain what AND when to use
license: MIT                        # Optional: license for the skill
compatibility: Required tools       # Optional: environment requirements
metadata:
  author: shipitsmarter
  version: "1.0"
---

# Skill Title

Markdown content with instructions, examples, and guidelines.
```

### Field Requirements

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | 1-64 chars, lowercase + hyphens, must match directory name |
| `description` | Yes | 1-1024 chars, explain what the skill does AND when to use it |
| `license` | No | License name (e.g., `MIT`, `Apache-2.0`) |
| `compatibility` | No | Environment requirements (e.g., "Requires git CLI and gh") |
| `metadata` | No | Key-value pairs for author, version, etc. |

---

## Creating New Skills

We have an AI assistant for writing skills in the [ai-knowledgebase](https://github.com/ShipitSmarter/ai-knowledgebase) repository. Use it to generate spec-compliant skills.

### Manual Creation

If creating manually:

1. Create a directory: `agents/skills/<skill-name>/`
2. Add a `SKILL.md` file following the format above
3. Create a symlink in `.opencode/skill/`:
   ```bash
   cd .opencode/skill
   ln -s ../../agents/skills/<skill-name> <skill-name>
   ```
4. Add Copilot instructions in `.github/instructions/<skill-name>.instructions.md`

### Validation

Use the [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) validator:

```bash
skills-ref validate ./agents/skills/<skill-name>
```
