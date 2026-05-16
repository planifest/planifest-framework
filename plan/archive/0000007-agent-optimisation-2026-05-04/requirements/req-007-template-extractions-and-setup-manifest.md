---
title: "Requirement: req-007 - template-extractions-and-setup-manifest"
status: "active"
version: "0.1.0"
---
# Requirement: req-007 — Template extractions and setup manifest

**Feature:** 0000007-agent-optimisation
**Source:** Confirmed optimisation items req-009, req-010, req-014 from live optimise-agent review
**Priority:** must-have

---

## Functional Requirements

### Extract inline design.md template (design req-010)

- Create `planifest-framework/templates/design.template.md` containing the confirmed design format — the full markdown template currently inline in `planifest-orchestrator/SKILL.md` under "What you produce at the end of Phase 0"
- Add a row to the orchestrator JIT Loading table: when about to write the confirmed design to `plan/current/design.md` → read `planifest-framework/templates/design.template.md` first
- Replace the inline template block in the orchestrator with: "Read `planifest-framework/templates/design.template.md` now."
- Add `design.template.md` to orchestrator `bundle_templates` frontmatter

### Replace inline iteration log template in docs-agent (design req-014)

- `planifest-docs-agent/SKILL.md` Audit trail section: remove the inline markdown template block (the fenced `# Iteration Log…` block)
- Replace with: "Read `planifest-framework/templates/iteration-log.template.md` now before producing the audit trail."
- `iteration-log.template.md` is already in docs-agent `bundle_templates` — no frontmatter change needed

### Setup manifest tracking (design req-009)

- `planifest-framework/setup.sh`:
  - After completing installation, write `{tool-install-dir}/.planifest-manifest` listing all directories installed in the current run (one path per line)
  - At the start of a re-run, read the manifest (if it exists) and remove only the listed directories before reinstalling
  - Never remove directories not listed in the manifest
  - If no manifest exists (first run), proceed as normal

- `planifest-framework/setup.ps1`: same logic as setup.sh, adapted for PowerShell

## Acceptance Criteria

- [ ] `planifest-framework/templates/design.template.md` exists containing the full confirmed design format
- [ ] Orchestrator JIT Loading table has a row for `design.template.md`
- [ ] Orchestrator inline design template block is replaced by a single read instruction
- [ ] `design.template.md` is listed in orchestrator `bundle_templates` frontmatter
- [ ] Docs-agent Audit trail section contains no inline markdown template block
- [ ] Docs-agent Audit trail section instructs reading `iteration-log.template.md`
- [ ] `setup.sh` writes `.planifest-manifest` after install
- [ ] `setup.sh` re-run removes only manifest-listed directories
- [ ] `setup.ps1` same behaviour as setup.sh

## Dependencies

- None — extractions and setup script changes are independent
