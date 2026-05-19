---
title: "ADR-002: New Session Recommendation Not Block"
summary: "After P9, the orchestrator recommends starting a new session but does not enforce it — the human decides."
status: "accepted"
version: "0.1.0"
---
# ADR-002 - New Session Recommendation Not Block

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000015-pipeline-session-cleanup
**Component:** planifest-orchestrator
**Status:** accepted
**Date:** 2026-05-19

---

## Context

After P9 completes, context window pressure from the completed pipeline run may degrade the quality of the next P0 coaching session. The question is whether the orchestrator should enforce a new session (hard block on continuing) or recommend one (advisory message).

---

## Decision

The orchestrator issues a recommendation after P9 final confirmation but does not block. The message is clear and prominent but the human retains control.

A hard block is not appropriate because:
- The orchestrator cannot prevent a human from continuing — any "block" can be bypassed by simply re-prompting
- Context pressure is real but not catastrophic — P0 coaching quality degrades gracefully
- Blocking would be surprising and frustrating in cases where the human genuinely wants to continue

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Hard block — refuse to start P0 in same session | Maximum enforcement | Easily bypassed; surprising UX; may block legitimate use cases | Rejected — enforcement without effect adds friction without benefit |
| Recommendation (this decision) | Respectful of human autonomy; honest about the trade-off | Human may ignore it | Chosen — recommendation is sufficient; humans who understand the trade-off will comply |
| Silent — no message | Zero friction | Human has no signal that context pressure is an issue | Rejected — the information is valuable; omitting it is unhelpful |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-ship-agent | Adds new-session message to P9 final confirmation step |

---

## Consequences

**Positive:**
- Human is informed of the trade-off without being blocked
- Simple to implement — one message appended to existing P9 output

**Negative:**
- Humans may ignore the recommendation, leading to degraded P0 quality in the same session

**Risks:**
- Low: the recommendation may be overlooked if the P9 output is long — mitigated by placing it last and making it visually distinct (⚡ prefix)

---

## Related ADRs

- None

---

## Supersedes

- None

## Superseded By

- None
