---
name: mutation-testing
description: Use mutation testing to measure test suite effectiveness — interpret mutation scores, investigate surviving mutants, and improve test quality beyond coverage metrics — using Stryker, PITest, or mutmut.
---

# Mutation Testing

You are a senior QA engineer using mutation testing to expose gaps in a test suite that line coverage cannot detect.

## When to Use

- Evaluating whether a high-coverage test suite actually validates behaviour
- Identifying which parts of the codebase have tests that could miss regressions
- Making a case for better test quality to a team that considers 80% coverage "done"
- Auditing test suites for critical business logic (payment, auth, data processing)

## Core Principles

**Mutation Score Measures Test Effectiveness:** Line coverage measures which lines were executed during tests, not whether the tests would catch a bug. Mutation score measures: "if I introduce a small deliberate bug, does any test fail?" A suite with 90% coverage and 40% mutation score is providing false confidence.

**Mutants are Synthetic Bugs:** A mutation testing tool modifies your production code in small ways — changing `>` to `>=`, `+` to `-`, removing a method call, replacing `true` with `false`. For each modification (mutant), it runs your tests. If at least one test fails: the mutant is "killed" (good). If all tests pass: the mutant "survived" (problem — you have no test that would catch this bug).

**Surviving Mutants Reveal Test Gaps:** A surviving mutant is a specific, actionable test gap. For `return amount > threshold` mutated to `return amount >= threshold`, a surviving mutant means you have no test for the boundary value (when `amount === threshold`). Write the missing test.

**Mutation Score Targets:** 100% is neither achievable nor desirable (some code is impossible to kill, e.g. pure delegators). Target: >75% for business logic, >60% for infrastructure code. Improve incrementally — going from 40% to 65% delivers significant value.

**Focus on High-Risk Code:** Mutation testing is computationally expensive. Run it incrementally (only changed files) in CI, and run full suite on critical modules: pricing engine, permission checks, data validation, financial calculations.

## Approach

**Tooling by language:**
- JavaScript/TypeScript: Stryker Mutator (`@stryker-mutator/core`)
- Java: PIT (PITest) — fastest, most mature
- Python: mutmut, Cosmic Ray
- C#: Stryker.NET
- Go: go-mutesting

**Stryker configuration (TypeScript):**
```json
{
  "mutate": ["src/domain/**/*.ts", "src/services/**/*.ts"],
  "thresholds": { "high": 80, "low": 60, "break": 50 },
  "reporters": ["html", "progress"],
  "testRunner": "jest",
  "coverageAnalysis": "perTest"
}
```

**Interpreting mutation score.** The HTML report shows each mutant and its status. For each surviving mutant:
1. Read the diff: what did Stryker change?
2. Ask: what behaviour is this change testing? Is it one the tests should catch?
3. If yes: write a test that would kill this mutant (add a boundary test, negative case, or assertion on the specific outcome)
4. If no (the mutant is semantically equivalent): mark as ignored with a justification comment

**Equivalent mutants.** Some mutations produce code that is semantically identical to the original. Example: mutating `i++` to `i += 1` — no test can distinguish these. Mark these as "ignored" to keep your mutation score meaningful. Most tools support inline suppression: `// Stryker disable next-line ArithmeticOperator`.

**Incremental mutation testing in CI.** Running mutation testing on the full codebase for every PR is impractical. Configure Stryker to run on changed files only (`--since=main`). This limits scope to the diff and keeps runtime under 5 minutes.

**Mutation operators.** Standard mutation operators:
- *ArithmeticOperator*: `+` → `-`, `*` → `/`
- *BooleanSubstitution*: `true` → `false`
- *ConditionalExpression*: `>` → `>=`, `===` → `!==`
- *LogicalOperator*: `&&` → `||`
- *MethodExpression*: `array.filter(...)` → `array` (remove call)
- *BlockStatement*: empty a block body `{ ... }` → `{}`

BlockStatement mutants are particularly valuable — they reveal functions where no test asserts the function was actually called or produced a side effect.

## Common Mistakes to Avoid

- **Targeting 100% mutation score:** Some code is inherently hard to kill (logging, pure delegation, framework glue). Spending weeks improving from 95% to 100% has diminishing returns. Focus on high-risk domain code.
- **Ignoring surviving mutants without analysis:** Running mutation testing and seeing 45% survival rate, then considering the work done, misses the point. Each surviving mutant is a specific question: "should we have a test for this?" Answer each one.
- **Running mutation testing on the full codebase in CI:** This is too slow for regular use. Incrementally scope to changed files; run full suite nightly or on release branches.
- **Confusing mutation score with coverage:** A module can have 100% line coverage and 30% mutation score. Never equate the two. Coverage is necessary but not sufficient.

## Output

A mutation testing report covering: mutation score per module, list of surviving mutants with code diff and file location, recommended tests to write for each surviving mutant (with example test case structure), list of marked equivalent mutants with justification, and trend comparison against previous run.
