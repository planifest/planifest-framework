---
title: "Execution Plan - 0000014-improve-adoption-mode-selection"
---
# Execution Plan - 0000014-improve-adoption-mode-selection

## Summary

Framework-level improvements to Phase 0 of the Planifest orchestrator: adoption mode selection, version suggestion, scope lock challenge, structured audit trail, and a framework-wide one-question-at-a-time instruction. Supporting changes to templates, ship-agent, docs-agent, and a migration for existing archives.

No runtime code. No API. No database. All changes are to markdown skill files and templates.

## Non-Functional Requirements

| Concern | Target |
|---------|--------|
| Latency | Not applicable — skill file authoring |
| Availability | Not applicable |
| Scalability | Not applicable |
| Security | No credentials, no PII, no regulated data |
| Data privacy | None |
| Observability | P0 audit trail written to build log (REQ-011); P8 reads it |
| Cost | Not constrained |

## Component Summary

| Component | Change type | Requirements |
|-----------|-------------|--------------|
| `planifest-orchestrator` skill | Modify | REQ-001, REQ-002, REQ-003, REQ-005, REQ-006, REQ-009, REQ-010, REQ-011, REQ-012 |
| `planifest-ship-agent` skill | Modify | REQ-004, REQ-012, REQ-013 |
| `planifest-docs-agent` skill | Modify | REQ-012, REQ-015, REQ-016 |
| `planifest-spec-agent` skill | Modify | REQ-012 |
| `planifest-adr-agent` skill | Modify | REQ-012 |
| `planifest-codegen-agent` skill | Modify | REQ-012 |
| `planifest-validate-agent` skill | Modify | REQ-012 |
| `planifest-security-agent` skill | Modify | REQ-012 |
| `planifest-change-agent` skill | Modify | REQ-012 |
| `design.template.md` | Modify | REQ-007 |
| `about.template.md` | Create | REQ-004 |
| `feature-brief.template.md` | Modify | REQ-017 |
| Migration file | Create | REQ-008, REQ-014 |

## Implementation Order

1. REQ-007 (template bug fix) — unblocks correct design.md output for all subsequent work
2. REQ-004 + REQ-013 (about.template.md + ship-agent write) — foundational for version protocol
3. REQ-001 + REQ-002 + REQ-005 + REQ-009 (mode detection + selection step + External Anchor + hardening) — core P0 flow
4. REQ-003 + REQ-006 (version suggestion + conflict warnings) — depends on mode detection
5. REQ-010 + REQ-011 (Scope Lock Challenge + audit trail) — depends on P0 flow being defined
6. REQ-012 (one-question rule — all 9 skills) — can run in parallel with 3–5
7. REQ-015 + REQ-016 (P6 gate A + B) — docs-agent changes, independent of orchestrator
8. REQ-017 (Feature Brief template) — independent
9. REQ-008 + REQ-014 (migration + progress file) — last, depends on all above being defined

## API Summary

None — no API surface.

## Data Summary

| Artifact | Owner | Read by | Written by |
|----------|-------|---------|-----------|
| `docs/about.md` | Pipeline (orchestrator + ship-agent) | Orchestrator at P0 | Ship-agent at P7 |
| `planifest-framework/migrations/_progress/*.json` | Migration | Migrator on resume | Migrator after each archive |
| Build log P0 coaching section | Orchestrator | P8 build-assessment-agent | Orchestrator incrementally during P0 |
