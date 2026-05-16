---
title: "Risk Register - 0000004-tdd-regression-test-quality"
status: "active"
version: "0.1.0"
---
# Risk Register - 0000004-tdd-regression-test-quality

**Feature:** 0000004-tdd-regression-test-quality
**Overall Risk Level:** medium

> Every entry is specific to this feature.

---

## Risks

| ID | Category | Description | Likelihood | Impact | Mitigation | Status |
|----|----------|-------------|------------|--------|------------|--------|
| R-001 | technical | Sub-agent token cost: 3 sub-agents × N requirements multiplies context cost significantly. On large requirement sets (>10 reqs), total token spend may exceed the cost of the original single-pass codegen approach. | medium | medium | Cheaper model tier (haiku-class) for all three sub-agents. Narrow skill prompts keep context small. Stack capability skill loaded only when declared in stack. | open |
| R-002 | operational | Regression pack staleness: promoted tests may break as the framework evolves, producing false failures that block P7 ship. | medium | high | Regression pack runs in full on every P4; failures block P7. Failed tests must be triaged and either fixed or explicitly removed from the pack by a human. | open |
| R-003 | technical | Sub-agent coordination failure: test-writer writes a test the implementer cannot satisfy (e.g. due to incorrect test assumptions or incompatible framework API). | low | medium | codegen-agent detects red→green failure after 3 attempts and escalates to human before proceeding. Pipeline does not auto-skip the requirement. | open |
| R-004 | technical | Agent SDK model override not supported: Claude Code Agent tool may not support per-invocation model override, making `recommended_model` frontmatter advisory only. | medium | low | `recommended_model` is documented as advisory convention, not hard enforcement. Risk is cost only — no functional impact. Mitigated by documenting in ADR. | open |
| R-005 | operational | Test report completeness drift: if P4 validate-agent does not output a machine-readable list of tests run, the ship-agent cannot guarantee the report references every test. | low | medium | Test report template explicitly references P4 output. ship-agent SKILL.md requires the validate-agent to produce a test list artefact. If not available, human must manually verify. | open |
| R-006 | technical | promote-to-regression.sh idempotency broken by concurrent runs: two simultaneous promotion runs could produce duplicate manifest entries. | low | low | Script uses a read-modify-write pattern on a local JSON file. Concurrent execution is unlikely in single-agent pipelines. Idempotency test (req-014) catches regressions in the implementation. | open |

---

## Assumptions Logged as Risks

| ID | Assumption | Impact if Wrong | Status |
|----|------------|-----------------|--------|
| A-001 | Stack capability skills (e.g. `webapp-testing`) are available for the declared stack at P3 time. | Sub-agents proceed without capability skill; code quality degrades but pipeline does not block. | open |
| A-002 | Claude Code Agent tool supports model override per sub-agent invocation. | All sub-agents run at default model tier; cost mitigation not realised. No functional impact. | open |
| A-003 | Existing tests in `planifest-framework/tests/` are not retroactively classified into regression vs. feature-specific. | Regression pack starts empty; operators manually seed it after first P7 ship of this feature. | open |
