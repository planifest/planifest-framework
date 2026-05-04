# Changelog — 0000004-tdd-regression-test-quality — 2026-05-01

**Feature:** TDD Sub-Loop, Regression Pack, and Test Reporting
**Pipeline run:** P0 Assess → P1 Spec → P2 ADRs → P3 Codegen → P4 Validate → P5 Security → P6 Docs → P7 Ship
**PR:** (pending — raise manually: `gh pr create --title "feat(0000004): TDD sub-loop, regression pack, test reporting"`)

## What Was Built

Structured test-driven development introduced into the Planifest P3 codegen phase:

- **TDD inner loop** in `planifest-codegen-agent`: per-requirement red→green→refactor sub-loop orchestrating three new narrow sub-agents. Escalates to human after 3 failed attempts on any single requirement.
- **3 new sub-agent skills** in `planifest-framework/skills/`:
  - `planifest-test-writer` — writes one failing test, confirms RED
  - `planifest-implementer` — writes minimum passing code, confirms GREEN
  - `planifest-refactor` — improves quality, confirms full suite green
  - All three declare `recommended_model: haiku` for cost efficiency
- **Regression pack infrastructure**: `planifest-framework/tests/regression/` directory, `regression-manifest.json` (tracks promotions by feature/date/agent), `promote-to-regression.sh` (idempotent, POSIX/Windows path compatible)
- **`run-tests.sh` updated**: regression suite runs as a distinct labelled block with separate pass/fail counts in summary
- **`planifest-ship-agent` updated**: Step R (regression candidate confirmation) and Step T (test report generation) added before archive
- **test-report template** at `planifest-framework/templates/test-report.template.md`

## Artefacts Produced

**plan/current/ artefacts:**
- `design.md` — confirmed design
- `execution-plan.md` — 8-item build order, NFRs
- `requirements/` — 14 requirement files (req-001 through req-014)
- `scope.md`, `risk-register.md`, `domain-glossary.md`, `operational-model.md`, `slo-definitions.md`, `cost-model.md`
- `adr/ADR-001-tdd-inner-loop-as-codegen-subloop.md`
- `adr/ADR-002-subagent-model-tier-convention.md`
- `adr/ADR-003-regression-promotion-criteria.md`

**Framework files changed/added:**
- `planifest-framework/skills/planifest-test-writer/SKILL.md` (new)
- `planifest-framework/skills/planifest-implementer/SKILL.md` (new)
- `planifest-framework/skills/planifest-refactor/SKILL.md` (new)
- `planifest-framework/skills/planifest-codegen-agent/SKILL.md` (updated — TDD inner loop)
- `planifest-framework/skills/planifest-ship-agent/SKILL.md` (updated — Steps R + T)
- `planifest-framework/scripts/promote-to-regression.sh` (new)
- `planifest-framework/tests/regression/` (new — empty pack, ready)
- `planifest-framework/tests/regression/regression-manifest.json` (new)
- `planifest-framework/tests/test-regression-pack.sh` (new — 17 tests)
- `planifest-framework/tests/run-tests.sh` (updated — regression block)
- `planifest-framework/templates/test-report.template.md` (new)

## Decisions

- **ADR-001**: TDD loop as codegen-agent inner sub-loop — not a new pipeline phase; additive and preserves existing orchestration
- **ADR-002**: `recommended_model: haiku` frontmatter convention — advisory, portable, non-blocking on unsupported tools
- **ADR-003**: Agent-tag candidates at P3 + human-confirm at P7 Step R — balances automation with human curation

## Skipped Phases

None.

## Test Results

- `test-regression-pack.sh`: 17/17 passed
- `test-skill-sync-security.sh`: 13/13 passed (pre-existing, no regression)
