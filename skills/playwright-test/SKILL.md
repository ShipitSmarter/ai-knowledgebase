---
name: playwright-test
description: Writing Playwright E2E tests following project patterns and fixtures. Use when creating new E2E tests, debugging test failures, or setting up test helpers and page objects.
license: MIT
compatibility: Requires Node.js and Playwright. Tests run in playwright/ directory.
metadata:
  author: shipitsmarter
  version: "1.0"
---

# Playwright Test Skill

Guidelines for writing Playwright E2E tests in this project.

---

## Project structure

```
playwright/
├── tests/
│   ├── app-tests/           # Feature tests organized by domain
│   │   ├── address/
│   │   ├── carrier-integration/
│   │   ├── configuration/
│   │   ├── consignment/
│   │   ├── shipment/
│   │   └── tokens/
│   ├── helpers/              # Shared utilities
│   │   ├── fixtures.ts       # Custom test fixtures
│   │   ├── functions.ts      # Helper functions
│   │   ├── consts.ts         # Constants
│   │   ├── TestId.ts         # Test ID helpers
│   │   └── wrappers/         # Page object wrappers
│   ├── users/                # User management tests
│   ├── onboarding/           # Onboarding flow tests
│   └── *.login.ts, *.logout.ts, *.setup.ts, *.teardown.ts
├── playwright.config.ts
└── package.json
```

---

## Running tests

```bash
# From project root
npm run playwright           # Run all tests
npm run playwright-ui        # Run with UI mode

# From playwright directory
cd playwright
npx playwright test                           # All tests
npx playwright test tests/app-tests/shipment  # Specific folder
npx playwright test --grep "create"           # By test name
npx playwright test --ui                      # Interactive UI
npx playwright test --debug                   # Debug mode
```

---

## Test file structure

```typescript
import { BASE_URL } from '~/auth-consts';
import { expect, test } from '~/helpers/fixtures';
import { navigateToHome } from '~/helpers/functions';
import MultiselectWrapper from '~/helpers/wrappers/MultiselectWrapper';

test.describe.serial('feature name', () => {
  test('01. Test case description', async ({ page }) => {
    // Arrange
    await navigateToHome(page);
    
    // Act
    await page.getByTestId('some-button').click();
    
    // Assert
    await expect(page.getByText('Expected text')).toBeVisible();
  });

  test('02. Another test case', async ({ adminRolePage }) => {
    const { page } = adminRolePage;
    // Use adminRolePage fixture for authenticated tests
  });
});
```

---

## Key conventions

### Use test.describe.serial for ordered tests

When tests depend on each other (e.g., create then verify):

```typescript
test.describe.serial('shipment flow', () => {
  test('01. Create shipment', async ({ page }) => { ... });
  test('02. Verify shipment was created', async ({ page }) => { ... });
});
```

### Number test names for clarity

Prefix tests with numbers to show execution order:
- `'01. Create basic shipment'`
- `'02. Verify created shipment'`
- `'03. Edit shipment details'`

---

## Playwright Best Practices

> Based on [Playwright's official best practices](https://playwright.dev/docs/best-practices)

### Testing philosophy

**Test user-visible behavior**
- Test what end users see and interact with
- Avoid relying on implementation details (CSS classes, DOM structure, function names)
- Your test should interact with the rendered output, not internal code

**Make tests isolated**
- Each test should be independent - own storage, cookies, data
- Use `beforeEach` hooks for common setup (like navigation or login)
- Avoid tests that depend on state from previous tests (unless using `test.describe.serial`)

**Avoid testing third-party dependencies**
- Don't test external sites or APIs you don't control
- Mock external dependencies using Playwright's Network API:

```typescript
await page.route('**/api/external-service', route => route.fulfill({
  status: 200,
  body: JSON.stringify({ data: 'mocked response' }),
}));
```

### Use web-first assertions

Always use async assertions that auto-wait and retry:

```typescript
// ✅ Good - waits for condition
await expect(page.getByText('welcome')).toBeVisible();

// ❌ Bad - doesn't wait, can cause flaky tests
expect(await page.getByText('welcome').isVisible()).toBe(true);
```

### Use locators effectively

**Chain and filter locators** for precision:

```typescript
// Find button within a specific list item
await page
  .getByRole('listitem')
  .filter({ hasText: 'Product 2' })
  .getByRole('button', { name: 'Add to cart' })
  .click();
```

**Prefer user-facing attributes:**

```typescript
// ✅ Good - resilient to DOM changes
page.getByRole('button', { name: 'submit' });
page.getByTestId('create-shipment-btn');
page.getByLabel('Reference number');

// ❌ Bad - fragile, breaks when CSS changes
page.locator('button.buttonIcon.episode-actions-later');
```

### Generate locators with codegen

Use Playwright's test generator to create reliable locators:

```bash
npx playwright codegen localhost:8080
```

This opens a browser where you can click elements and Playwright generates the best locator for each.

### Use soft assertions for multiple checks

When you want to check multiple things without stopping at the first failure:

```typescript
// Soft assertions collect all failures
await expect.soft(page.getByTestId('status')).toHaveText('Success');
await expect.soft(page.getByTestId('count')).toHaveText('5');

// Test continues even if above assertions fail
await page.getByRole('link', { name: 'next page' }).click();
```

### Debugging strategies

**Local debugging:**
- Use VS Code extension for live debugging
- Run `npx playwright test --debug` to step through tests
- Use `await page.pause()` to open inspector at specific points

**CI debugging:**
- Use traces (configured in `playwright.config.ts`)
- View traces with `npx playwright show-report`
- Traces show timeline, DOM snapshots, network requests, and console logs

### Performance tips

**Run tests in parallel** (default behavior):

```typescript
// For independent tests in a single file
test.describe.configure({ mode: 'parallel' });
```

**Use sharding for CI:**

```bash
npx playwright test --shard=1/3
```

**Only install needed browsers on CI:**

```bash
# Instead of all browsers
npx playwright install chromium --with-deps
```

### Keep Playwright updated

New versions include latest browser support and bug fixes:

```bash
npm install -D @playwright/test@latest
npx playwright --version  # Check current version
```

---

## Locator strategies

### Prefer data-testid attributes

```typescript
// Best - explicit test identifier
await page.getByTestId('create-shipment-btn').click();

// Good - accessible selectors
await page.getByRole('button', { name: 'Create' }).click();
await page.getByLabel('Reference number').fill('ABC123');

// Avoid - fragile selectors
await page.locator('.btn-primary').click();  // CSS class
await page.locator('div > span > button').click();  // DOM structure
```

### Adding test IDs to components

In Vue components, add `data-testid`:

```vue
<ButtonComponent data-testid="create-shipment-btn" label="Create" />
```

---

## Page object wrappers

For complex components, create wrappers in `tests/helpers/wrappers/`:

```typescript
// MultiselectWrapper.ts
export default class MultiselectWrapper {
  constructor(private page: Page, private testId: string) {}

  async selectByText(text: string, clearFirst = false) {
    const select = this.page.getByTestId(this.testId);
    if (clearFirst) {
      await select.getByRole('button', { name: 'Clear' }).click();
    }
    await select.click();
    await this.page.getByText(text).click();
  }
}
```

Usage:

```typescript
const addressSelect = new MultiselectWrapper(page, 'sender-address-select');
await addressSelect.selectByText('ShipitSmarter Sender', true);
```

---

## Fixtures

The project provides custom fixtures in `tests/helpers/fixtures.ts`:

```typescript
import { expect, test } from '~/helpers/fixtures';

// Available fixtures:
test('with admin role', async ({ adminRolePage }) => {
  const { page } = adminRolePage;
  // Pre-authenticated as admin user
});

test('with new role', async ({ newRolePage }) => {
  const { page } = newRolePage;
  // Fresh context without authentication
});
```

---

## Waiting strategies

### Wait for navigation

```typescript
await page.waitForURL(`${BASE_URL}/shipment/${shipmentId}`);
```

### Wait for API responses

```typescript
await Promise.all([
  page.waitForResponse(async (resp) => {
    if (resp.url().includes('api/shipping/v4/shipments')) {
      const data = await resp.json();
      shipmentId = data?.id;
    }
    return resp.url().includes('api/shipping/v4/shipments') && resp.status() === 200;
  }),
  page.getByTestId('submit-btn').click(),
]);
```

### Wait for elements

```typescript
await page.getByTestId('loading-spinner').waitFor({ state: 'hidden' });
await page.getByText('Success').waitFor({ state: 'visible' });
```

---

## Assertions

```typescript
import { expect } from '~/helpers/fixtures';

// Visibility
await expect(page.getByText('Shipment created')).toBeVisible();
await expect(page.getByTestId('error-message')).not.toBeVisible();

// Text content
await expect(page.getByTestId('reference')).toHaveText('ABC123');
await expect(page.getByTestId('status')).toContainText('Active');

// Input values
await expect(page.getByLabel('Weight')).toHaveValue('10');

// URL
await expect(page).toHaveURL(/\/shipment\/\d+/);

// Count
await expect(page.getByTestId('list-item')).toHaveCount(3);
```

---

## Environment variables

Tests require these environment variables:

| Variable | Description |
|----------|-------------|
| `PLAYWRIGHT_BASE_URL` | Base URL (e.g., `https://preview.viya.me`) |
| `PLAYWRIGHT_ORY_USERNAME` | Login username |
| `PLAYWRIGHT_ORY_PASSWORD` | Login password |
| `PLAYWRIGHT_ORY_PAT` | Ory API token |
| `PLAYWRIGHT_ADMIN_MAILBOX` | Admin mailbox URL |
| `PLAYWRIGHT_ADMIN_MAILBOX_USER` | Mailbox basic auth user |
| `PLAYWRIGHT_ADMIN_MAILBOX_PASSWORD` | Mailbox basic auth password |

Local setup: Copy `.env.example` to `.env.local` and fill in values.

---

## Debugging tests

> **For CI failure investigation:** When tests fail in CI, use the **browser-debug** skill for detailed trace analysis, CI artifact retrieval, and Chrome DevTools MCP usage.

### UI mode (recommended for development)

```bash
npx playwright test --ui
```

### Debug mode with breakpoints

```bash
npx playwright test --debug
```

### Add console logging

```typescript
test('debugging test', async ({ page }) => {
  page.on('console', (msg) => console.log(msg.text()));
  // ... test code
});
```

### Pause execution

```typescript
await page.pause(); // Opens Playwright Inspector
```

### Take screenshots

```typescript
await page.screenshot({ path: 'debug-screenshot.png' });
```

---

## Test file naming

| Pattern | Purpose |
|---------|---------|
| `*.spec.ts` | Regular test files |
| `*.setup.ts` | Setup tasks (run before tests) |
| `*.teardown.ts` | Cleanup tasks (run after tests) |
| `*.login.ts` | Login flow |
| `*.logout.ts` | Logout flow |

---

## Configuration

Key settings in `playwright.config.ts`:

```typescript
export default defineConfig({
  timeout: 120000,           // Test timeout: 2 minutes
  expect: { timeout: 10000 }, // Assertion timeout: 10 seconds
  retries: process.env.CI ? 2 : 0,
  workers: 3,
  use: {
    baseURL: BASE_URL,
    trace: 'on',              // Always collect traces
    video: 'on',              // Always record video
    screenshot: 'on',         // Always take screenshots
  },
});
```

---

## Test entity naming

**Entity references MUST start with `PW_ENTITY_PREFIX` (`pwtest-`)** to enable automatic cleanup:

```typescript
// mock-data.ts
import { PW_ENTITY_PREFIX } from '~/helpers/consts';
import { TestId } from '~/helpers/TestId';

export const ENTITY_DATA = { name: `${PW_ENTITY_PREFIX}Test Entity` } as const;

// Fixture generator - always use PW_ENTITY_PREFIX + feature-specific suffix
export const getFixture = () => TestId.getFixtureId(8, PW_ENTITY_PREFIX + 'entity-');
// Result example: "pwtest-entity-a1b2c3d4"
```

---

## Common patterns

### Timeout strategy

| Operation | Timeout | Why |
|-----------|---------|-----|
| UI elements | 10-15s (default) | Appear instantly or fail |
| API responses | 60s | Firefox can be 2-3x slower |
| Test suite | 120s (global) | Never reduce |

```typescript
// API wait with explicit timeout
const response = page.waitForResponse(
  (r) => r.url().includes('/api/') && r.request().method() === 'POST',
  { timeout: 60000 }
);
```

### Cross-browser cleanup

Only run cleanup in the last browser project to avoid race conditions:

```typescript
test.afterAll(async ({ browser }, testInfo) => {
  if (testInfo.project.name !== 'firefox') return;
  // ... cleanup code
});
```

### Verify input values after fill

```typescript
const input = page.locator('input[placeholder*="contract name"]');
await input.fill('value');
await expect(input).toHaveValue('value'); // Always verify
```

### Button state verification

```typescript
const btn = page.getByRole('button', { name: 'Save' });
await expect(btn).toBeEnabled();
await btn.click();
```

### Vue-Multiselect handling

```typescript
const dropdown = row.locator('.multiselect');
await dropdown.click();
const option = dropdown.locator('.multiselect__content-wrapper').getByText('Option');
await option.click();
```

### Descriptive assertions

```typescript
await expect(
  page.getByText(reference),
  `Contract ${reference} should be in list`
).toBeVisible();
```

---

## Trace viewer

**Start:** `cd playwright/trace-viewer && node trace-viewer.js &`
**Open:** http://localhost:9400

Features: dashboard with browser grouping, one-click trace viewing, arrow key navigation.

---

## Common issues

| Issue | Cause | Fix |
|-------|-------|-----|
| `Timeout exceeded` | Element not found | Check selector, add explicit wait |
| `strict mode violation` | Multiple matches | Make selector more specific |
| `Target closed` | Navigation during action | Add `waitForNavigation` |
| Button disabled | Form invalid | Fill required fields, verify values |
| Click intercepted | Overlapping element | Scope selector to container |
| Firefox slower | Browser difference | Use 60s timeout for API waits |

---

## Checklist for new tests

- [ ] Test file in correct `app-tests/<feature>/` directory
- [ ] Uses `test.describe.serial` for dependent tests
- [ ] Tests numbered for clarity (`01.`, `02.`, etc.)
- [ ] Uses `data-testid` selectors where possible
- [ ] Entity references start with `PW_ENTITY_PREFIX` (`pwtest-`)
- [ ] Includes cleanup helper (`deleteAllTestEntities`)
- [ ] Waits for API responses when needed
- [ ] Includes meaningful assertions
- [ ] Cleans up test data in teardown if needed
- [ ] Works on both Chromium and Firefox
- [ ] Works in CI environment (no local dependencies)

---

## Related Documentation

- [Testing Strategy](../../../docs/testing-strategy.md) - When to write E2E vs unit tests, critical flows, coverage expectations

---

## Related Skills

| Skill | When to Use |
|-------|-------------|
| **browser-debug** | Investigating CI test failures with traces and Chrome DevTools |
| **pr-review** | Test coverage evaluation during PR review |
| **vue-component** | Component conventions when adding test IDs |
