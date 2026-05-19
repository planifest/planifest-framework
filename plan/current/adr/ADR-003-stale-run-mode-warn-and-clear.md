---
title: "ADR-003: Stale Run-Mode Warn-and-Clear at P0"
summary: "When plan/.run-mode is present at P0 start, the orchestrator warns and clears it rather than blocking or silently proceeding."
status: "accepted"
version: "0.1.0"
---
# ADR-003 - Stale Run-Mode Warn-and-Clear at P0

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000015-pipeline-session-cleanup
**Component:** planifest-orchestrator
**Status:** accepted
**Date:** 2026-05-19

---

## Context

If P9 failed to clean up `plan/.run-mode`, the next P0 will find a stale value. Three responses are possible: silent acceptance (use the stale value), hard block (refuse to proceed until cleared manually), or warn-and-clear (surface the issue, auto-remediate, continue). The stale value could silently bypass the run-mode question at P0 and lock the session into continuous mode without the human realising.

---

## Decision

Warn and clear. The orchestrator surfaces a visible warning, deletes the file, and continues P0 without blocking. The human is informed but does not need to take action.

Rationale: stale run-mode is not a data integrity issue — it's a cleanup miss. The correct remediation is automatic. Blocking would penalise the human for a framework bug. Silent acceptance would silently impose a preference the human may not want.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Silent acceptance | Zero friction | Human unknowingly gets continuous mode from a stale file; violates the principle that run mode is always asked fresh | Rejected — silent corruption of session preference |
| Hard block | Maximum visibility | Penalises human for a framework bug; requires manual file deletion | Rejected — remediation should be automatic |
| Warn-and-clear (this decision) | Visible, self-healing, non-blocking | Human sees a warning they may not understand | Chosen — best balance of transparency and usability |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-orchestrator | P0 pre-flight gains stale run-mode check before sentinel write |

---

## Consequences

**Positive:**
- Stale run-mode is always detected and cleared — no silent session contamination
- No human action required; P0 proceeds normally

**Negative:**
- Human sees an unexpected warning that requires understanding the run-mode concept

**Risks:**
- Low: the warning message must be clear enough that the human understands it is self-resolving

---

## Related ADRs

- ADR-004 — related-to (run-mode deletion at P9 is the complement to this stale detection at P0)

---

## Supersedes

- None

## Superseded By

- None
