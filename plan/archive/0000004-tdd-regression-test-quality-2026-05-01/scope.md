---
title: "Scope - 0000004-tdd-regression-test-quality"
status: "active"
version: "0.1.0"
---
# Scope - 0000004-tdd-regression-test-quality

**Feature:** 0000004-tdd-regression-test-quality

> All three sections are present. See design.md for full context.

---

## In Scope

- **TDD inner loop protocol** added to `planifest-codegen-agent/SKILL.md`: per-requirement red→green→refactor sub-loop orchestrating three sub-agents in sequence.
- **planifest-test-writer skill** (new): narrow skill; writes one failing test per requirement (red phase); `recommended_model: haiku`.
- **planifest-implementer skill** (new): narrow skill; writes minimum code to pass the failing test (green phase); `recommended_model: haiku`.
- **planifest-refactor skill** (new): narrow skill; improves code quality while keeping all tests green (refactor phase); `recommended_model: haiku`.
- **Escalation protocol**: codegen-agent escalates to human after 3 failed red→green attempts on a single requirement.
- **Sub-agent model tier convention**: `recommended_model` frontmatter field on each sub-agent SKILL.md; rationale documented.
- **Regression pack directory**: `planifest-framework/tests/regression/` — long-term curated test suite distinct from feature-specific tests.
- **regression-manifest.json**: tracks promoted tests with name, sourceFeature, promotionDate, promotedBy, filePath.
- **promote-to-regression.sh**: idempotent bash script; copies test to regression dir, updates manifest.
- **run-tests.sh update**: regression suite runs as a distinct labelled block; pass/fail counts included in summary.
- **test-report template**: `planifest-framework/templates/test-report.template.md` covering plan tests, regression state, newly promoted tests.
- **ship-agent Step R** (regression confirmation): presents agent-tagged candidates to human, records decisions, invokes promotion script.
- **ship-agent Step T** (test report generation): generates `plan/changelog/{feature-id}-test-report-{YYYY-MM-DD}.md` before archiving.
- **Tests for regression infrastructure**: `test-regression-pack.sh` covering promotion, idempotency, manifest validity, run-tests.sh integration.
- **ADRs**: model tier selection, regression promotion criteria, TDD sub-loop protocol.

---

## Out of Scope

- OpenAPI specification — no HTTP API is introduced.
- Data contracts — no data-owning component.
- IaC, Dockerfiles, cloud deployment — local framework tooling only.
- Retroactive regression promotion for features 0000001–0000003.
- Changes to `planifest-validate-agent`, `planifest-spec-agent`, or `planifest-adr-agent`.
- TDD loop for stacks beyond what existing stack capability skills cover.
- External CI/CD test reporting integrations (e.g. Allure, Datadog Test Visibility).
- Windows PowerShell equivalents of `promote-to-regression.sh` or `run-tests.sh` additions.

---

## Deferred

- **ML-based automatic regression candidate scoring** — blocked until sufficient regression history exists to train a scoring model.
- **Cross-feature regression trend dashboard** — blocked until regression pack has multi-feature history; deferred to a future framework feature.
- **Regression flakiness detection** — blocked until regression pack runs enough times to establish flakiness baseline.
- **PowerShell parity for regression scripts** — deferred; `skill-sync.ps1` parity work is a separate concern. Until resolved, Windows users must run regression scripts via WSL or Git Bash.
