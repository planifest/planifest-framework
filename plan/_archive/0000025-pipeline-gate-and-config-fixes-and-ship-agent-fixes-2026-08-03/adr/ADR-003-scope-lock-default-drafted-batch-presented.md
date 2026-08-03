---
title: "ADR 003: Scope Lock Default-Drafted, Batch-Presented Answers"
summary: "The Scope Lock Challenge now dispatches planifest-scope-lock-agent for all four scenario-path questions in parallel by default and presents all four drafts together for one batch review pass, with per-item explicit accept/edit/reject still required and recorded immediately — narrowly scoped against 0000014-ADR-008, which remains in force everywhere else."
status: "accepted"
version: "0.1.0"
---
# ADR-003 - Scope Lock Default-Drafted, Batch-Presented Answers

**Skill:** [adr-agent](../../../planifest-framework/skills/planifest-adr-agent/SKILL.md)
**Tool:** claude-code
**Model:** claude-sonnet-5
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Component:** planifest-framework
**Status:** accepted
**Date:** 2026-08-03

---

## Context

`0000017-ADR-003` ("Scope Lock Suggested Answers via On-Demand Subagent") established that the orchestrator's Scope Lock Challenge always asks each of the four scenario-path questions (happy path, first-run path, error/sad path, cross-session continuity) one at a time, and always offers "want me to suggest an answer first?" in the same turn — but only dispatches `planifest-scope-lock-agent` on explicit human request, never pre-emptively. That decision was made to guard against passive rubber-stamping of unrequested drafts.

Two backlog entries subsequently reversed that judgment from lived experience:

- `plan/backlog/0000029-scope-lock-drafts-always-presented/entry.md` (filed from feature 0000022's own P0): the offer-then-opt-in flow adds a round trip per question — up to eight exchanges for four answers — "with no governance benefit: the human's explicit per-item accept/edit/reject remains the only thing that counts either way." The human directed that the draft should simply always be there when the question is asked.
- `plan/backlog/0000040-scope-lock-default-to-drafted-answers/entry.md` (filed from feature 0000017's own P0): the human called the opt-in-only default "a bug," and separately asked that all four drafts be presented together in one batch rather than one-at-a-time sequencing waiting for a per-question answer before drafting/showing the next.

`req-007-scope-lock-default-drafted-batch.md` (this feature) merges both entries into a single requirement: dispatch `planifest-scope-lock-agent` for all four scenario-path questions in parallel by default, present all four together, and have the human complete one review pass while still giving a separate explicit accept/edit/reject per item, with each item's `build-log.md` entry written immediately on that item's own confirmation. req-007 explicitly assigns authoring the superseding ADR to P2 (this ADR) as a hard dependency, and explicitly calls out that the reversal must be scoped narrowly against `0000014-ADR-008` (One-Question-at-a-Time as Framework-Wide Instruction) so it does not read as a silent framework-wide reversal of that convention.

This ADR supersedes `0000017-ADR-003` for the Scope Lock Challenge specifically.

---

## Decision

The Scope Lock Challenge changes from sequential, opt-in-per-question drafting to default-drafted, batch-presented drafting:

1. **Default parallel dispatch, no opt-in.** The orchestrator dispatches `planifest-scope-lock-agent` for all four scenario-path questions (happy path, first-run path, error/sad path, cross-session continuity) in parallel, by default, before presenting any question to the human. The per-question "want me to suggest an answer first? yes/no" offer is removed — drafting is no longer gated on a human request. Each dispatch remains a fresh-context subagent scoped to exactly one question, receiving the same inputs the prior on-request dispatch received (the scenario-path question, feature brief, requirements/ADRs confirmed so far, and latest confirmed decisions to check against, if any exist yet) — not the coaching conversation history.
2. **Batch presentation.** The orchestrator presents all four questions together with their labelled drafts in a single turn, not one question at a time waiting for an answer before drafting or showing the next.
3. **Per-item confirmation is unchanged and non-negotiable.** The human reviews the batch in one pass but still gives a separate, explicit accept / edit / reject for each of the four items individually. No blanket or implied confirmation across multiple items is ever read as approval for any of them. The moment the human gives that explicit affirmative for one item, it is recorded to `plan/current/build-log.md` immediately — using the existing capture format and source labels (`agent-draft-accepted` / `agent-draft-edited` / `human`) — not deferred until the whole batch is confirmed.
4. **Partial-failure fallback.** If one of the four parallel dispatches fails, the orchestrator presents the three successful drafts plus a clear failure marker for the fourth, and falls back to the original blank-question, opt-in flow for that one item only. A single failed dispatch never blocks or discards the rest of the batch.
5. **`planifest-scope-lock-agent`'s invocation contract is unchanged.** Fresh-context subagent, single-question scope, never self-confirms, never advances the Scope Lock sequence, never writes `build-log.md` itself. Only the trigger (automatic-by-default vs. on-explicit-request) and the batch cardinality (four dispatched together vs. one at a time) change. The five drafting rules in `planifest-scope-lock-agent/SKILL.md` — usage-only framing, outcome not action, N/A recognition, consistency check, no implicit confirmation — are unchanged and remain fully authoritative.

**Explicit scope bound against `0000014-ADR-008`:** This change applies **only** to the Scope Lock Challenge's four scenario-path questions. `0000014-ADR-008`'s one-question-at-a-time convention remains in force everywhere else in the framework — coaching Q&A, clarifying questions raised when a Scope Lock answer reveals a gap, phase gates, and every other human-interaction point in the pipeline still ask one question at a time with recommend-then-confirm. The Scope Lock Challenge's four questions are a fixed, enumerable, non-branching set uniquely suited to batching (unlike open-ended coaching, whose next question depends on the prior answer); batching their drafting and presentation does not weaken confirmation into a blanket approval, because per-item accept/edit/reject remains individually gated and individually recorded. This is a narrow, named exception, not a framework-wide reversal.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Keep on-demand, per-question opt-in (status quo, 0000017-ADR-003) | Minimal exchange when a draft isn't wanted; preserves active per-question engagement | Adds up to 8 exchanges for 4 answers; no governance benefit since accept/edit/reject already gates approval regardless of drafting cadence | Human explicitly called it "a bug" (backlog 0000040); the offer step protects nothing the per-item confirmation doesn't already protect |
| Always draft, but still present one question at a time | Removes the opt-in friction while keeping a la carte per-question attention | Retains up to 4 sequential round trips; leaves the second stated friction (wanting a single batch review) unresolved | Backlog 0000040 explicitly requests batch presentation together with default-drafting; a partial fix leaves the friction the human named unresolved |
| Always draft all four in parallel and batch-present, with a single blanket accept for all four | Fastest possible flow — one exchange total | Directly violates scope-lock-agent's "no implicit confirmation" rule and 0000017-ADR-003's core governance property (approval must be per-item and explicit) | req-007 explicitly requires a separate affirmative per item; batching approval itself would erode scope integrity, not just drafting cadence |
| Default-drafted, batch-presented, per-item explicit accept/edit/reject (chosen) | Eliminates both stated frictions (opt-in ask, sequential round-trips) while preserving the one governance property that actually matters — the human's explicit per-item decision | On partial dispatch failure, requires a defined fallback path for the failed item, adding one more branch to implement and test | Matches req-007's functional requirements and both backlog entries' explicit human direction exactly |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| `planifest-orchestrator` skill | Scope Lock Challenge section rewritten: removes the per-question opt-in offer, adds default parallel dispatch of all four `planifest-scope-lock-agent` calls, batch presentation, per-item confirmation/build-log capture unchanged, and the new partial-failure fallback path |
| `planifest-scope-lock-agent` skill | Description/Invocation Contract updated to reflect default, parallel, per-question dispatch (trigger and cardinality only) — drafting rules and output format untouched |

---

## Consequences

**Positive:**
- Eliminates up to eight sequential exchanges (offer, then possible request, times four) down to one dispatch batch plus one review pass — directly resolving the friction the human called "a bug" in backlog 0000040 and the redundant round-trips flagged in backlog 0000029.
- Scope Lock's per-item governance discipline — fresh-context subagent per question, usage-only framing, consistency-check flagging, explicit accept/edit/reject, immediate build-log write — is fully preserved; only drafting trigger and presentation cadence change, not the confirmation mechanism itself.

**Negative:**
- Four parallel subagent dispatches now happen on every Scope Lock Challenge run unconditionally, even for items where the human would have declined a draft under the old opt-in flow — a real, if small, increase in agent/token spend versus the zero-dispatches-unless-requested baseline.
- The new partial-failure fallback (three successful drafts plus a failure marker for the fourth, reverting only that item to the blank-question opt-in flow) is a more complex failure mode to implement and test correctly than the uniform single-question flow it replaces.

**Risks:**
- If the single batch-review turn is ever misread — by the human or by a future implementer — as inviting one blanket approval across all four items, the "no implicit confirmation" rule could silently erode; mitigated by req-007's explicit acceptance criterion and by `planifest-scope-lock-agent/SKILL.md` rule 5 remaining unchanged and fully authoritative.
- Without this ADR's explicit boundary, a future reader could misread the reversal as license to batch other one-question-at-a-time flows (coaching Q&A, phase gates); the Decision section above forecloses that reading by name.

---

## Related ADRs

- 0000017-ADR-003 (Scope Lock Suggested Answers via On-Demand Subagent) - conflicts-with (this decision reverses its never-pre-draft, offer-then-opt-in default for the Scope Lock Challenge specifically; see Supersedes below)
- 0000014-ADR-008 (One-Question-at-a-Time as Framework-Wide Instruction) - related-to (this ADR carves a narrow, explicitly bounded exception for the Scope Lock Challenge's four scenario-path questions only; ADR-008's convention remains in force everywhere else in the framework)
- 0000014-ADR-007 (Derived Scope Lock Scenarios over Fixed Checklist) - related-to (unaffected — this ADR changes only the drafting/presentation cadence of the four scenario questions, not how they are derived)

---

## Supersedes

- 0000017-ADR-003 - Scope Lock Suggested Answers via On-Demand Subagent (superseded for the Scope Lock Challenge specifically; see `docs/decisions-index.md` for the cross-feature status update)

## Superseded By

- None

---

*Generated by adr-agent.*
