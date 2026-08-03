---
title: "Requirement: req-007 - Scope Lock default drafted batch"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-007 - Scope Lock default drafted batch

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Source:** US-007
**Priority:** should-have

## User Story

> One requirement doc = one user story.

As a human on the loop, I want the Scope Lock Challenge to default to drafting all four scenario-path answers up front and presenting them in one batch, so that I do one accept/edit/reject pass instead of four sequential round-trips.

## Functional Requirements
- The Scope Lock Challenge MUST, by default, dispatch `planifest-scope-lock-agent` for all four scenario-path questions (happy path, first-run path, error/sad path, cross-session continuity) in parallel, before presenting any question to the human — replacing the current one-at-a-time sequencing where each question is asked and answered before the next is even posed.
- Drafting MUST no longer require a per-question human opt-in ("Want me to suggest an answer first? yes/no"). The draft is always produced; the human's role starts at review, not at requesting a draft.
- Each of the four parallel dispatches MUST remain a fresh-context subagent scoped to exactly one question, receiving the same inputs the current on-request dispatch receives (the scenario-path question, feature brief, requirements/ADRs confirmed so far, and latest confirmed decisions to check against, if any exist yet). Only the trigger (automatic vs. on-request) and batch cardinality (all four together vs. one at a time) change — the subagent's drafting rules, output format, and never-self-confirms behavior are unchanged.
- The orchestrator MUST present all four questions together with their labelled drafts in a single batch turn, not one question at a time waiting for an answer before drafting or showing the next.
- The human reviews the batch in one pass but still gives a separate, explicit accept / edit / reject for each of the four items individually — no blanket or implied confirmation across multiple items is ever read as approval for any of them.
- Each item's `plan/current/build-log.md` entry MUST be written immediately upon that item's own explicit confirmation, using the existing capture format and source labels (`agent-draft-accepted` / `agent-draft-edited` / `human`), not deferred until the whole batch is confirmed.
- If one of the four parallel dispatches fails, the orchestrator MUST present the three successful drafts plus a clear failure marker for the fourth, and fall back to the original blank-question, opt-in flow for that one item only — a single failed dispatch does not block or discard the rest of the batch (feature-brief.md sad path).
- This change is scoped to the Scope Lock Challenge only. It MUST NOT alter `0000014-ADR-008`'s one-question-at-a-time convention anywhere else in the framework (coaching Q&A, clarifying questions, other phase gates).
- `0000017-ADR-003`'s "never pre-draft automatically, offer-then-opt-in" behavior is reversed for the Scope Lock Challenge specifically. A new ADR superseding/amending ADR-003, and scoped narrowly against `0000014-ADR-008`, is required before this behavior can ship — authoring that ADR is P2's responsibility, not this requirement's (see Dependencies).

## Acceptance Criteria
- [ ] Scope Lock Challenge dispatches `planifest-scope-lock-agent` for all four scenario-path questions in parallel by default — no human opt-in step is required to trigger drafting.
- [ ] All four questions and their labelled drafts are presented to the human together in one batch, not sequentially one-at-a-time.
- [ ] The human completes one review pass but gives a separate explicit accept / edit / reject per item; no blanket or implied confirmation across items counts as approval for any of them.
- [ ] Each item's build-log entry is written immediately on that item's own confirmation (not deferred to the end of the batch), using the existing capture format and source labels.
- [ ] If one of the four parallel dispatches fails, the batch presents the three successful drafts and a clear failure marker for the fourth, falling back to the original blank-question opt-in flow for that item only.
- [ ] `planifest-orchestrator/SKILL.md`'s Scope Lock Challenge section documents that this default-drafted, batch-presented behavior is scoped to the Scope Lock Challenge only — the framework-wide one-question-at-a-time convention (`0000014-ADR-008`) is unchanged everywhere else in the framework.
- [ ] `planifest-scope-lock-agent`'s invocation contract (fresh-context per question, single-question scope, never self-confirms, never advances the sequence) is preserved unchanged — only the trigger and batch cardinality change.

## Dependencies
- P2 ADR: a new ADR superseding/amending `0000017-ADR-003` (never-pre-draft, offer-then-opt-in) is required to record the always-draft, batch-presented default for the Scope Lock Challenge before this requirement can be implemented (design.md Risks; feature-brief.md Acceptance Criteria). Not authored by this requirement — noted here as a hard dependency for P2.
- `0000014-ADR-008` (one-question-at-a-time as a framework-wide convention) — the new P2 ADR must scope the reversal narrowly against it so it doesn't read as a silent framework-wide reversal.
- `planifest-orchestrator/SKILL.md`'s Scope Lock Challenge section (current one-at-a-time, offer-then-opt-in protocol) and `planifest-scope-lock-agent/SKILL.md`'s description/Invocation Contract ("dispatched only on explicit human request... never for more than one item at a time") both require updating to reflect default, parallel, per-question dispatch.
- Merges backlog entries `plan/backlog/0000029-scope-lock-drafts-always-presented/entry.md` and `plan/backlog/0000040-scope-lock-default-to-drafted-answers/entry.md` — this requirement supersedes both; their folders are removed by the orchestrator during archive, not by this requirement.
