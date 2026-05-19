---
title: "Risk Register - 0000014-improve-adoption-mode-selection"
---
# Risk Register - 0000014-improve-adoption-mode-selection

## RISK-001
- **Category:** Technical
- **Description:** The "always retrofit" bug in `design.template.md` may be caused by the orchestrator write logic rather than the template itself — fix target could be wrong.
- **Likelihood:** Medium
- **Impact:** Low (bug persists in design.md output but is caught at P0 review; no runtime consequence)
- **Mitigation:** Investigate both the template and the orchestrator write path during REQ-007 implementation; document root cause in commit message.

## RISK-002
- **Category:** Operational
- **Description:** The migration (REQ-008) is interactive — if the human loses context mid-migration (e.g. session interruption after progress file write), resumed session may not re-load migration context correctly.
- **Likelihood:** Low
- **Impact:** Medium (archive corrections could be inconsistent)
- **Mitigation:** Progress file records each archive's old and new value; resuming planifest-migrator re-presents the last confirmed decision for human review before continuing.

## RISK-003
- **Category:** Technical
- **Description:** REQ-012 requires adding the one-question rule to 9 phase skills. If any skill is missed, the behaviour is inconsistent across phases.
- **Likelihood:** Medium
- **Impact:** Low (inconsistency in UX, not a functional failure)
- **Mitigation:** Acceptance criteria require explicit verification that all 9 skills contain the instruction. P4 validation checks for the rule's presence in each skill file.

## RISK-004
- **Category:** Technical
- **Description:** `docs/about.md` write at P7 is blocking — if the write fails for an unexpected reason (e.g. permissions), the pipeline halts and the human must resolve manually before P8/P9 can proceed.
- **Likelihood:** Low
- **Impact:** Medium (pipeline stall at late stage)
- **Mitigation:** Ship-agent creates `docs/` defensively before writing; error message names the failure reason and the resolution path.

## RISK-005
- **Category:** Operational
- **Description:** Scope Lock Challenge scenarios are derived by the agent from the feature — if the agent's scenario derivation misses a category (e.g. never asks about cross-session continuity for a stateful feature), the challenge provides false confidence.
- **Likelihood:** Medium
- **Impact:** Medium (scope creep not caught at P0)
- **Mitigation:** REQ-017 (Feature Brief Scenario Paths) provides human-authored scenarios as a complement; the two approaches together reduce the risk of blind spots.

## RISK-006
- **Category:** Technical
- **Description:** The migration's adoption mode auto-detection from archive context clues (feature name, problem statement) may produce wrong best-guesses for ambiguous archives.
- **Likelihood:** Medium
- **Impact:** Low (human confirms each decision before it is applied)
- **Mitigation:** The migration always presents its rationale alongside the best-guess; human confirmation is required before any correction is written.
