---
title: "ADR-004: Run-Mode Deletion Owned by P9"
summary: "plan/.run-mode is deleted at P9 cleanup, not at P0 start. P0 handles the stale case as a recovery path only."
status: "accepted"
version: "0.1.0"
---
# ADR-004 - Run-Mode Deletion Owned by P9

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000015-pipeline-session-cleanup
**Component:** planifest-ship-agent
**Status:** accepted
**Date:** 2026-05-19

---

## Context

`plan/.run-mode` is written at P0 and read throughout the pipeline. Two components could own its deletion: P9 (as part of pipeline close-out cleanup) or P0 (as part of each fresh-start pre-flight). The choice determines where responsibility lives and what happens if P9 is skipped.

---

## Decision

P9 owns deletion. `plan/.run-mode` is deleted in ship-agent Step 6 alongside `.orchestrator-active` and `.orchestrator-ack`. P0 handles the stale case (file present at fresh start) as a recovery path — not the primary deletion path.

This keeps lifecycle ownership clear: P9 opens and closes the pipeline state. P0 reads state it does not own. Recovery at P0 handles the edge case where P9 did not complete.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| P0 deletes run-mode at every start | Guaranteed clean state regardless of prior P9 | P0 would destroy a valid run-mode if P0 is invoked mid-pipeline for any reason; unclear lifecycle ownership | Rejected — P0 deleting state it didn't create is the wrong ownership model |
| P9 deletes (this decision) | Clear lifecycle: P9 creates/closes pipeline state | If P9 is skipped, run-mode persists until P0 recovery | Chosen — correct ownership; P0 recovery handles the edge case |
| Both P0 and P9 delete | Belt-and-suspenders | Duplication; two owners for the same file | Rejected — single ownership is cleaner; recovery path at P0 is sufficient |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-ship-agent | Step 6 adds `plan/.run-mode` deletion |
| planifest-orchestrator | P0 pre-flight adds stale detection as recovery path (see ADR-003) |

---

## Consequences

**Positive:**
- Clear single ownership: P9 closes what P0 opens
- Ship-agent Step 6 is the canonical cleanup step — one place to look for all sentinel cleanup

**Negative:**
- If P9 is skipped (via `.skips`), run-mode persists and is only recovered at the next P0 start

**Risks:**
- Low: P9 skip is an explicit human action; the P0 recovery path handles it cleanly

---

## Related ADRs

- ADR-003 — related-to (P0 stale detection is the recovery path for this deletion)

---

## Supersedes

- None

## Superseded By

- None
