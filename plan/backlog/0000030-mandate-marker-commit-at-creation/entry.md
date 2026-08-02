---
title: "Backlog Entry: 0000030 - Mandate committing session markers at creation"
summary: "The orchestrator mandates the P0 commit only for plan/.run-mode; plan/.orchestrator-active and plan/.orchestrator-ack carry no commit instruction at creation, so a lost working tree can strand a run without its sentinel state. Companion to 0000028, which covers the deletion side."
status: "open"
---
# Backlog Entry: 0000030 - Mandate committing session markers at creation

**Source feature:** 0000022-orchestrator-redundancy-removal
**Source phase:** P0 (Scope Lock Challenge)
**Date filed:** 2026-08-02

---

## Problem

During 0000022's Scope Lock cross-session question, the scope-lock agent flagged that resume depends on three marker files, and the human on the loop confirmed they should always be committed. The orchestrator currently mandates this for only one of the three: `plan/.run-mode` carries "Include this file in the P0 commit" (Phase 0 Start Actions), but step 1 (write `plan/.orchestrator-active`) and step 5 (write `plan/.orchestrator-ack`) in `planifest-framework/skills/planifest-orchestrator/SKILL.md` contain no commit instruction. Hard Limit 7 (commit after every meaningful artifact write) arguably covers them, but nothing states it for the markers explicitly, and an agent that treats dotfile markers as ephemeral leaves resume state local-only. A lost working tree then recovers the trims and artifacts from the remote but not the sentinel or run mode. Backlog `0000028` records the mirror-image gap at the deletion end (markers not committed as deleted before the PR was raised).

## Suggested Action

Add an explicit commit instruction to Phase 0 Start Actions steps 1 and 5 (or fold all three markers into one "markers are committed when written, committed when deleted" rule shared with 0000028's fix), and consider a deterministic check (pre-push or CI) that marker state on the branch matches the pipeline state. Best picked up together with 0000028 as one marker-lifecycle fix.

## Why Deferred

Out of scope for 0000022 (redundancy removal with zero behavioural change); it is an enforcement-content addition, and it pairs naturally with 0000028.
