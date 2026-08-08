---
title: "Domain Glossary - backlog-batch-governance-tooling-fixes"
summary: "Definitions of domain terms used within this feature."
status: "active"
version: "0.1.0"
---
# Domain Glossary - backlog-batch-governance-tooling-fixes

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md) (updated by any agent that introduces a new domain term)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Version:** 0.27.0

## Terms

| Term | Definition | Aliases | Used In |
|------|-----------|---------|---------|
| Unified Telemetry Signal | The single `--structured-telemetry-mcp` install flag that gates all telemetry hook emission (context-pressure, phase_start, phase_end) together, per 0000018-ADR-001 | telemetry gate | planifest-framework, setup-hook-integration |
| Positive-Presence Check | A verification step that confirms a hook is actually registered in the target tool's config, not merely that the install flag was passed | wiring-presence check | setup-hook-integration |
| Telemetry Failure Marker | A durable file under `plan/.telemetry-failures/` recording a hook emission failure by root cause, per 0000018-ADR-002 | failure marker | planifest-framework |
| Deterministic Backstop | A mechanism (hook, gate check, or both) that enforces a rule structurally rather than relying on skill prose/agent memory alone, per 0000016-ADR-007's precedent | backstop | planifest-framework |
| Backlog Entry | A `plan/backlog/{id}-{slug}/entry.md` file recording an out-of-scope discovery or deferred item, per `templates/backlog-entry.template.md` | backlog item | planifest-framework |
| Backlog Pickup | The P0 step where the orchestrator presents each `plan/backlog/` entry to the human for pull-in / leave / discard | pickup protocol | planifest-framework |
| Framework Update Policy | The (currently undocumented, req-005 creates it) canonical mechanism governing how a downstream project's local `planifest-framework/` copy gets updated, distinct from an arbitrary code push | update policy | planifest-framework |
| Provenance (framework update) | The stated source of a framework-folder update — the upstream release, commit, or migration that produced the changed files | update source | planifest-framework |
| Skill-Scope Test | The governing question from req-007's ADR: does this skill provide governance or traceability the host tool cannot | "earns its place" test | planifest-framework |
| Minimal Artifact Set | The named, always-produced subset of Phase 1 artifacts (execution plan, requirements, scope, risk register, domain glossary) with every other artifact gated by an explicit, checkable trigger condition, per req-008 | default artifact set | planifest-framework |
