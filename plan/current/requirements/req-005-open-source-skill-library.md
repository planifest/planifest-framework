---
title: "Requirement: REQ-005 - open-source-skill-library"
status: "active"
version: "0.1.0"
---
# Requirement: REQ-005 - open-source-skill-library

**Feature:** 0000009-framework-rail-tightening
**Source:** Feature brief AC — curated open-source skill library with permissive license and attribution.txt
**Priority:** should-have

---

## Functional Requirements

- A directory `planifest-framework/external-skills/` is created to hold curated open-source skills
- Each skill occupies its own subdirectory: `planifest-framework/external-skills/{skill-name}/`
- Each skill directory contains:
  - `SKILL.md` — the skill content (unchanged from source, or minimally adapted for SKILL.md format)
  - `attribution.txt` — containing: license type, copyright holder, source URL, and any required attribution text from the original license
- Only skills with permissive licenses (MIT, Apache 2.0, ISC, BSD-2-Clause, BSD-3-Clause, or equivalent) are included; skills with GPL, AGPL, or unknown licenses are excluded
- `setup.sh` and `setup.ps1` accept a new flag `--include-full-skill-library`; when set, all skills in `external-skills/` are copied to the tool's skill directory alongside the built-in skills
- Without the flag, external skills are not copied (opt-in)
- The library is populated during this pipeline run via web search for highly-regarded open-source Claude Code SKILL.md-format skills; a minimum of 3 skills must be included
- A `README.md` in `planifest-framework/external-skills/` lists all included skills with their source URLs and license types

## Acceptance Criteria

- [ ] `planifest-framework/external-skills/` exists with at least 3 skill subdirectories
- [ ] Every skill subdirectory contains both `SKILL.md` and `attribution.txt`
- [ ] `attribution.txt` in each skill contains: license type, copyright holder, source URL, required attribution text
- [ ] No skill with a GPL, AGPL, or unknown license is included
- [ ] `setup.sh --include-full-skill-library` copies all external skills to the tool's skill dir
- [ ] `setup.ps1 --include-full-skill-library` does the same (PS1 parity)
- [ ] Without the flag, external skills are not copied
- [ ] `planifest-framework/external-skills/README.md` exists and lists all skills with source URLs and licenses
- [ ] Re-running setup with the flag is idempotent (no duplicate copies)

## Dependencies

- None
