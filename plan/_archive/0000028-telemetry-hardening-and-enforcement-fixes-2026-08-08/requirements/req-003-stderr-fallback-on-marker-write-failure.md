---
title: "Requirement: req-003 - stderr fallback on marker write failure"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-003 - stderr fallback on marker write failure

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000028-telemetry-hardening-and-enforcement-fixes
**Source:** US-003
**Priority:** must-have

## User Story

As a framework maintainer, I want a failing marker write to leave a trace on stderr, so that a genuinely-down backend never produces zero signal.

## Functional Requirements
- `recordTelemetryFailure()` in `planifest-framework/hooks/telemetry/context-pressure.mjs` wraps its own marker write (`mkdirSync` / `writeFileSync` / `renameSync`) in a try/catch that currently swallows every error silently. That inner catch must emit exactly one line to stderr identifying the hook name and marker path before returning.
- The stderr line must not include credential values (API keys, tokens, secrets, passwords) in any field it constructs.
- The stderr line may echo the user-configured backend URL and the underlying error message verbatim. This matches the existing design decision that `plan/.telemetry-failures/` markers themselves may echo these strings verbatim and are gitignored for that reason (`.gitignore` line 27; see `context-pressure.mjs` header comment and `plan/current/design.md`'s Security line).
- All other behaviour of `recordTelemetryFailure()` is unchanged: the function still never throws (its outer try/catch keeps the hook's exit-0 guarantee), and the normal path, where the marker write succeeds, emits nothing extra to stderr.
- If `recordTelemetryFailure()` is later extracted into a shared module under REQ-002, this stderr fallback moves with it rather than being left behind in `context-pressure.mjs` alone.

## Acceptance Criteria
- [ ] When the marker write inside `recordTelemetryFailure()` fails, exactly one line is written to stderr.
- [ ] The hook still exits with code 0 after a marker-write failure, same as before this change.
- [ ] When the marker write succeeds (the normal path), stderr emits nothing extra beyond current behaviour, no line is added for a successful write.
- [ ] The stderr line does not contain credential values in any field it constructs.
- [ ] The stderr line may contain the user-configured backend URL and the raw error message verbatim; this is accepted, not a defect, matching the reasoning already applied to gitignoring `plan/.telemetry-failures/`.

## Dependencies
- REQ-002 (shared emit-and-record module extraction): if `recordTelemetryFailure()` moves to a shared module before this lands, the stderr fallback must be added to the shared version.
- `plan/.telemetry-failures/` gitignore entry (`.gitignore` line 27, already present): establishes the precedent this stderr behaviour follows and is otherwise unaffected by this requirement.
