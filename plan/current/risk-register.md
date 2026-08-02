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
| R-001 | technical | A cut removes the sole statement of a rule that none of the 22 regression tests pin (only 4 tests grep orchestrator content against ~10 trim areas), so no test catches the loss | medium | high | Dual detector per Scope Lock error-path answer: P4 diff review is the named second detector; any rule found lost by either detector is restored, never rationalised away | open |
| R-002 | technical | A regression test pins a phrase scheduled for relocation and goes red for a reason unrelated to actual content loss (the content moved, it did not disappear) | high | low | req-004 enumerates every orchestrator-content-pinning test before edits land and updates its assertion to the new canonical location in the same commit as the move | open |
| R-003 | technical | The new standards file (req-003) is not loaded at the moment a phase skill needs the Model Tier Decision Table or Parallelism Rules, producing a silent behavioural gap where a subagent is dispatched without model-tier guidance | low | high | req-003 requires the orchestrator, ship-agent, and codegen-agent to carry an explicit pointer to the new file, mirroring the existing JIT-load pattern already used for phase skills | open |
| R-004 | operational | req-002, req-003, and req-004 all edit `planifest-orchestrator/SKILL.md`; if worked without care, overlapping edits could conflict or one requirement's diff could silently undo another's | medium | medium | Requirements target non-overlapping sections by design (Class 1 vs Class 2 vs Class 3 content); Hard Limit 7's granular-commit convention means each requirement lands as its own reviewable commit, making an overwrite visible immediately via git status/diff before the next commit | open |
| R-005 | compliance | 0000021 ADR-002 mandates a baseline-gated trim process with zero enforcement-content loss as the pass condition; skipping or rushing req-001's baseline would leave this feature unable to prove that condition was met | low | high | req-001 is a hard dependency for every other requirement; the P1 gate checklist and req-001's acceptance criteria both require the baseline commit to exist before any SKILL.md edit | open |

## Assumptions Logged as Risks

Documented assumptions from the specification are logged here with likelihood: medium.

| ID | Assumption | Impact if Wrong | Status |
|----|-----------|----------------|--------|
| A-001 | The per-section word estimates in the discovery findings table (~2,900-3,300 removable words) are approximate; the 7,600-word ceiling is the binding target | If actual removable content falls short of the ceiling, req-004's Class 3 trims go deeper, or the human on the loop renegotiates the ceiling before req-005's final check | open |
| A-002 | A new standards file (`agent-dispatch-standards.md`, per req-003) is an acceptable home for model-tier and parallelism content rather than an existing standards file | P2 ADR could instead select an existing file (e.g. folding into `telemetry-standards.md`'s sibling or a new dedicated file); no scope change either way, only a naming decision | open |
