---
topic: Testing Strategy One-Pager
date: 2026-01-16
project: testing-strategy
status: draft
tags: [testing, vitest, playwright, csharp, vue]
---

# Testing Strategy One-Pager

**Stack**: C# .NET Backend | Vue.js Frontend | Vitest | Playwright

---

## WHY: The Business Case for Testing

| Benefit | Impact |
|---------|--------|
| **Catch bugs early** | Bugs found in development cost 10-100x less than in production |
| **Enable fast delivery** | Automated tests transform days of manual QA into seconds |
| **Confidence to refactor** | Safety net allows continuous improvement without fear |
| **Living documentation** | Tests explain expected behavior better than comments |
| **Team velocity** | New developers understand code faster through tests |

> "With unit testing, you can rerun your entire suite of tests after every build or even after you change a line of code." - Microsoft

---

## HOW: The Testing Pyramid

```
        /\          E2E (Playwright) - ~5%
       /  \         Critical user journeys only
      /----\
     /      \       Integration Tests - ~15%
    /--------\      API contracts, database, services
   /          \
  /------------\    Unit Tests (xUnit/Vitest) - ~80%
 /              \   Business logic, components, utilities
```

### What to Test at Each Layer

| Layer | C# Backend | Vue Frontend |
|-------|------------|--------------|
| **Unit** | Business logic, validators, utilities | Components, composables, stores |
| **Integration** | Database queries, external APIs | API calls with MSW/mocks |
| **E2E** | Critical paths: login, checkout, core workflows |

### Key Practices

1. **Test behavior, not implementation** - Tests survive refactoring
2. **Arrange-Act-Assert** - Clear test structure
3. **One assertion per test** - Easier debugging
4. **Resilient locators** - `getByRole('button', {name: 'Submit'})` over `.btn-primary`
5. **Isolated tests** - No shared state between tests

---

## WHAT: Measuring Success

### Coverage Metrics (Guidance, Not Goals)

| Metric | Recommended | Notes |
|--------|-------------|-------|
| Line coverage | 70-80% baseline | Track trends, not absolutes |
| Branch coverage | 60-70% | More meaningful than lines |
| Critical paths | 90%+ | Payment, auth, core business |

> "A high code coverage percentage isn't an indicator of success... it just represents the amount of code covered by unit tests." - Microsoft

### What to Measure Beyond Coverage

- **Test execution time** - Fast feedback loops enable CI/CD
- **Flaky test rate** - <1% target, fix immediately
- **Bug escape rate** - Bugs reaching production despite tests
- **Test maintenance cost** - Tests shouldn't slow development

### Prioritization Matrix

| Priority | What to Test | Why |
|----------|--------------|-----|
| **High** | Payment flows, authentication, data integrity | Business critical |
| **High** | Complex business rules | Many edge cases |
| **Medium** | Integration points | Contracts between systems |
| **Medium** | High-traffic features | Most user exposure |
| **Low** | Simple CRUD, getters/setters | Low complexity |
| **Skip** | Framework code | Test your code, not theirs |

---

## Quick Reference: Our Stack

| Tool | Purpose | Docs |
|------|---------|------|
| **xUnit** | C# unit tests | [docs](https://xunit.net/) |
| **Moq** | C# mocking | [github](https://github.com/moq/moq4) |
| **Vitest** | Vue unit/component tests | [vitest.dev](https://vitest.dev/) |
| **Vue Test Utils** | Component mounting | [test-utils.vuejs.org](https://test-utils.vuejs.org/) |
| **Playwright** | E2E testing | [playwright.dev](https://playwright.dev/) |

---

## Sources

- [The Practical Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html) - Martin Fowler
- [Unit Testing Best Practices](https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices) - Microsoft
- [Playwright Best Practices](https://playwright.dev/docs/best-practices)
- [Vue.js Testing Guide](https://vuejs.org/guide/scaling-up/testing.html)
