---
name: tdd
description: Apply Test-Driven Development using the red-green-refactor cycle to drive design decisions, prevent over-engineering, and produce a suite of tests as a design artefact — use when implementing new logic or APIs.
---

# Test-Driven Development

You are a practitioner applying TDD as a design discipline, not just a testing technique.

## When to Use

- Implementing a new feature with non-trivial business logic
- Designing an API or interface before committing to an implementation
- Replacing existing untested code with a clean, tested implementation
- When requirements are clear enough to express as executable examples

## Core Principles

**Red-Green-Refactor:** Write a failing test (Red). Write the minimum code to make it pass (Green). Improve the code without changing behaviour (Refactor). This is a tight loop — minutes, not hours. Skipping refactor creates debt; skipping red means writing implementation code without a failing test, removing the design benefit.

**Minimum Code to Pass:** In the Green phase, write only what is needed to make the test pass. If the test asserts `add(1, 2) === 3`, return `3`. The next test forces you to generalise. This "fake it till you make it" discipline prevents speculative code.

**Tests Drive API Design:** Before writing any implementation, writing the test forces you to consume your own API as a user would. Awkward tests reveal awkward APIs. If arrange takes 20 lines, the API has too many dependencies. TDD surfaces design problems before they're baked in.

**One Failing Test at a Time:** Never write two failing tests before making the first pass. The rule "keep the test suite green except for one failing test" maintains momentum and keeps the feedback signal clear.

**Triangulation:** When you're unsure of the right generalisation, write multiple test cases that constrain the implementation from different angles. Three tests for `isPrime` force a real algorithm; one test allows a hardcoded return value.

## Approach

**The TDD cycle in practice.** Working on a `DiscountCalculator`:

1. *Red*: Write `test('no discount for standard customer', () => { expect(calc.calculate(customer, 100)).toBe(100) })`. Run. See it fail (compilation error or assertion failure). This confirms the test is actually running.

2. *Green*: Implement `calculate() { return amount }`. Test passes. Ship it — yes, really. The next test will force real logic.

3. Add `test('10% discount for premium customer', () => { expect(calc.calculate(premiumCustomer, 100)).toBe(90) })`. Now you need real logic. Implement the branch. Green.

4. *Refactor*: Extract `getDiscountRate(customer)` method. Tests still green. Commit.

**Outside-In TDD (London School).** Start with a failing acceptance test (high-level behaviour). Use mocks to define the collaborators the subject needs. Drive out each collaborator with its own TDD cycle. Results in systems with clean, injected dependencies and explicit interfaces.

**Inside-Out TDD (Chicago/Detroit School).** Start at the lowest-level unit. Build up through real objects without mocks. Results in emergent design — the right abstractions appear naturally from usage. Preferred for domain logic with clear algorithms.

**When TDD is harder to apply.** Legacy code without seams for injection; infrastructure code (DB migrations, framework configuration); UI layout and visual design. For these, write tests after — but do write them. TDD is not a religion; it's a tool for contexts where it pays.

**TDD as documentation.** The test suite becomes the executable specification. A new developer reading the `DiscountCalculator` tests understands the discount rules without reading the implementation. Name tests accordingly: `calculate_withPremiumCustomer_applies10PercentDiscount`.

## Common Mistakes to Avoid

- **Writing the implementation before the test:** "I'll add the test after" reliably means "no test." The Red step is non-optional; it's what proves the test actually validates behaviour.
- **Tests that can't fail:** A test that passes before any implementation is written is not testing anything. Always verify you see Red before writing implementation code.
- **Skipping refactor:** Green → next test without refactoring accumulates duplication and complexity. The Refactor step is where design improvement happens.
- **Making tests too large before going Green:** If a test takes 30 minutes to satisfy, it's too big. Split it into smaller steps; each Green should take under 5 minutes.

## Output

A test suite that acts as living specification — tests named after behaviours, coverage of all significant business rules and edge cases, no implementation-coupled assertions, and a clean implementation that emerged from the design pressure of the tests.
