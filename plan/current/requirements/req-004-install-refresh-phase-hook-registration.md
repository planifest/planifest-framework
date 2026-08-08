---
title: "Requirement: req-004 - install refresh phase hook registration"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-004 - install refresh phase hook registration

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source:** US-004
**Priority:** must-have

## User Story

As a human on the loop, I want this repo's stale install refreshed so the phase telemetry hooks are registered, so that `phase_start` and `phase_end` are actually emitted.

## Functional Requirements
- Precondition, check first before any other step: confirm `--structured-telemetry-mcp` was passed for this install. `.claude/.planifest-setup-flags` currently records `flags: ["--context-mode-mcp","--structured-telemetry-mcp","--strict-orchestrator"]` with `backendUrl: "http://localhost:3741"`, which supports the assumption in `plan/current/design.md`. Re-confirm against that file (or equivalent evidence) at execution time rather than trusting this snapshot. If the precondition does not hold, stop and re-specify this requirement rather than proceeding, per `design.md`'s Assumptions section.
- This is not new wiring code. `planifest-framework/setup.sh` line 626, `merge_telemetry_hook_settings()`, already wires `resolve-phase.mjs start` to `PreToolUse` (Skill matcher), `resolve-phase.mjs end` to `Stop`, and `emit-event-receipt.mjs` to a `PostToolUse` matcher on `mcp__structured-telemetry-mcp__emit_event`. This shipped in feature 0000027. No change to `setup.sh` is in scope.
- The gap is that this repo's `.claude/settings.json` is stale local machine state (gitignored, `.gitignore` line 2): it currently registers only `context-pressure.mjs` on `PostToolUse` and is missing the three entries above.
- Refresh the install using the `planifest-refresh-setup` skill: reconstruct the flags currently in effect (from `.claude/.planifest-setup-flags` and installed hook wiring), confirm with the human on the loop, and re-invoke `setup.sh` with those flags.
- After refresh, confirm registration by reading the resulting `.claude/settings.json` directly, not by assuming the refresh succeeded.
- Add `plan/.telemetry-receipts/` to `.gitignore`, matching the existing `plan/.telemetry-failures/` entry (`.gitignore` line 27), since `emit-event-receipt.mjs` starts writing receipts once wired and they would otherwise appear as untracked files.

## Acceptance Criteria
- [ ] Precondition confirmed first: the flags in effect for this install include `--structured-telemetry-mcp`, verified via `.claude/.planifest-setup-flags` or equivalent, before setup is re-invoked.
- [ ] The `planifest-refresh-setup` skill is invoked to reconstruct the flags in effect and re-run `setup.sh` with them.
- [ ] After refresh, `.claude/settings.json`'s `PreToolUse` contains a Skill-matcher entry running `resolve-phase.mjs start ... emit-phase-start.mjs`.
- [ ] After refresh, `.claude/settings.json`'s `Stop` contains an entry running `resolve-phase.mjs end ... emit-phase-end.mjs`.
- [ ] After refresh, `.claude/settings.json`'s `PostToolUse` contains a `mcp__structured-telemetry-mcp__emit_event` matcher entry running `emit-event-receipt.mjs`, alongside the pre-existing `context-pressure.mjs` entry, which must remain present and unchanged.
- [ ] No new hook-wiring code is added anywhere; `setup.sh` is not modified by this requirement.
- [ ] `plan/.telemetry-receipts/` is added to `.gitignore`, matching the existing `plan/.telemetry-failures/` entry, before `emit-event-receipt.mjs` can produce untracked receipt files.
- [ ] If the `--structured-telemetry-mcp` precondition turns out false, this requirement is stopped and re-specified rather than proceeding.

## Dependencies
- `planifest-framework/setup.sh:626` `merge_telemetry_hook_settings()` (existing, shipped in feature 0000027): this requirement depends on it already existing and being correct; no changes to it are in scope.
- `planifest-refresh-setup` skill: the mechanism this requirement uses to reconstruct flags and re-invoke setup.
- REQ-005 (live verification of `resolve-phase.mjs`): depends on this requirement landing first, since `resolve-phase.mjs` cannot be observed firing until it is registered.
- `.claude/.planifest-setup-flags`: local marker used to reconstruct flags; if absent or stale, the precondition check needs another source of truth.
