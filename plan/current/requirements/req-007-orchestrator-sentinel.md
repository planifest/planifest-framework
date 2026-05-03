---
title: "Requirement: REQ-007 - orchestrator-sentinel"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-007 - orchestrator-sentinel

**Feature:** 0000005-framework-governance
**Source:** orchestrator sentinel user stories (feature-brief.md)
**Priority:** must-have

---

## Functional Requirements

- planifest-orchestrator SKILL.md must write `plan/.orchestrator-active` at Phase 0 start; file content must be the feature-id of the current pipeline run
- `planifest-framework/hooks/enforcement/gate-write.mjs` must be extended: when the target path matches `plan/current/**` (any file or subdirectory), check for the existence of `plan/.orchestrator-active`; if absent, exit 2 with human-readable message directing the human to load the orchestrator
- `plan/current/feature-brief.md` must be explicitly excluded from the sentinel check — it must always be writable so P0 can begin
- The sentinel check must also exclude `plan/` paths outside `plan/current/` (e.g. `plan/.orchestrator-active` itself, `plan/changelog/`)
- planifest-ship-agent SKILL.md must delete `plan/.orchestrator-active` as the final step of P7 archive, before closing the pipeline run
- If `plan/.orchestrator-active` contains a feature-id that does not match the active pipeline run, gate-write must surface a warning and block — stale sentinel from a previous run

## Acceptance Criteria

- [ ] Orchestrator writes `plan/.orchestrator-active` containing feature-id at P0 start
- [ ] gate-write blocks `plan/current/**` writes when sentinel is absent (exit 2)
- [ ] gate-write allows `plan/current/feature-brief.md` writes regardless of sentinel
- [ ] gate-write allows writes to `plan/` paths outside `plan/current/`
- [ ] ship-agent deletes `plan/.orchestrator-active` at P7
- [ ] Regression test covers all sentinel enforcement paths

## Dependencies

- REQ-008 (check-design inject) — complementary enforcement layer
