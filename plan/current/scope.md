---
title: "Scope - 0000012-docs-restructure-commit-directives"
summary: "In / out / deferred scope boundaries for this feature."
status: "active"
version: "0.1.0"
---
# Scope - 0000012-docs-restructure-commit-directives

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000012-docs-restructure-commit-directives
**Version:** 0.1.0

> All three sections must be present.

---

## In Scope

- `planifest-framework/getting-started.md` — lean restructure to steps 1–5 (REQ-001, implemented)
- `planifest-framework/pipeline-reference.md` — expanded phase guidance; P9 addition; `plan/archive` → `plan/_archive` correction (REQ-002)
- `planifest-framework/project-operations.md` — new ops reference file (REQ-003, implemented)
- `planifest-framework/skills/planifest-orchestrator/SKILL.md` — commit directives at each gate (REQ-004, implemented); build log Hard Limit (REQ-005); run-mode sentinel protocol (REQ-006); P0–P9 phase table and naming (REQ-007); P0 pre-flight section (REQ-009)
- `planifest-framework/skills/planifest-ship-agent/SKILL.md` — restructure into P7 Archive / P8 sub-agent spawn / P9 Ship; P9 git tag, push decision, PR description (REQ-008)
- `planifest-framework/skills/planifest-build-assessment-agent/SKILL.md` — clarify sub-agent invocation (REQ-007)
- `planifest-framework/migrations/retroactive-release-tags.md` — new migration file (REQ-010)
- `planifest-framework/component.yml` — update responsibilities and version

---

## Out of Scope

- Changes to other phase skills: planifest-spec-agent, planifest-adr-agent, planifest-codegen-agent, planifest-validate-agent, planifest-security-agent, planifest-docs-agent
- Application source code under `src/`
- CI pipeline configuration (`.github/workflows/`)
- Database schema migrations
- Changes to `planifest-framework/setup.sh` or `planifest-framework/setup.ps1`
- Changes to hooks under `planifest-framework/hooks/`
- Pushing the retroactive git tags (human responsibility)
- Raising the PR (human responsibility per local-git-only constraint)

---

## Deferred

Nothing deferred.
