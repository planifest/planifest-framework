# Scope — 0000010-framework-quality-improvements

**Date:** 12 May 2026

---

## In Scope

- Adding `## Input Validation` section to `planifest-framework/templates/requirement.template.md` (REQ-001)
- Adding `"Agent"` to `allowedTools` via `setup.sh` and `setup.ps1` for Claude Code target (REQ-002)
- Adding Agent dispatch template and parallelism directives to `planifest-orchestrator/SKILL.md`, `planifest-codegen-agent/SKILL.md`, `planifest-validate-agent/SKILL.md` (REQ-002)
- Audit and normalisation of all existing skill directory names under `planifest-framework/external-skills/` (REQ-003)
- Full extraction of skills from `_temp/sw-agent-skills`, `_temp/wondelai-skills`, `_temp/garden-skills`, `_temp/marketingskills` (REQ-004)
- Updating `planifest-framework/external-skills/README.md` (REQ-003 + REQ-004)
- Test coverage for REQ-001 and REQ-002 changes

---

## Out of Scope

- Exhausting large repos: `antigravity-awesome-skills`, `privacy-skills`, `useful-ai-prompts` (too large for human review without automated filter)
- Changes to phase skills other than orchestrator, codegen-agent, validate-agent
- Writing new original skills (no original work in this pipeline)
- Global Claude Code `allowedTools` changes (project-scoped settings only)
- End-to-end Agent tool invocation testing (requires a test pipeline; deferred)
- Changes to `src/setup-hook-integration/docs/` (out of scope per R-001 — separate feature)
- Modifying any plan/archive/ artifact from feature 0000009

---

## Deferred

- **Automated bulk skill filter (option C):** blocked until a quality-filter script exists — planned as feature 0000011
- **Agent tool end-to-end test:** blocked until a test harness for spawning and verifying Agent calls exists
- **`src/setup-hook-integration` component docs update:** deferred from 0000009 R-001; still pending, should be addressed in a dedicated Change Pipeline run against feature 0000003
