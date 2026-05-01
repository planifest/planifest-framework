# Execution Plan — 0000004-tdd-regression-test-quality

**Feature:** TDD Sub-Loop, Regression Pack, and Test Reporting
**Date:** 2026-04-25
**Adoption mode:** Retrofit
**Components affected:** planifest-codegen-agent (update), planifest-ship-agent (update), 3 new skills, regression-pack infrastructure

---

## Summary

This feature introduces structured test-driven development into the Planifest P3 codegen phase via a per-requirement red-green-refactor sub-loop, a curated long-term regression pack distinct from feature-specific tests, and a test report artifact generated at P7 ship time.

No HTTP APIs are introduced. No schema changes. No new cloud infrastructure.

---

## What Changes

### 1. planifest-codegen-agent (SKILL.md update)

The codegen-agent gains a **TDD inner loop protocol** replacing its current all-at-once test+code approach. For each requirement, the agent orchestrates three sub-agents in sequence:

```
for each requirement:
  1. invoke planifest-test-writer  (+ stack capability skill) → confirms RED
  2. invoke planifest-implementer  (+ stack capability skill) → confirms GREEN
  3. invoke planifest-refactor     (+ stack capability skill) → confirms still GREEN
```

If red→green fails after 3 attempts on a single requirement, escalate to human before proceeding.

Sub-agents SHOULD use a cheaper/faster model tier. The codegen-agent retains the full model for orchestration and synthesis.

### 2. planifest-test-writer (new skill)

Narrow skill. Scope: write exactly one failing test per requirement. Load the declared stack capability skill. Run the test. Confirm exit non-zero (RED). Do not write implementation code.

`recommended_model: haiku` (or equivalent cheaper tier)

### 3. planifest-implementer (new skill)

Narrow skill. Scope: write the minimum code required to make the failing test pass. Load the declared stack capability skill. Run the test. Confirm exit zero (GREEN). Do not over-engineer.

`recommended_model: haiku` (or equivalent cheaper tier)

### 4. planifest-refactor (new skill)

Narrow skill. Scope: improve code quality while keeping all tests passing. Load the declared stack capability skill. Run full test suite. Confirm all green. Do not add new behaviour.

`recommended_model: haiku` (or equivalent cheaper tier)

### 5. regression-pack infrastructure (new)

- `planifest-framework/tests/regression/` — directory for long-term regression tests
- `planifest-framework/tests/regression/regression-manifest.json` — tracks promoted tests: name, source feature, promotion date, promoted by (agent/human)
- `planifest-framework/scripts/promote-to-regression.sh` — idempotent promotion script; copies test to regression/, updates manifest
- `planifest-framework/tests/run-tests.sh` — updated to run regression suite as a distinct block

### 6. planifest-ship-agent (SKILL.md update)

Two new steps added before archiving:

**Step R — Regression confirmation:**
Present agent-tagged regression candidates to human. Record confirmed promotions. Run `promote-to-regression.sh` for each confirmed test.

**Step T — Test report:**
Generate `plan/changelog/{feature-id}-test-report-{YYYY-MM-DD}.md` covering:
- All tests run for this plan (from P4 results)
- Full regression pack state (pass/fail counts)
- Newly promoted tests (highlighted)

### 7. test-report template (new)

`planifest-framework/templates/test-report.template.md`

---

## Non-Functional Requirements

| NFR | Target |
|-----|--------|
| Sub-agent token cost | Each sub-agent invocation uses cheaper model tier (haiku-class); codegen-agent full model only |
| Regression run time | Regression pack must complete within P4 CI run; no external dependencies |
| Promotion idempotency | Running promote-to-regression.sh twice produces no duplicates |
| Report completeness | Test report must reference every test file run in P4; no silent omissions |

---

## Build Order

1. Regression-pack infrastructure (scripts, directory, manifest schema)
2. test-report template
3. planifest-test-writer skill
4. planifest-implementer skill
5. planifest-refactor skill
6. planifest-codegen-agent SKILL.md update
7. planifest-ship-agent SKILL.md update
8. run-tests.sh update

---

## Out of Scope

- OpenAPI specification (no HTTP API)
- Data contracts (no data-owning component)
- Retroactive regression promotion for 0000001–0000003
- IaC, Dockerfiles, cloud deployment
