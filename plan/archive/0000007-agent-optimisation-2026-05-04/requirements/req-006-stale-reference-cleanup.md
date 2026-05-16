---
title: "Requirement: req-006 - stale-reference-cleanup"
status: "active"
version: "0.1.0"
---
# Requirement: req-006 — Stale reference cleanup across skill files

**Feature:** 0000007-agent-optimisation
**Source:** Confirmed optimisation items req-006, req-007, req-008, req-011, req-012, req-013, req-015, req-016, req-017 from live optimise-agent review
**Priority:** must-have

---

## Functional Requirements

### Fix pipeline-run.md → build-log.md references

- `planifest-validate-agent/SKILL.md` Rules: "this goes into `pipeline-run.md`" → "this goes into `plan/current/build-log.md`"
- `planifest-orchestrator/SKILL.md` Mid-Pipeline Requirement Changes step 3: "Add a 'Requirement Change' entry to `pipeline-run.md`" → "Add a 'Requirement Change' entry to `plan/current/build-log.md`"

### Fix design-requirements.md → design.md references

- `planifest-security-agent/SKILL.md` Input: `plan/current/design-requirements.md` → `plan/current/design.md`
- `planifest-adr-agent/SKILL.md` Input: `plan/current/design-requirements.md` → `plan/current/design.md`

### Remove external-skills.json references (design req-006)

- `planifest-ship-agent/SKILL.md`: remove entire Step 6 ("Remove plan-scoped external skills — REQ-025")
- `planifest-orchestrator/SKILL.md` Capability Skill Intake step 4: remove JSON file update lines; replace with direct directory moves only:
  - `plan` → move to `plan/current/capability-skills/{name}/`
  - `permanent` → move to `planifest-overrides/capability-skills/{name}/`
- `planifest-orchestrator/SKILL.md` Skill Discovery: remove the line `Check planifest-framework/external-skills.json (if it exists) for already-installed skills`

### Replace skill-sync.sh references (design req-008)

- `planifest-orchestrator/SKILL.md` Skill Discovery: replace `Call skill-sync.sh add {skill-name} {tool}` with: "Copy the skill directory to `planifest-overrides/capability-skills/{name}/` (permanent) or `plan/current/capability-skills/{name}/` (plan-scoped). Re-run `setup.sh` / `setup.ps1` to register permanent installs with your tool."

### Remove Templates list from orchestrator References (design req-007)

- `planifest-orchestrator/SKILL.md` `## References`: remove the `**Templates**` bulleted subsection entirely. Keep `**Core Principles**` and `**Phase skills**` subsections.

### Remove ADR internal labels from codegen-agent (design req-011)

- `planifest-codegen-agent/SKILL.md`: `**TDD Inner Loop Protocol (ADR-001):**` → `**TDD Inner Loop Protocol:**`
- `planifest-codegen-agent/SKILL.md`: `**Sub-agent model tier (ADR-002):**` → `**Sub-agent model tier:**`

### Remove generic context-mode block from spec-agent (design req-015)

- `planifest-spec-agent/SKILL.md` Retrofit Mode: remove the blockquote starting `> **Context-Mode Protocol:** When ctx_batch_execute is available, use it for codebase discovery…`

### Remove redundant standards list from validate-agent (design req-016)

- `planifest-validate-agent/SKILL.md` `## Standards References`: remove the bulleted links list ([Code Quality Standards], [Testing Standards], [API Design Standards], [Database Standards]). Keep the paragraph: "Do not refactor code to meet standards during validation — only fix actual failures…"

## Acceptance Criteria

- [ ] `plan/current/build-log.md` is the referenced path in validate-agent and orchestrator (not `pipeline-run.md`)
- [ ] `plan/current/design.md` is the referenced path in security-agent and adr-agent inputs (not `design-requirements.md`)
- [ ] ship-agent has no Step 6
- [ ] Orchestrator Capability Skill Intake step 4 contains no reference to external-skills.json
- [ ] Orchestrator Skill Discovery contains no reference to external-skills.json or skill-sync.sh
- [ ] Orchestrator References has no Templates subsection
- [ ] Codegen-agent TDD and sub-agent model tier headings have no ADR labels in parentheses
- [ ] Spec-agent Retrofit Mode has no generic context-mode blockquote
- [ ] Validate-agent Standards References has no bulleted links list

## Dependencies

- None — all surgical edits to existing content
