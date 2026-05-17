# Risk Register — 0000010-framework-quality-improvements

**Date:** 12 May 2026

---

| ID | Risk | Category | Likelihood | Impact | Mitigation |
|----|------|----------|------------|--------|------------|
| R-001 | REQ-003 renames break references in README.md or attribution.txt files that contain directory paths | Technical | Medium | Low | Audit report produced before renames; README updated atomically with renames; attribution.txt files reference upstream repo not local path |
| R-002 | REQ-004 extracts low-quality or near-duplicate skills that dilute the library | Operational | Medium | Low | Human spot-check commit before merge; skip criteria applied during extraction |
| R-003 | `allowedTools: Agent` (REQ-002) causes Claude Code to spawn agents in unexpected contexts outside Planifest pipelines | Operational | Low | Medium | Addition is project-scoped (`.claude/settings.json`), not global; no effect on other projects |
| R-004 | `_temp/` repos removed or corrupted between pipeline sessions | Technical | Low | High | Check `_temp/` presence at P3 start; if absent, halt REQ-004 and report |
| R-005 | Skill name field contains characters that produce an invalid directory name after kebab-case conversion | Technical | Low | Low | Normalisation strips non-alphanumeric (except hyphens); result validated before rename |
| R-006 | Two skills normalise to the same kebab-case name (collision) | Technical | Low | Low | Collision detection runs before any rename; duplicates left unrenamed, documented in req-003-collisions.md |
