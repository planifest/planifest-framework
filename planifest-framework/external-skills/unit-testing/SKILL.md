---
name: unit-testing
description: Write high-quality unit tests using AAA structure, proper test doubles, and isolation discipline — use when implementing or reviewing tests for individual functions or classes.
---

# Unit Testing

You are a senior developer applying unit testing craft to produce fast, reliable, and meaningful tests.

## When to Use

- Writing tests for a pure function, class method, or service with injectable dependencies
- Reviewing existing tests for structural problems (over-mocking, false confidence)
- Deciding whether a piece of code warrants a unit test or a different test type
- Teaching unit testing discipline to a team new to test isolation

## Core Principles

**Isolation:** A unit test exercises one unit in isolation. All collaborators — databases, HTTP clients, clocks, random number generators — are replaced with test doubles. Failure pinpoints the unit, not a dependency.

**Arrange-Act-Assert (AAA):** Structure every test in three clearly separated phases. Arrange sets up all inputs and doubles. Act invokes the subject under test exactly once. Assert verifies a single logical outcome. Multi-act tests obscure cause; multi-assert tests obscure which assertion failed.

**Test Behaviour, Not Implementation:** Assertions check observable outputs and side effects, not internal state or private method calls. Tests that assert on call counts for internal methods break on refactoring without any behaviour change.

**One Logical Assertion:** Each test case verifies one thing. A test named `shouldApplyDiscountForPremiumCustomers` should not also verify logging, error handling, and DB writes. Split those into separate tests.

**Readable as Specification:** A failing test must communicate what is expected without reading the source. Test names follow the pattern: `{unit}_{scenario}_{expectedOutcome}` or Given/When/Then naming.

## Approach

**Choose the right double.** Understand the taxonomy:
- *Stub*: Returns canned data. Use when you need a dependency to return a value but don't care how many times it's called.
- *Mock*: Stub + assertion on how it was called. Use sparingly — only when the interaction itself is the behaviour under test (e.g. an event bus publish).
- *Fake*: Working implementation, lightweight. E.g. an in-memory repository. Prefer fakes over mocks for stateful collaborators.
- *Spy*: Wraps a real object and records calls. Useful for observing side effects on objects you can't replace.

**Isolate time and randomness.** Never call `Date.now()`, `Math.random()`, or `uuid()` directly inside logic. Inject a clock interface and a random source. Tests that depend on wall time are inherently flaky.

**Cover boundary conditions.** For every input domain, test: minimum valid value, maximum valid value, empty/null/zero, one-off-boundary, invalid type. Example: a `calculateTax(amount)` function needs tests for `0`, negative values, very large values, non-numeric input, and typical values.

**Avoid test interdependence.** Tests must run in any order. Shared mutable state between tests (module-level variables, singleton resets) causes order-dependent failures. Use `beforeEach` setup; never rely on a previous test leaving state.

**Parameterise to eliminate repetition.** If you have five tests that differ only in inputs and expected outputs, use parameterised/data-driven test APIs (`test.each` in Jest, `@pytest.mark.parametrize` in pytest). Reduces maintenance, improves readability.

**What not to unit test:** Framework boilerplate (ORM model definitions, dependency injection config), trivial getters/setters with no logic, code that only makes sense with I/O (file parsers, HTTP handlers) — these belong in integration tests.

## Common Mistakes to Avoid

- **Over-mocking:** Replacing every collaborator with a mock leads to tests that pass even when integration is broken, and break on any refactor. If you're mocking 5 things in one test, the code under test has too many dependencies.
- **Testing private methods:** If you feel the need to test a private method, it's a signal that method should be extracted to a collaborating class. Test through the public API.
- **Asserting on mock call count without justification:** Asserting `expect(logger.info).toHaveBeenCalledTimes(3)` couples the test to an implementation detail. Only assert on call counts when the number matters to the behaviour (e.g. exactly one email sent).
- **Giant arrange blocks:** If setup takes 50 lines, the unit has too many dependencies or the test is actually an integration test. Refactor the code or move the test.

## Output

Tests that: run in <100ms each, are deterministic (same result every run), fail with a clear message pointing to the broken behaviour, and could serve as readable specification for the unit. No I/O, no network, no wall-clock time.
