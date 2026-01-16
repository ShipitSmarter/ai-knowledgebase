# Testing Strategy Research

## Overview

Research on modern testing strategies for applications with C# backends and Vue.js frontends, using Playwright for E2E testing and Vitest for unit/component testing.

## Documents

| Date | Topic | Status |
|------|-------|--------|
| 2026-01-16 | [Testing Strategy One-Pager](./2026-01-16-testing-strategy-one-pager.md) | draft |
| 2026-01-16 | [Modern Testing Strategy (detailed)](./2026-01-16-modern-testing-strategy.md) | draft |

## Key Insights

- **Test pyramid remains foundational**: Many unit tests, some integration tests, few E2E tests
- **Test behavior, not implementation**: Makes tests resilient to refactoring
- **Coverage is an indicator, not a goal**: High coverage doesn't guarantee quality
- **Fast feedback enables velocity**: Automated tests transform days into seconds

## Open Questions

- [ ] Best patterns for testing authentication flows in Playwright
- [ ] Strategies for testing real-time features (WebSockets, SignalR)
- [ ] Test data management for integration tests
- [ ] Measuring and reducing test flakiness
