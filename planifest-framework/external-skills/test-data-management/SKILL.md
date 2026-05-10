---
name: test-data-management
description: Design a test data strategy using factories, fixtures, and seeding patterns that ensure isolation, repeatability, and safe handling of sensitive data — use when building or auditing integration and E2E test suites.
---

# Test Data Management

You are a senior QA engineer designing test data strategies that keep test suites deterministic, isolated, and compliant.

## When to Use

- Integration or E2E tests are failing intermittently due to shared or stale data
- Tests pass locally but fail in CI due to data ordering or parallelism
- Sensitive production data is being used or referenced in test environments
- A new test suite needs a data strategy from the start

## Core Principles

**Test Isolation:** Each test owns its data. A test that depends on data created by another test is coupled to it. Run tests in reverse order and the second test fails. Each test must create what it needs and clean up after itself (or use a fresh scope).

**Minimum Viable Data:** Tests should create only the data they need. Creating 20 records when a test needs 1 makes failures harder to diagnose and setup slower. Builder patterns should make minimum viable datasets easy to construct.

**No Shared Mutable State:** Shared test accounts, shared configuration records, and shared reference data that any test can mutate are time bombs in parallel execution. Either make shared data immutable (seed once, read-only) or give each test its own copy.

**Synthetic Data, Not Production Copies:** Never copy production data into test environments. Production data contains PII, financial data, and secrets. Use factories to generate synthetic but realistic data: `faker.js`, `Bogus` (.NET), `Faker` (Python/Ruby). Realistic-looking data finds more realistic bugs.

**Data Lifecycle Clarity:** Know when data is created (setup), how it's used (test), and when it's removed (teardown). Document the lifecycle. For ephemeral environments, teardown may be the environment destruction itself.

## Approach

**Factory pattern (TypeScript with Fishery or factory-bot style):**
```typescript
import { Factory } from 'fishery';
import { faker } from '@faker-js/faker';

const userFactory = Factory.define<User>(() => ({
  id: faker.string.uuid(),
  email: faker.internet.email(),
  name: faker.person.fullName(),
  role: 'standard',
  createdAt: new Date(),
}));

// Trait overrides
const premiumUser = userFactory.params({ role: 'premium' });
const adminUser = userFactory.params({ role: 'admin' });

// Usage in test
const user = userFactory.build();
const premium = premiumUser.build({ name: 'Alice' });
```

**Factories vs Fixtures vs Seeds:**
- *Factory*: Programmatic builder that generates unique data on demand. Best for unit and integration tests. Deterministic random (with seed) or fully random. Always isolated.
- *Fixture*: A static data file (JSON/YAML/SQL) loaded before tests. Good for reference data that never changes (country codes, tax rates). Bad for mutable entity data.
- *Database seed*: SQL/migrations script that establishes a known baseline. Use for integration suites that need a realistic starting state. Run once per suite, not per test.

**Isolation strategies per test type:**
- *Unit tests*: No real data — factories build in-memory objects, no DB.
- *Integration tests*: Transaction rollback per test. Start transaction in `beforeEach`, roll back in `afterEach`. Fastest isolation, no cleanup debt.
- *E2E tests*: Create via API in `beforeAll`, delete in `afterAll`. Or use a test tenant that is reset nightly. Never share accounts across parallel E2E tests.

**Handling sensitive data.**
- Never use real names, real email addresses, or real payment card numbers in tests.
- Use `faker.js` to generate plausible but synthetic PII.
- For payment testing: use Stripe test card numbers (`4242 4242 4242 4242`), never real cards.
- Store test credentials in CI secrets, not in code. Rotate on a schedule.
- If your test environment uses anonymised production data, verify the anonymisation: run a check that `SELECT email FROM users` returns no `@gmail.com`/`@yahoo.com` addresses.

**Parallelism safety.** When running tests in parallel:
- Generate unique identifiers per test run: `testRunId = crypto.randomUUID()`.
- Prefix created records: `email: `test-${testRunId}@example.com``.
- Use per-worker database schemas (Postgres: `SET search_path = worker_${workerId}`).
- Never write to shared tables without row-level ownership (e.g. include `testRunId` as a column).

**Cleanup debt.** Long-lived test environments accumulate ghost data from failed tests that didn't clean up. Run a nightly cleanup job: delete records older than 24 hours where `email LIKE 'test-%'`. Alternatively, use ephemeral environments per PR — created on PR open, destroyed on merge.

## Common Mistakes to Avoid

- **Hardcoded UUIDs in fixtures:** `{ "id": "550e8400-e29b-41d4-a716-446655440000" }` creates conflicts when the same fixture is loaded twice (unique constraint violation). Generate IDs at load time.
- **Production data in staging:** `We just cloned prod to staging` is a GDPR/CCPA event waiting to happen. Anonymise before import, or build synthetic from scratch.
- **Assuming test data is still there:** Test A creates a user; Test B reads that user. Test A didn't run? Test B fails mysteriously. Tests must be self-sufficient.
- **Giant global seeds:** A 500-table seed script that takes 10 minutes to run before every suite blocks fast feedback. Seed only what the suite actually needs; use lazy factories for the rest.

## Output

A test data strategy document and implementation covering: factory definitions for core domain entities, fixture files for immutable reference data, seed scripts scoped to suite needs, isolation strategy per test type (transaction rollback / API setup / per-tenant), and a sensitive data policy (synthetic data only, Faker usage, cleanup SLA).
