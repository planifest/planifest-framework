---
title: "ADR-003 - Optimise-agent is suggestion-only"
status: "accepted"
date: "04 May 2026"
feature: "0000007-agent-optimisation"
---
# ADR-003 — Optimise-agent is suggestion-only; never auto-applies changes

## Context

The optimise-agent reviews Planifest skill files and identifies superfluous content. The question was whether it should apply confirmed removals directly or only accumulate a list of confirmed suggestions for a subsequent Change Pipeline run.

## Decision

The optimise-agent never modifies files. It presents suggestions, accumulates confirmed items into a numbered list, and produces a summary suitable as Change Pipeline input. Applying changes is a separate pipeline run.

## Alternatives Considered

| Option | Pros | Cons | Rejected because |
|--------|------|------|-----------------|
| Auto-apply each confirmed item immediately | Faster; fewer steps | No review of the accumulated set before applying; hard to undo a batch of interleaved edits; bypasses the Change Pipeline audit trail | Confirmed items seen individually may feel small; seeing the full list before applying gives the human a chance to reconsider scope |
| Auto-apply all at the end of the session | Still accumulates a reviewable list first | Still bypasses the Change Pipeline; no test run, no P8 assessment of the changes | Framework changes must go through the pipeline for test coverage and build assessment |
| Suggestion-only → Change Pipeline (chosen) | Human sees full confirmed list before any change; changes go through P3/P4/P8 for tests and assessment | Requires an extra pipeline run | Correctness and auditability outweigh the extra step |

## Affected Components

- `planifest-framework/skills/planifest-optimise-agent/SKILL.md` — hard constraint: no Write/Edit tool calls

## Consequences

**Positive:**
- All confirmed removals are tested (the Change Pipeline runs the test suite)
- A P8 Build Assessment runs on the resulting changes
- Human sees the full confirmed list before anything changes
- No accidental partial application if the session is interrupted

**Negative:**
- Two steps required: optimise-agent session + Change Pipeline run
- Human must manually initiate the Change Pipeline with the summary

**Risks:**
- Human may lose the confirmed-changes summary between sessions — mitigated by the summary being the last output of the session and clearly formatted for copy-paste

## Related ADRs

- None
