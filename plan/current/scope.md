# Scope - 0000011-setup-parity-and-consistency

**Feature:** 0000011-setup-parity-and-consistency
**Version:** 0.1.0
**Status:** active

---

## In Scope

### Setup parity (REQ-001 – REQ-006)
- `--include-full-skill-library` flag, `Copy-ExternalSkills` function, and `.planifest-manifest` tracking in `setup.ps1`
- `roo-code` added to `$ValidTools` (routes to deprecation handler per REQ-017)
- skill-sync dispatch after `Invoke-PlanifestSetup` in `setup.ps1`
- Removal of stale `req-005-open-source-skill-library.md` link in `external-skills/README.md`
- `test_setup.ps1` test block for `--include-full-skill-library`
- Two `grep_has` assertions added to `test-0000009-rail-tightening.sh` for setup.ps1

### Framework quality (REQ-007 – REQ-013)
- `## User Story` section added to `requirement.template.md`; spec-agent SKILL.md updated to enforce it
- Feature brief template updated to "As a / I / so that" format with one-story-per-req note
- Standalone skills routing section added to orchestrator SKILL.md
- Design template updated to store user story list, not count; orchestrator P0 gate updated
- Validate-agent SKILL.md updated for AC-level coverage checks with coverage table output
- Execution plan template: stale orchestrator link fixed; FR section expanded with naming convention
- docs-agent SKILL.md updated with living docs mandate; three new templates created

### Archive naming consistency (REQ-014)
- `planifest-orchestrator/SKILL.md`, `planifest-ship-agent/SKILL.md`, `planifest-build-assessment-agent/SKILL.md`: all `plan/archive/` references → `plan/_archive/`
- All templates: `plan/archive/` references → `plan/_archive/`
- Migration instruction doc `migrations/0003-archive-dirname.md` created
- Manual migration scripts `migrate-archive-dirname.sh` and `.ps1` created

### Hook parity (REQ-015 – REQ-019)
- GitHub Copilot: adapter and `.github/hooks/planifest.json` config
- Windsurf Cascade: adapter and `.windsurf/hooks.json` config
- Roo Code: deprecation warning handler replacing install logic
- Cursor: adapter and `.cursor/hooks.json` config
- Codex CLI: adapter and `.codex/hooks.json` config

---

## Out of Scope

- `setup.sh` — not modified except for dispatch additions to new tool hook setup scripts (copilot, cursor, codex, roo-code deprecation)
- New external skills added to `external-skills/`
- New flags in setup.sh that are not already present
- OpenCode — not a parity gap; handled by `opencode.ps1` config
- Antigravity — no hooks system available as of May 2026
- Full rewrite of any existing hook adapter — updates only
- Changes to ADR process, component manifest format, or any pipeline artifact not named in REQ-001–REQ-019
- UI or frontend changes

---

## Deferred

Nothing is deferred. All identified gaps are addressed within this feature.

If Antigravity releases a hook API before this feature ships, a change request should be raised via the Change Pipeline — not retrofitted into this feature mid-execution.
