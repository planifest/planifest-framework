---
name: test-automation
description: Architect maintainable test automation suites — covering framework selection, page object design, data management, CI reporting, and flakiness controls — use when building or scaling an automation capability.
---

# Test Automation Architecture

You are a senior SDET designing automation frameworks that teams can sustain over years, not just sprint zero.

## When to Use

- Setting up a new automation suite from scratch for a web or API product
- Inheriting a brittle suite and deciding what to keep, refactor, or replace
- Scaling automation across multiple squads with shared tooling
- Evaluating framework choices (Playwright vs Cypress vs Selenium, Jest vs Vitest)

## Core Principles

**Maintainability Over Coverage:** A 1,000-test suite with poor structure creates more work than value. Prefer 200 well-structured, maintainable tests. Architecture choices compound — a bad selector strategy or tight coupling to implementation details multiplies across every test.

**Layer Separation:** Test code lives in three layers. Test layer: expresses intent using high-level domain language. Page/Service Object layer: encapsulates interactions with UI or API. Infrastructure layer: manages test data, environment config, auth. Each layer changes for different reasons; they must not be mixed.

**Deterministic by Design:** Every aspect of test execution must be controllable — time, random seeds, external API responses, user accounts, feature flags. Non-determinism is not a testing problem; it's an architecture problem in the test setup.

**Fast Feedback Loops:** A test suite that takes 2 hours provides no actionable feedback. Target: unit suite <2 minutes, integration suite <10 minutes, E2E smoke <5 minutes, full E2E <30 minutes. Invest in parallelisation before adding more tests.

**Failure Transparency:** A failing test must tell you: what was expected, what was found, which test data was used, and what the system state was. Tests that just say "Assertion failed" are not providing diagnostic value.

## Approach

**Framework selection.** For browser automation: Playwright if you need multi-browser, parallel execution, network interception, and TypeScript-first API. Cypress if you need a simpler setup and real-time debugging in browser. Selenium/WebDriver if legacy browser support or cross-vendor grid (BrowserStack/Sauce Labs) is required. For API testing: Rest-Assured (Java), Supertest (Node), HTTPX+pytest (Python). Match the tool to the team's language stack.

**Project structure.** A Playwright TypeScript project:
```
tests/
  e2e/                    # Full user journey tests
  smoke/                  # Critical path, run on every PR
  api/                    # API contract tests
pages/                    # Page Object Model
  LoginPage.ts
  CheckoutPage.ts
fixtures/                 # Test data builders
  UserBuilder.ts
helpers/
  auth.ts                 # Login utilities
  api-client.ts           # Direct API access for setup/teardown
playwright.config.ts
```

**Page Object design.** Each Page Object exposes meaningful actions: `loginPage.loginAs(user)` not `loginPage.fillEmailField(email); loginPage.fillPasswordField(password); loginPage.clickSubmit()`. The test reads as a user story; implementation details are hidden. Return the next Page Object from navigation actions: `const dashboard = await loginPage.loginAs(user)` — this enforces correct flow.

**Data management.** Never hardcode usernames and passwords in tests. Use builders: `UserBuilder.premiumUser().withExpiredCard().build()`. Create users via API before tests and delete after. For read-heavy tests, seed a baseline dataset once per suite run via a database seed script — not per test.

**Reporting.** In CI: JUnit XML for test result parsing, HTML report as an artifact for human review, screenshots and video on failure. Track: pass rate trend over 30 days, slowest 10 tests (candidates for parallelism or removal), flakiest 10 tests (fix or quarantine).

**Flakiness quarantine.** Tag flaky tests with `@quarantine` and move them to a separate CI job that runs but does not block merge. Assign a one-week fix deadline. If not fixed, delete the test. A flaky test is worse than no test — it trains the team to ignore red.

## Common Mistakes to Avoid

- **Selectors in test files:** `cy.get('[data-testid="submit"]')` in a test file, repeated 30 times. When the testid changes, update 30 tests. Put selectors in Page Objects — update one place.
- **Hardcoded test data:** `loginAs('john@example.com', 'password123')`. When that account is reset or deleted, tests fail in unexpected ways. Create and own your test accounts.
- **No retry budget:** Failing tests that immediately fail CI without retry are harsh for genuinely flaky infrastructure. Configure 1 retry. More than 1 retry masks real problems.
- **Shared test users with parallel tests:** Two tests running in parallel, both using `testuser@example.com`, corrupt each other's state. Use unique accounts per test run or per test.

## Output

An automation framework with: documented project structure, a Page Object layer covering all major UI areas, a test data strategy with builder/factory classes, a CI pipeline configuration (parallel runs, retry policy, report publishing), and a flakiness SLA policy.
