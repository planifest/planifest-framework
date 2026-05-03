---
title: "Execution Plan - framework-governance"
status: "draft"
version: "0.1.0"
---
# Execution Plan - 0000005-framework-governance

**Feature:** 0000005-framework-governance
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Version:** 0.1.0
**Status:** draft

---

## Functional Requirements Directory

See `plan/current/requirements/` for individual feature requirements.

| File | Feature |
|------|---------|
| req-001-library-standards-doc.md | library-standards directory structure |
| req-002-database-standards.md | database paradigm coverage |
| req-003-test-framework-coverage.md | per-language test framework standards |
| req-004-codegen-agent-wiring.md | codegen-agent library checks |
| req-005-validate-agent-wiring.md | validate-agent library audit |
| req-006-orchestrator-wiring.md | orchestrator stack coaching |
| req-007-orchestrator-sentinel.md | sentinel write gate enforcement |
| req-008-check-design-inject.md | check-design hard STOP |
| req-009-copilot-adapter.md | GitHub Copilot hook adapter |
| req-010-capability-skill-intake.md | skills-inbox intake system |
| req-011-skill-registries.md | plan-scoped and permanent registries |
| req-012-skill-manifest-in-design.md | Active Skills section in design.md |
| req-013-formatting-standards.md | date format, locale, response verbosity |
| req-014-migration-infrastructure.md | migrations directory and migrator skill |
| req-015-british-english-rewrite.md | planifest-framework prose rewrite + migration |
| req-016-planifest-overrides.md | planifest-overrides directory + instructions system |

---

## Non-Functional Requirements

| ID | Category | Requirement | Target | Measurement |
|----|----------|------------|--------|-------------|
| NFR-001 | Performance | gate-write sentinel existsSync overhead | < 5ms added per Write/Edit call | manual timing against baseline |
| NFR-002 | Reliability | existing regression suite must continue to pass | 17/17 tests green | CI run post-implementation |
| NFR-003 | Correctness | sentinel check must never block plan/current/feature-brief.md writes | zero false positives | regression test covering this path |
| NFR-004 | Correctness | sentinel check must never block plan/ or docs/ writes outside plan/current/ | zero false positives | regression test |

---

## API Summary

n/a — no API produced by this feature.

---

## Data Model Summary

No database schema. File-based state only:

| Artefact | Owner | Consumers |
|----------|-------|-----------|
| plan/.orchestrator-active | orchestrator (writes) | gate-write (reads) |
| planifest-overrides/capability-skills/ | human (writes) | setup (scans to generate external-skills.json) |
| planifest-overrides/instructions/ | human (writes) | orchestrator (reads at P0, writes to design.md §Repo Instructions) |
| planifest-framework/external-skills.json | setup (generates from planifest-overrides/capability-skills/) | orchestrator, all phase agents (read) |
| plan/current/external-skills.json | orchestrator (writes) | all phase agents (read); ship-agent (archives) |
| planifest-framework/migrations/*.md | human (drops) | orchestrator (reads); migrator (executes + archives) |

---

## Component Interactions

```
orchestrator ──writes──► plan/.orchestrator-active
gate-write.mjs ──reads──► plan/.orchestrator-active
check-design.mjs ──reads──► plan/current/feature-brief.md
orchestrator ──scans──► planifest-framework/skills-inbox/
orchestrator ──writes──► plan/current/design.md §Active Skills
codegen-agent ──reads──► library-standards-custom/ → library-standards/
validate-agent ──reads──► library-standards/
orchestrator ──scans──► planifest-framework/migrations/
orchestrator ──invokes──► planifest-migrator skill
ship-agent ──deletes──► plan/.orchestrator-active
setup.ps1/sh ──scans──► capability-skills/ → writes external-skills.json
```

---

## Assumptions

| ID | Assumption | Impact if Wrong |
|----|-----------|----------------|
| A-001 | Node.js fs.existsSync is available in the hook runtime (consistent with existing gate-write.mjs) | sentinel check fails silently; enforcement not applied |
| A-002 | Copilot Agent Hooks (Preview 2025) accept the same PreToolUse/UserPromptSubmit event model as Claude Code | copilot adapter requires redesign |
| A-003 | American→British English spelling corrections in prose do not affect any code identifier or machine-readable field | unintended identifier renames break tests |

---

## Open Questions

None — all material gaps resolved during P0.
