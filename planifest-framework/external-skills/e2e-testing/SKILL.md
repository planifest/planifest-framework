---
name: e2e-testing
description: Write reliable end-to-end tests with Playwright or Cypress — covering selector strategy, flakiness prevention, test data lifecycle, and CI integration patterns.
---

# End-to-End Testing

You are a senior SDET designing E2E tests that give real user-journey confidence without becoming a flakiness tax.

## When to Use

- Verifying critical user journeys across the full stack (browser through DB)
- Smoke testing a deployment before traffic is switched
- Regression-protecting checkout, authentication, or onboarding flows
- Replacing manual regression checklists on high-traffic paths

## Core Principles

**Critical Paths Only:** E2E tests are the most expensive to write, run, and maintain. Reserve them for flows where failure is catastrophic and no cheaper test catches the bug. Login, checkout, sign-up, data export — yes. "Does the tooltip show?" — no, that's a unit test.

**Stable Selectors:** Selectors coupled to CSS classes, DOM position, or visual appearance are brittle. Use `data-testid` attributes added intentionally for testing. They survive styling refactors, DOM restructuring, and framework migrations.

**Auto-Waiting, Not Arbitrary Sleeps:** Modern E2E tools (Playwright, Cypress) have built-in auto-waiting. Use `page.waitForSelector`, `page.waitForResponse`, or assertion-based waiting. Never add `sleep(2000)` — it's both slow and unreliable.

**Test Isolation by Default:** Every test starts with a known state. Either reset state via API calls in `beforeEach` (faster than UI navigation) or use a fresh user account per test. Tests that depend on other tests' side effects fail non-deterministically.

**Network Interception for Speed:** Long tests often wait for real external APIs (payments, email). Use Playwright's `page.route()` or Cypress `cy.intercept()` to stub slow or flaky third-party calls, keeping journeys within the application boundary fast and deterministic.

## Approach

**Selector strategy.** Add `data-testid="submit-button"` to interactive elements. In Playwright: `page.getByTestId('submit-button')`. In Cypress: `cy.get('[data-testid="submit-button"]')`. Never select by `nth-child`, hex colour, or generated class name. Use `getByRole` (Playwright) as a second-choice — it tests accessibility semantics simultaneously.

**Page Object Model (POM).** Encapsulate page interactions in Page Object classes. Each page/component has one class with methods like `loginPage.submitCredentials(email, password)`. Selectors live only in the Page Object, not in test files. When the UI changes, update one class, not fifty tests.

**Test data lifecycle.** Create test users and data via API (not via UI navigation). Playwright: use `request` context in `beforeAll` to POST to your API and create accounts. Tag accounts for cleanup. Run cleanup in `afterAll` or use a dedicated test tenant that is reset nightly.

**Parallelism and sharding.** E2E suites are slow in sequence. Use Playwright's built-in sharding (`--shard=1/4`) to split across CI workers. Ensure tests are fully independent — shared accounts or sequential dependencies prevent parallelism.

**Retry strategy.** Configure retry on failure (Playwright: `retries: 1` in `playwright.config.ts`). Retry once catches genuine infrastructure flakes without masking real bugs. If a test fails twice, it's a real failure. Track flakiness rate in CI — alert if >1% of runs fail intermittently.

**CI integration.** Run E2E on merge to main (not on every PR for cost reasons, unless parallelised). Run smoke subset (10-15 critical tests) on every PR. Use Playwright's `--reporter=html` for local debugging and `--reporter=junit` for CI parsing. Store trace artifacts (Playwright traces, Cypress videos) for failures.

**Assertions.** Assert on user-visible outcomes: page content, URL, network calls to key APIs. Avoid asserting on implementation (Redux state, React component props). Use `expect(page).toHaveURL('/dashboard')` not `expect(router.currentRoute).toBe('/dashboard')`.

## Common Mistakes to Avoid

- **Sleeping instead of waiting:** `await page.waitForTimeout(3000)` is a time bomb. Use `await page.waitForSelector(...)` or `await expect(locator).toBeVisible()`.
- **Massive test suites with no ownership:** 500 E2E tests with no clear owner become everyone's problem. Cap suite size. If you need 500 E2E tests, your lower-level tests are inadequate.
- **Running E2E against production data:** Never. Use dedicated test environments. Production data is unpredictable, personal, and destructible.
- **No test isolation:** If test B relies on test A having created a record, they are secretly coupled. Run test B alone and watch it fail. Fix the setup.

## Output

Tests that: express user intent clearly ("user can complete checkout with saved card"), use stable selectors, run in under 60 seconds per scenario, are independently runnable in any order, produce video/trace artifacts on failure, and map to documented user journeys.
