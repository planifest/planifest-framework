---
title: "Backlog Entry: 0000035 - Dispatched subagents should file discovered bugs to plan/backlog/, not the host tool's spawn_task"
summary: "Phase-agent subagents (codegen, spec, etc.) that discover an out-of-scope bug while implementing their assigned requirement currently have no instruction on how to flag it, and default to a host-tool-level mechanism (e.g. spawn_task) that creates a standalone session outside the Planifest pipeline, bypassing the backlog's own P0 pickup protocol. They should be instructed to write a plan/backlog/ entry directly instead."
status: "open"
---
# Backlog Entry: 0000035 - Dispatched subagents should file discovered bugs to plan/backlog/, not the host tool's spawn_task

**Source feature:** 0000023-framework-pipeline-fixes
**Source phase:** P8 (Build Assessment), raised by the human on the loop after observing the behavior live
**Date filed:** 2026-08-02

---

## Problem

During this feature's P3 (Codegen), the subagent implementing req-003 (copilot self-copy fix) discovered an unrelated, out-of-scope bug in `setup/cline.sh` (a boot-file/skills-dir path collision, unmasked by the req-003 fix). It correctly recognized the bug was out of scope and didn't try to fix it inline — but instead of writing a `plan/backlog/` entry (this framework's own convention for exactly this situation, per `templates/backlog-entry.template.md` and the orchestrator's P0 backlog-pickup protocol), it used the host tool's `spawn_task` mechanism, which created a standalone suggested-task chip surfaced directly to the human, entirely outside the Planifest pipeline.

This meant the human had to notice the chip, decide what to do with it, and the orchestrator then had to manually convert it into a proper backlog entry (`0000034`) and dismiss the chip — extra round-trip work that a direct backlog write would have skipped entirely. No dispatched subagent in this run (or, as far as this feature's own investigation went, in the codegen-agent/spec-agent/validate-agent/security-agent skill files generally) is ever told that `plan/backlog/` is the correct place to record an out-of-scope discovery, or given the template to do it with. The skills' own text (e.g. `planifest-codegen-agent/SKILL.md`'s "Deviation & Escalation Protocol") covers what to do about in-scope blockers (document the deviation or escalate) but says nothing about out-of-scope discoveries — the gap this bug fell into.

## Suggested Action

Add explicit instruction — likely in the orchestrator's Agent Dispatch Template (self-contained prompt rule) and/or each phase skill's own dispatch guidance (`planifest-codegen-agent`, `planifest-spec-agent`, `planifest-validate-agent`, `planifest-security-agent`, `planifest-docs-agent`) — that a dispatched subagent discovering an out-of-scope bug or gap should write a `plan/backlog/{id}-{slug}/entry.md` directly, following `templates/backlog-entry.template.md`, rather than reaching for a host-tool-level mechanism like `spawn_task`. This requires the subagent to know the next available backlog ID at dispatch time (per the existing "own monotonic sequence" convention) — the dispatching orchestrator/phase-agent could pre-compute and pass it in the dispatch prompt, or the subagent could be told to check `plan/backlog/` itself and pick the next ID, accepting a small collision risk under parallel dispatch that a human reviews at the next P0 pickup anyway.

## Why Deferred

Filed live during this feature's own P7-P9 close-out, at the human's request, after observing the exact failure mode play out mid-run. Needs its own scoping pass (where exactly the instruction belongs — orchestrator-level dispatch template vs. per-skill — and how to handle the backlog-ID-at-dispatch-time question) before implementation; out of scope to bolt onto 0000023, which is already mid-ship.
