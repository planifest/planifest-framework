---
title: "Requirement: REQ-008 - orchestrator-presence-check"
status: "active"
version: "0.1.0"
---
# Requirement: REQ-008 - orchestrator-presence-check

**Feature:** 0000009-framework-rail-tightening
**Source:** Human-identified gap — orchestrator skill lost after context compaction; pipeline continued without enforcement
**Priority:** must-have

---

## Problem

`auto-trigger-orchestrator.mjs` fires only when `plan/.orchestrator-active` is **absent**. Once a pipeline is active the sentinel exists and the hook goes silent. After context compaction the skill context is lost, but the sentinel still exists — so no hook fires to alert the model or the human. The session continues off-rails.

## Functional Requirements

- A `UserPromptSubmit` hook `check-orchestrator-presence.mjs` is installed alongside the existing `auto-trigger-orchestrator.mjs`
- The hook fires on every user prompt when `plan/.orchestrator-active` **exists** (pipeline active)
- It reads the feature-id from `plan/.orchestrator-active` and injects a presence-check banner into the model's context before the prompt is processed
- The banner instructs the model to verify the orchestrator skill is loaded and reload it if not
- The banner includes the active feature-id so the model can confirm it is working on the correct pipeline
- The hook exits 0 in all cases — it never blocks a prompt
- When `plan/.orchestrator-active` is absent (no active pipeline) the hook exits 0 silently

## Strict Mode (--strict-orchestrator)

When `plan/.orchestrator-strict` exists (written by `setup.sh --strict-orchestrator` / `setup.ps1 -StrictOrchestrator`):

- On every prompt where `plan/.orchestrator-active` exists and no valid session ack is present, the hook injects a hard-block banner instructing the model not to process the user's request and instead load the orchestrator skill immediately
- The banner includes the Claude Code `session_id` from hook stdin, instructing the model to write it to `plan/.orchestrator-ack`
- Once the orchestrator skill is loaded (resume detection runs), it writes the session_id to `plan/.orchestrator-ack`
- On subsequent prompts in the same session, the hook reads `plan/.orchestrator-ack`, compares to the current `session_id`, and exits 0 silently — no further banners
- `plan/.orchestrator-ack` is deleted at P7 ship (end of pipeline) so the next pipeline always starts clean

In advisory mode (default, no `plan/.orchestrator-strict`): current behaviour — one-line banner, exit 0.

## Acceptance Criteria

- [x] `planifest-framework/hooks/enforcement/check-orchestrator-presence.mjs` exists
- [x] Advisory mode: hook injects one-line banner with feature-id; exits 0; fires every prompt when `plan/.orchestrator-active` present
- [x] Advisory mode: exits 0 silently when `plan/.orchestrator-active` absent
- [x] Strict mode: when `plan/.orchestrator-strict` exists and no valid ack, hook injects hard-block banner including `session_id`; instructs model to load skill and write ack; exits 0
- [x] Strict mode: once `plan/.orchestrator-ack` contains matching `session_id`, hook exits 0 silently
- [x] `setup.sh --strict-orchestrator` writes `plan/.orchestrator-strict`
- [x] `setup.ps1 --strict-orchestrator` writes `plan/.orchestrator-strict`
- [x] `setup.sh` and `setup.ps1` register `check-orchestrator-presence.mjs` as a `UserPromptSubmit` hook (idempotent)
- [x] Orchestrator SKILL.md Phase 0 Start Actions writes session_id to `plan/.orchestrator-ack` when strict mode is active
- [x] P7 ship agent deletes `plan/.orchestrator-ack` after archiving

## Dependencies

- REQ-002 (auto-trigger-orchestrator — this hook complements it, does not replace it)
- `plan/.orchestrator-active` sentinel file convention (established in Phase 0)
