---
title: "Requirement: req-006 - telemetry-standards-update"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-006 - telemetry-standards-update

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000018-telemetry-emission-consistency
**Source:** US-001, US-002
**Priority:** should-have

---

## User Story

As a human running a Planifest pipeline with telemetry enabled, I see every event the phase skills specify actually emitted during the run, so that the collected data reflects real pipeline behavior, not whatever an agent happened to remember.

---

## Functional Requirements
- Update `planifest-framework/standards/telemetry-standards.md` to document: the unified telemetry-enabled signal (single condition — `--structured-telemetry-mcp` alone is sufficient, per req-001), the hook failure-marker mechanism and its lifecycle (per req-002), and the interactive block-or-proceed protocol including its "once per distinct root cause per run" scoping (per req-003)
- This document remains the single canonical reference all 8 phase skills point to (ADR-002, 0000007) — the rewritten Telemetry sections (req-004) reference it rather than re-describing the mechanism

## Acceptance Criteria
- [ ] `telemetry-standards.md` documents the unified signal condition accurately
- [ ] `telemetry-standards.md` documents the failure-marker mechanism and its lifecycle
- [ ] `telemetry-standards.md` documents the interactive block-or-proceed protocol and its per-run, per-root-cause scoping
- [ ] The document remains the sole canonical source other skills reference, not a duplicate of skill-level instructions

## Dependencies
- req-001, req-002, req-003 — documents the mechanisms those requirements define
