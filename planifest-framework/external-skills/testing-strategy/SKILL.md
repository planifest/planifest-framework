---
name: testing-strategy
description: Define a testing strategy by selecting the right coverage model, setting risk-based goals, and mapping test types to delivery risk — use when starting a project or auditing an existing test suite.
---

# Testing Strategy

You are a senior QA architect defining testing strategy for software delivery teams.

## When to Use

- Starting a new project and deciding what test types to invest in
- Auditing an existing test suite that is slow, brittle, or providing false confidence
- Scaling a team and needing to standardise testing expectations across squads
- Choosing between competing approaches (e.g. heavy unit tests vs integration-heavy)

## Core Principles

**Risk-Based Coverage:** Not all code warrants the same test investment. Prioritise by consequence of failure: payment flows, data mutations, and auth paths warrant higher coverage than read-only display logic.

**Model Fitness:** The testing pyramid (many units, fewer integration, fewest E2E) fits systems with complex business logic in isolated units. The testing trophy (more integration, fewer units) fits API-heavy backends. The testing honeycomb fits microservices where service integration is the real risk. Choose the model that reflects where your system's complexity lives.

**Speed as a Feature:** A slow test suite is avoided. Tests that run in minutes enable tight feedback loops; tests that take 30 minutes become a CI-only afterthought. Design for sub-5-minute local feedback on the critical path.

**Confidence Over Coverage:** 100% line coverage means nothing if tests only verify happy paths. Coverage is a lagging indicator; scenario coverage (error paths, boundary conditions, permission boundaries) is the leading one.

**Shift-Left Economics:** A bug caught by a unit test costs near-zero to fix. A bug caught in production costs 100x. Testing strategy must make early detection economically attractive by keeping unit and integration tests fast and reliable.

## Approach

**Step 1 — Identify risk zones.** Map your system: data stores, external dependencies, authentication, financial operations, regulatory requirements. These are your high-risk zones. List them explicitly.

**Step 2 — Select a model.** Apply the right coverage model:
- *Testing Pyramid*: Business logic in domain services, pure functions, complex algorithms. Heavy unit base.
- *Testing Trophy* (Kent C. Dodds): CRUD APIs, React frontends. Integration tests give most confidence per dollar.
- *Testing Honeycomb* (Spotify): Microservices communicating over network. Integration between services is the riskiest seam; test there heavily.

**Step 3 — Define coverage goals per risk tier.** Example:
- Tier 1 (payment, auth): 90%+ branch coverage, contract tests for all external integrations, E2E for critical user journeys
- Tier 2 (core features): 75%+ branch coverage, integration tests for persistence layer
- Tier 3 (display/utility): 50%+ or none; rely on type system and linting

**Step 4 — Establish test-type budgets.** Budget by run time and by failure signal clarity:
- Unit: <100ms per test, deterministic, no I/O
- Integration: <5s per test, real DB in containers, controlled dependencies
- E2E: <60s per scenario, run on merge to main only (not every PR)

**Step 5 — Define ownership.** Tests close to code are owned by feature teams. E2E and contract tests are co-owned with QA. Performance and security testing is QA-led with dev input.

**Step 6 — Set quality gates.** Coverage thresholds in CI, mandatory green before merge, flakiness budget (e.g. zero tolerance for tests that fail >1% of runs without code changes).

## Common Mistakes to Avoid

- **Chasing line coverage targets**: 80% coverage set as a CI gate causes devs to write trivial tests to hit the number. Measure scenario coverage, not line coverage.
- **Ignoring the test maintenance budget**: Every test has a carrying cost. A 10,000-test suite requires real effort to maintain. Prune aggressively.
- **Applying one model to all services**: A payment service and a notification service have different risk profiles. Their testing strategies should differ.
- **No test data strategy**: Tests that depend on shared mutable state produce intermittent failures. Test isolation is not optional.

## Output

A testing strategy document covering: chosen model with rationale, risk tier mapping, coverage goals per tier, test-type budget (speed + ownership), and quality gate definitions. One page maximum. Should be committal — "we will do X" not "we could consider X".
