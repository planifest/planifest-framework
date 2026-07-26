---
title: "ADR 003: Scope Lock Suggested Answers via On-Demand Subagent"
summary: "The orchestrator always offers a suggested-answer option at each Scope Lock Challenge question, but only dispatches the drafting subagent on explicit human request — never pre-emptively — keeping scope decisions human-owned while offering drafting help."
status: "accepted"
version: "0.1.0"
---
# ADR-003 - Scope Lock Suggested Answers via On-Demand Subagent

**Skill:** [adr-agent](../../../planifest-framework/skills/planifest-adr-agent/SKILL.md)
**Tool:** claude-code
**Model:** claude-sonnet-5
**Feature:** 0000017-ratchet-forgery-detection-and-telemetry-schema-spec
**Component:** planifest-framework
**Status:** accepted
**Date:** 2026-07-25

---

## Context

During this session's own Scope Lock Challenge, the orchestrator initially answered scenario questions from a build/pipeline perspective rather than a feature-usage perspective, requiring repeated human correction: build-vs-usage framing, outcome-vs-action framing for tooling/process items, N/A recognition for static content with no runtime state, and a hard rule that no item is ever confirmed without an explicit human affirmative. The human wants this rigor available as drafting help for future features, but without it becoming a rubber stamp — the risk being that offering a suggested answer by default could push humans toward passive acceptance rather than active scope decisions.

---

## Decision

At each Scope Lock Challenge question, the orchestrator always asks the human first, and always offers a "want me to suggest an answer?" option — never silently skipped — but only dispatches the drafting work (a new `planifest-scope-lock-agent` skill/subagent) on explicit human request, never pre-emptively.

The subagent's draft is governed by the rigor spec hardened through this session's live corrections:
- Usage-only framing — describes only how the finished feature behaves for people using it, never the build/pipeline/implementation process
- Outcome, not action — for tooling/process items, describes the resulting state a user/reader/operator experiences, never the act of running a tool
- Explicit N/A recognition — when a scenario question doesn't meaningfully apply, says so with a reason rather than manufacturing an artificial narrative
- Consistency check — checks the suggestion against the latest confirmed decisions for that item, explicitly flagging any contradiction, unresolved concern, or gap the plain-usage phrasing exposes, never smoothing it over (skipped silently only when no confirmed decisions yet exist to check against)
- No implicit confirmation — a draft is never self-confirming; only an explicit human affirmative per item counts, with silence, no-objection, or topic-change never read as approval; every explicit confirmation is written to `build-log.md` immediately as the durable record

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Always pre-draft a suggested answer automatically | Faster for the human — no need to ask | Risks passive rubber-stamping of drafts the human didn't actually request; contradicts the human's explicit instruction this session | Rejected per direct human instruction |
| Never offer suggested answers — human must always answer from scratch | Guarantees active engagement, zero rubber-stamping risk | Loses the drafting assistance the human explicitly wants available | Rejected — the human wants the option, just not forced |
| Offer on every question, draft only on explicit request (this decision) | Assistance available without being pushed; the ask itself keeps the human in an active decision-making frame | Adds one extra exchange (offer, then possible request) per question when the human does want a draft | Chosen — matches the human's explicit instruction and preserves active engagement |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| `planifest-orchestrator` skill | Scope Lock Challenge section updated to always offer the suggested-answer option |
| `planifest-scope-lock-agent` (new skill) | Authored under req-005 to implement the rigor spec above |

---

## Consequences

**Positive:**
- Scope decisions stay human-owned even when drafting help is used
- The same rigor spec that caught a real gap in this session's own dogfooding (the 0000008 hand-typing-reliability gap, surfaced by forcing plain-usage phrasing) becomes a repeatable mechanism for future features

**Negative:**
- Adds a new skill file to maintain and a new protocol step (the offer) to every Scope Lock Challenge question, even when the human never requests a draft

**Risks:**
- The consistency-check and confirmation-discipline rules depend on `build-log.md` being read faithfully on resume — if that durable-record convention is ever skipped, the "no implicit confirmation" guarantee weakens to trust alone; mitigated by req-005's explicit requirement that every confirmation is written to `build-log.md` immediately

---

## Related ADRs

- ADR-007 (0000014) derived-scope-lock-scenarios - extends (adds a suggested-answer capability on top of the existing agent-derived-scenario mechanism)
- ADR-008 (0000014) one-question-at-a-time - related-to (the offer-then-draft flow still asks one question at a time)

---

## Supersedes

- None

## Superseded By

- None

---

*Generated by adr-agent.*
