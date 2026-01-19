# ShipitSmarter Development Guidelines

This file provides context for GitHub Copilot when working in ShipitSmarter repositories.

## Company Context

ShipitSmarter is a B2B SaaS company providing transport management solutions (TMS) for logistics operations. Our main product is Viya - a platform for shipment management, rate calculation, and carrier integrations.

## Code Style

### General Principles
- Write clear, self-documenting code
- Prefer explicit over implicit
- Follow existing patterns in the codebase
- Add comments for complex business logic

### TypeScript
- Use strict TypeScript - avoid `any`, prefer `unknown` with type guards
- Define interfaces for all props, API responses, and function parameters
- Use generated types from `@/generated/*` for API responses
- Prefer `type` for unions/primitives, `interface` for objects

### Vue 3 (viya-app)
- Use Composition API with `<script setup lang="ts">`
- Follow script order: types → composables → constants → services → props/emits → refs → computed → functions → watchers → lifecycle
- Use Tailwind CSS classes - avoid `<style>` blocks
- Always check Storybook (storybook.viyatest.it) for existing components

### Testing
- Unit tests: Vitest + vue-test-utils
- E2E tests: Playwright in `playwright/` directory
- Test file naming: `*.spec.ts`
- Use `data-testid` attributes for E2E selectors

## Git Conventions

### Commit Messages
Use conventional commit format:
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code change that neither fixes nor adds
- `test:` - Adding tests
- `docs:` - Documentation only
- `chore:` - Maintenance tasks

### Branch Naming
- `feature/<description>` - New features
- `fix/<description>` - Bug fixes
- `refactor/<description>` - Refactoring

### Pull Requests
- Include clear description of changes
- Reference related issues
- Ensure all checks pass before requesting review

## Project Structure (viya-app)

```
src/
├── components/     # Reusable Vue components by feature
├── views/          # Page-level components
├── composables/    # Vue 3 composables (use* pattern)
├── services/       # API service layer
├── store/          # Pinia stores
├── generated/      # Auto-generated API types
├── types/          # Shared TypeScript types
└── utils/          # Utility functions
```

## API Integration

- Services extend `BaseService` class
- Use `DataOrProblem<T>` for responses
- Import types from `@/generated/<domain>`
- Handle errors with `showToast()` method

## Resources

- UI Components: https://storybook.viyatest.it/
- Project Board: https://github.com/orgs/ShipitSmarter/projects/10
- AI Skills: https://github.com/ShipitSmarter/ai-knowledgebase
