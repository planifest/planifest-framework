---
title: "Backlog Entry: 0000047 - Pre-P0 discussion (backlog triage, item targeting, migration handling) is lost at the mandatory context reset"
summary: "Substantive discussion routinely happens before Phase 0 Start Actions writes build-log.md/discovery.md: backlog listing, which items to target, pending-migration handling. The orchestrator's Context Hygiene bookend fires a /clear before any of it is persisted, so it is silently discarded and the human on the loop has to manually re-paste it to recover."
status: "open"
---
# Backlog Entry: 0000047 - Pre-P0 discussion (backlog triage, item targeting, migration handling) is lost at the mandatory context reset

**Source feature:** none, discovered during this session's own pre-P0 flow, before a feature ID existed
**Source phase:** P0 (Context Hygiene step -1, before Phase 0 Start Actions)
**Deferral source:** discovered mid-flight
**Date filed:** 2026-08-08

---

## Problem

In practice, real conversation happens before the orchestrator's Phase 0 Start Actions step -1 (context reset) ever runs. The human on the loop asks "what's in our backlog," the assistant runs several commands to list and summarise open backlog entries, the human names which items to target, and sometimes a pending-migration check runs and resolves inline. None of this is written to `plan/current/build-log.md` (which step -1 requires be created, but only *after* the reset) or `plan/current/discovery.md` (both created later, inside Phase 0 Start Actions steps 1-2 and 3d). When step -1 then fires the mandatory `/clear`-or-flag, that entire pre-coaching exchange is discarded with nothing durable capturing it.

Concretely, this session's actual pre-reset transcript (target items already chosen, migration already resolved) was entirely lost at the reset and had to be manually re-pasted by the human on the loop to recover it:

> ```
> prepare next feature release. what's in our backlog?
> Ran 5 commands
> 14 open backlog items, all status `open`, no priority field or index — grouped by theme below.
> Framework self-review findings (filed 2026-07-31, ad-hoc chat review, all independent):
> * `0000020` — orchestrator skill is 12,204 words (39% of skills corpus), loaded in full up front
> * `0000021` — feature-pipeline mandates cost model/SLOs/ops model for every feature regardless of size
> * `0000022` — add token accounting per phase alongside existing duration_ms
> * `0000023` — no comparative evidence vs. no-framework/fast-path/full-pipeline exists
> * `0000024` — record an ADR for the "does this skill earn its place" test
> * `0000025` — README doesn't state audience or stability/versioning commitment
> * `0000026` — no guard against AI writing tells (em dashes etc.) in generated artifacts
> Discovered during pipeline runs:
> * `0000034` — cline.sh boot-file/skills-dir path collision aborts setup.sh
> * `0000035` — subagents should file discovered bugs to the backlog, not host-tool spawn_task
> * `0000042` — context-mode hook false-flags local http:// URLs in command args
> * `0000043` — phase_start/phase_end telemetry hooks never actually wired in setup
> * `0000044` — orchestrator misses telemetry failure markers, skips agent-driven emit_event calls
> * `0000045` — backfill pre-0000025 recommendations.md deferred items into the backlog
> * `0000046` — need explicit P0 handling for planifest-framework/ dependency updates vs. arbitrary code
> No priority/severity ranking exists in these entries as filed. To "prepare next feature release," the normal flow is Phase 0 (Assess and Coach) triage — pick which backlog item(s) become the next feature, per planifest-orchestrator. Want me to load the orchestrator and start P0 triage on this list, or do you already have a specific item (or subset) in mind?
>
> target 0000043, 0000034, 0000035, 0000044, 0000045, 0000046, 0000024, 0000021
> Ran a command, used a tool
> A pending migration exists (migrate-product-yml-component-paths.md) that hasn't been applied yet. Per the orchestrator's Resume Detection protocol, migrations take priority over all other phase work — I need to run this first.
> Read migrate-product-yml-component-paths.md, ran a command, used a tool
> All three components[] entries already use path (not version) — this migration was already applied.
> Ran 3 commands
> Migration migrate-product-yml-component-paths.md complete.
> product.yml already uses {id, path} for every components[] entry (no version keys present) — already migrated, 0 corrections needed. Archived to planifest-framework/migrations/_done/ and committed.
> Sanity check per the migration's instructions:
> Ran product-version.mjs sanity check
> Sanity check passes (0.26.1, exit 0). No pending migrations remain.
> Returning to the orchestrator to begin Phase 0 for the targeted backlog items (0000043, 0000034, 0000035, 0000044, 0000045, 0000046, 0000024, 0000021).
> ```

At the point `/clear` was requested, none of the following had been written anywhere durable: which backlog items the human on the loop had already selected (0000043, 0000034, 0000035, 0000044, 0000045, 0000046, 0000024, 0000021), the fact a migration had already been checked and found already-applied, or the reasoning trail behind either. A fresh session after the reset has no way to recover this except the human on the loop manually re-pasting the transcript. That defeats the point of the reset being hygienic rather than lossy.

## Suggested Action

Before, or as part of, issuing the step -1 context-reset flag, persist whatever pre-P0 state already exists to a durable artifact that survives the reset and is read back in during Phase 0 Start Actions. Candidate approaches to evaluate at pickup:

(a) Allow `build-log.md` to be created earlier, at the first pre-coaching exchange rather than gated behind step 1, so a "P0 pre-flight" block can capture backlog items discussed and targeted plus any migration handling before the reset fires.

(b) A lightweight `plan/current/.pre-p0-notes.md` scratch file written just before the `/clear` flag, read and folded into `discovery.md`/`build-log.md` once Phase 0 Start Actions actually runs, then deleted.

(c) Reorder Context Hygiene step -1 to run strictly before any backlog or migration discussion happens, that is, at the very first prompt of a session, before even a "what's in the backlog" question is answered, so there is never substantive pre-reset discussion to lose in the first place.

Option (c) is cheapest but changes today's actual usage pattern, since humans naturally ask "what's in the backlog" before formally starting P0. Options (a) and (b) preserve that pattern while making it durable.

## Why Deferred

Out of scope for the batch of items this session is targeting (0000043, 0000034, 0000035, 0000044, 0000045, 0000046, 0000024, 0000021). This is a new, separate framework governance gap in the orchestrator's own Context Hygiene protocol, discovered live during this session's pre-P0 flow, not a fix to any of the already-targeted items.
