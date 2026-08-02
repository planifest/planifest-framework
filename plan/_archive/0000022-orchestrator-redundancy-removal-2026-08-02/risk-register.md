---
title: "Risk Register - orchestrator-redundancy-removal"
summary: "Technical, operational, and security risks with their mitigations."
status: "draft"
version: "0.1.0"
---
# Risk Register - orchestrator-redundancy-removal

**Skill:** [spec-agent](../skills/spec-agent-SKILL.md) (updated by any agent that identifies a new risk)
**Feature:** 0000022-orchestrator-redundancy-removal
**Version:** 0.22.0
**Overall Risk Level:** medium

## Risks

| ID | Category | Description | Likelihood | Impact | Mitigation | Status |
|----|----------|------------|------------|--------|-----------|--------|
| R-001 | technical | A cut removes the sole statement of a rule that none of the 22 regression tests pin - corrected at req-001's baseline: 10 of 22 tests pin orchestrator content (not the 4 estimated at P0), but the untested items (Fast Path detail, reversal execute/assess mechanics, Change Pipeline confirm questions) remain confirmed-unpinned by any test | medium | high | Dual detector per Scope Lock error-path answer and ADR-002: P4 diff review is the named second detector; any rule found lost by either detector is restored, never rationalised away | open |
| R-002 | technical | A regression test pins a phrase scheduled for relocation or trim and goes red for a reason unrelated to actual content loss (the content moved, it did not disappear) - materialised once during req-002 drafting: the original plan would have broken test-0000016 (Hard Limit 7 push-cadence, reversal-assessor name) and test-0000017-req-006 (Structured Discovery Pass preamble) before any edit landed | high | low | req-001's baseline enumerated the actual 10-test inventory (not the P0 estimate) and req-002/req-004 were corrected before any edit; req-004 additionally re-runs the 9 unaffected tests individually post-edit to confirm | mitigated |
| R-003 | technical | The new standards file (req-003) is not loaded at the moment a phase skill needs the Model Tier Decision Table or Parallelism Rules, producing a silent behavioural gap where a subagent is dispatched without model-tier guidance | low | high | req-003 requires the orchestrator, ship-agent, and codegen-agent to carry an explicit pointer to the new file, mirroring the existing JIT-load pattern already used for phase skills | open |
| R-004 | operational | req-002, req-003, and req-004 all edit `planifest-orchestrator/SKILL.md`; if worked without care, overlapping edits could conflict or one requirement's diff could silently undo another's | medium | medium | Requirements target non-overlapping sections by design (Class 1 vs Class 2 vs Class 3 content); Hard Limit 7's granular-commit convention means each requirement lands as its own reviewable commit, making an overwrite visible immediately via git status/diff before the next commit | open |
| R-005 | compliance | 0000021 ADR-002 mandates a baseline-gated trim process with zero enforcement-content loss as the pass condition; skipping or rushing req-001's baseline would leave this feature unable to prove that condition was met | low | high | req-001 is a hard dependency for every other requirement; the P1 gate checklist and req-001's acceptance criteria both require the baseline commit to exist before any SKILL.md edit | open |

## Assumptions Logged as Risks

Documented assumptions from the specification are logged here with likelihood: medium.

| ID | Assumption | Impact if Wrong | Status |
|----|-----------|----------------|--------|
| A-001 | The per-section word estimates in the discovery findings table (~2,900-3,300 removable words) were approximate; the 7,600-word ceiling was the initial binding target | Materialised as predicted: after all in-scope items landed (1,787 words removed, zero content loss), the remaining ~992-word gap was reviewed and found to be dense P0 operative content, not duplication or exposition. Human confirmed a revised 8,600-word ceiling on 2026-08-02 rather than cutting further. | closed |
| A-002 | A new standards file (`agent-dispatch-standards.md`, per req-003) is an acceptable home for model-tier and parallelism content rather than an existing standards file | P2 ADR could instead select an existing file (e.g. folding into `telemetry-standards.md`'s sibling or a new dedicated file); no scope change either way, only a naming decision | open |
