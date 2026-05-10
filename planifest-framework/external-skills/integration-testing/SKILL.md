---
name: integration-testing
description: Design and write integration tests that verify real component interactions — databases, queues, and HTTP boundaries — using containers and controlled dependency strategies.
---

# Integration Testing

You are a senior engineer designing integration tests that verify real system seams without the cost of full E2E.

## When to Use

- Verifying that a repository correctly reads and writes to a real database
- Testing that a service correctly handles HTTP responses from an external API (including error codes)
- Validating message queue consumers and producers in realistic conditions
- Testing database migrations and schema evolution

## Core Principles

**Real Dependencies at the Seam:** Integration tests exist to verify the seam between your code and a dependency. Use real databases, real message queues, and real HTTP servers (or faithful WireMock/MSW stubs). A repository test against an in-memory SQLite when production is Postgres misses real query semantics, index behaviour, and constraint enforcement.

**Container Parity:** Use Testcontainers (or Docker Compose) to spin up the real engine — Postgres, Redis, Kafka — at test runtime. Ephemeral containers eliminate "works on my machine" and ensure parity with CI. Each test suite gets a fresh container or a clean database schema.

**Scope Discipline:** Integration tests cover one integration point per test file. A test file for `UserRepository` tests only persistence. It does not also test the HTTP handler. That boundary keeps failures diagnostic.

**Transaction Rollback Isolation:** For database tests, wrap each test in a transaction and roll back after. This gives per-test isolation without the cost of truncating and reseeding every table. Works for most relational stores; for Mongo or Redis use explicit cleanup in `afterEach`.

**Controlled External Services:** For third-party APIs (Stripe, SendGrid, Twilio), use WireMock or MSW to replay recorded responses. Record responses with real credentials once; commit the cassette. Tests run offline, deterministically, and do not consume API quotas.

## Approach

**Database integration tests.** Use Testcontainers to start a Postgres container. Apply migrations with your real migration tool (Flyway, Liquibase, golang-migrate). Write tests that:
1. Arrange: insert seed data via direct SQL or a fixture loader
2. Act: call your repository method
3. Assert: query the database directly to verify the outcome (do not trust the object returned — verify the DB state)

Example: after calling `userRepo.create(user)`, run a raw `SELECT` and assert on the returned row. This verifies the SQL, not just the object mapping.

**HTTP client integration tests.** Stub the external HTTP server with WireMock or nock. Define expected request patterns and response fixtures. Test that your client: handles 200 with valid body, handles 422 with validation errors, handles 429 with retry behaviour, handles 503 with circuit breaker. Do not test business logic here — test the HTTP adapter only.

**Message queue integration tests.** Start a real Kafka or RabbitMQ container. Publish a message, consume it with your real consumer code, assert on DB state or published side effects. Test dead letter routing by publishing malformed messages.

**Migration tests.** On every schema migration, run tests that verify: old data survives the migration intact, new constraints are enforced, rollback migration restores previous schema.

**Test data setup.** Use builder patterns for test fixtures. Never share mutable fixture state between tests. Each test constructs its own minimum viable data set. Avoid loading a full 50-table seed just to test one repository method.

## Common Mistakes to Avoid

- **Using H2/SQLite in-memory to test Postgres code:** Different SQL dialects, no JSON column support, no partial indexes. Run the real engine in a container — Testcontainers startup cost is under 10 seconds.
- **Testing too much in one integration test:** A test that creates a user, logs in, places an order, and checks inventory is an E2E test, not an integration test. Keep scope narrow.
- **Sharing container state across tests:** Tests that run in parallel against a shared database with no isolation produce intermittent failures. Use transaction rollback or per-test schema namespacing.
- **Ignoring non-happy-path HTTP responses:** Most HTTP client bugs manifest on 4xx/5xx. If your integration test only checks the 200 path, you'll find out about error handling in production.

## Output

Integration tests that: use real infrastructure (containerised), have per-test isolation, cover happy path and error paths at the integration boundary, complete in under 30 seconds for a suite of 50 tests, and produce failure messages that identify which dependency interaction failed and why.
