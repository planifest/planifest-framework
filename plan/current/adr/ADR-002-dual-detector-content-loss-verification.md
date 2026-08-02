---
title: "ADR 002: Dual-Detector Content-Loss Verification"
summary: "This feature verifies zero enforcement-content loss with two detectors, not one: the existing regression pack, and the mandatory P4 diff review formally named as the systematic check for what the pack does not pin. Both resolve a finding the same way - relocate the pointer or restore the content, never weaken the check."
status: "accepted"
version: "0.1.0"
---
# ADR-002 - Dual-Detector Content-Loss Verification

**Skill:** [adr-agent](../skills/adr-agent-SKILL.md)
**Feature:** 0000022-orchestrator-redundancy-removal
**Component:** planifest-framework (skills/planifest-orchestrator)
**Date:** 2026-08-02

## Context

This feature removes and relocates roughly ten distinct content areas from `planifest-framework/skills/planifest-orchestrator/SKILL.md`, operating under 0000021 ADR-002's mandate that a guardrailed baseline-gated trim must produce zero enforcement-content loss. The regression pack at `planifest-framework/tests/regression/` (22 tests) is the safety net that mandate assumes. Inspection of that pack shows only 4 of the 22 tests actually grep or assert against orchestrator-specific content; the remaining 18 cover other parts of the framework. A cut that removes the sole statement of a rule from a section none of those 4 tests pin would not turn the pack red - it would ship silently, leaving roughly 6 of the 10 trim areas in this feature with no automated tripwire.

This gap was surfaced during the P0 Scope Lock Challenge, specifically the error/sad-path question, by the scope-lock agent. The human on the loop confirmed the closure: this feature's plan already requires a P4 diff review ("every removed instruction verifiably stated in exactly one canonical file") as an acceptance criterion, but that review was not named as a detector or given a defined resolution rule for what happens when it finds a problem.

## Decision

This feature verifies content loss with two detectors, not one.

Detector 1 is the existing regression pack: it catches any orchestrator content loss that one of the 4 orchestrator-pinning tests happens to assert against.

Detector 2 is the mandatory P4 diff review already required by this feature's acceptance criteria. It is formally named here as the systematic detector for the remaining trim areas the regression pack does not pin - a full diff of every removal against the destination files, confirming each removed instruction is verifiably stated in exactly one canonical file.

Both detectors resolve a finding the same way: if the content was relocated, update the pointer (or the test, if one exists) to the new canonical location; if the content was the sole statement of a rule and no relocation target holds it, the cut was wrong and the content is restored. Neither detector's finding may be resolved by weakening or deleting a check, in either the regression pack or the diff review's own criteria.

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Rely on the regression pack alone, as 0000021 ADR-002's process describes by default | No new process to define; matches the established baseline-gated trim pattern | Only 4 of 22 tests pin orchestrator content; roughly 6 of this feature's 10 trim areas would have no automated check | Leaves the majority of this feature's scope unverified by any mechanism, defeating the zero-content-loss mandate it operates under |
| Write new regression tests to pin every content area this feature touches, so the pack alone becomes sufficient | Fully automated going forward; closes the gap with the same mechanism as Detector 1 | Roughly 6 new tests whose only purpose is to duplicate a one-time P4 diff review; adds permanent test-maintenance surface for a one-time verification need | Disproportionate for this feature; new regression tests remain the right tool for content areas future features will touch again, not for a one-time trim |
| Do the P4 diff review informally, without naming it as a detector or defining its resolution rule | No additional documentation burden; review already required by acceptance criteria | The Scope Lock Challenge specifically found the brief's error path defined resolution only for a test failure, not a diff-review finding; informal treatment leaves room for a finding to be rationalised away instead of restored | Inconsistent resolution was the exact gap surfaced by the scope-lock agent; leaving it informal does not close it |

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-framework | Governs process for this feature's own P4 gate only; no code or schema change. Defines that P4 diff review findings follow the same restore-or-relocate resolution rule as regression-pack failures. |

## Consequences

**Positive:**
- Every one of the 10 content areas in scope now has an explicit, defined verification path, not just the roughly 40% covered by existing regression tests.
- The resolution rule (restore the content, or relocate the pointer - never rationalise a finding away) is recorded and citable rather than left implicit in the acceptance criteria.

**Negative:**
- The P4 diff review is a manual, human-and-agent judgement step rather than a deterministic test, making it slower and dependent on reviewer thoroughness in a way an automated regression test is not.

**Risks:**
- A rushed or incomplete diff review could still miss a lost rule in the roughly 6 trim areas the regression pack does not pin, since Detector 2 is not enforced by a deterministic gate the way `ratchet-check.mjs` enforces scope-weakening elsewhere in the framework.

## Related ADRs

- ADR-001 (agent-dispatch-standards-file) - related-to (both are P2 decisions for this same feature; no dependency between them)
- 0000021 ADR-002 (guardrailed baseline-gated trim process) - depends-on (this ADR operates within that upstream process)

## Supersedes

- none

## Superseded By

- none
