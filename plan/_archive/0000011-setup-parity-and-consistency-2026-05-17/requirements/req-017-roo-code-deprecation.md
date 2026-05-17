---
title: "Requirement: REQ-017 - Remove or deprecate Roo Code support (extension shut down May 15, 2026)"
summary: "Roo Code shut down on May 15, 2026. The VS Code extension is archived and no longer installable. The Planifest framework must stop offering Roo Code as a supported tool and guide existing users to a recommended alternative."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-017 - Remove or deprecate Roo Code support (extension shut down May 15, 2026)

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Source:** Research — Roo Code (formerly Roo-Cline) announced shutdown on May 15, 2026. The VS Code extension is archived; the team pivoted to Roomote (a cloud agent product). The extension is no longer installable or maintainable. Cline is the recommended migration path for users who relied on Roo Code's tool-call hook model.
**Priority:** must-have

---

## User Story

As a developer who previously used Roo Code in a Planifest repo, I want setup to inform me that Roo Code is no longer supported and recommend a migration path so that I am not left with broken or unenforced hooks.

## Functional Requirements

- `planifest-framework/setup.sh`: when `tool` is `roo-code`, print a deprecation warning and exit 0 — do not proceed with installation:
  ```
  [planifest] WARNING: Roo Code was discontinued on 2026-05-15 and is no longer supported.
  [planifest] Recommended alternative: Cline (compatible hook model, active development).
  [planifest] Re-run setup with --tool cline to configure Planifest for Cline instead.
  ```
- `planifest-framework/setup.ps1`: same warning block when tool is `roo-code`
- REQ-002 (adding `roo-code` to `$ValidTools`) must be reconsidered: `roo-code` should remain in `$ValidTools` solely to trigger the deprecation warning path — it must not proceed to installation
- `planifest-framework/setup/roo-code.sh` (if present): replace contents with the deprecation warning and exit 0; do not delete the file (preserves the dispatch path cleanly)
- `planifest-framework/setup/roo-code.ps1` (if present): same replacement
- The orchestrator skill's tool tier table must mark Roo Code as `Deprecated (2026-05-15) — use Cline` and remove it from the active tier assignments
- Any `planifest-framework/hooks/adapters/roo-code.mjs` (if present): add a deprecation comment header but do not delete; the adapter may still exist in repos installed before the deprecation
- `planifest-framework/skills/planifest-orchestrator/SKILL.md` tool detection logic: remove `roo-code` from active tool detection; if `.clinerules` is the detection signal for Roo Code, note that Cline also uses `.clinerules` — detection should resolve to `cline` in all cases going forward
- `planifest-framework/docs/` or README: add a deprecation notice entry for Roo Code if a changelog or news section exists

## Acceptance Criteria

- [ ] Running `setup.sh --tool roo-code` prints the deprecation warning and exits 0 without installing anything
- [ ] Running `setup.ps1 --tool roo-code` prints the deprecation warning and exits 0 without installing anything
- [ ] `roo-code` remains in `$ValidTools` / valid tool list but routes to a warning-only handler
- [ ] `setup/roo-code.sh` (if present) contains only the deprecation warning and `exit 0`
- [ ] `setup/roo-code.ps1` (if present) contains only the deprecation warning and `Exit-PlanifestSetup`-equivalent
- [ ] Orchestrator skill marks Roo Code as deprecated in the tool tier table
- [ ] No Planifest skill or template instructs the agent to detect or configure Roo Code as an active tool
- [ ] `grep -r 'roo-code' planifest-framework/skills/` returns no active-configuration references (deprecation notices are acceptable)

## Dependencies

- REQ-002 scope must be re-evaluated: adding `roo-code` to `$ValidTools` is still correct, but the install path must route to deprecation, not installation
