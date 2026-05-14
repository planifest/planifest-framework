---
title: "Requirement: REQ-004 - additional-external-skills"
summary: "Extract and add skills from four high-signal repos in _temp/ that were only partially sampled in feature 0000009."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-004 - additional-external-skills

**Skill:** planifest-implementer
**Feature:** 0000010-framework-quality-improvements
**Source:** P0 coaching: user selected option B — exhaust high-signal repos sw-agent-skills, wondelai-skills, garden-skills, marketingskills.
**Priority:** must-have

> Written by the spec-agent. This file contains the requirements for a single feature so that agents can build it without loading the entire project scope.

---

## Functional Requirements

- Source repos (all in `_temp/`): `sw-agent-skills`, `wondelai-skills`, `garden-skills`, `marketingskills`
- For each skill file found in these repos:
  - If a skill covering the same topic already exists in `planifest-framework/external-skills/`, skip it unless the new skill is meaningfully more specific or higher quality (judgement call — document decision in attribution.txt)
  - Otherwise: create `planifest-framework/external-skills/{kebab-case-name}/SKILL.md` and `attribution.txt`
  - `SKILL.md` must have valid frontmatter: `name`, `description`, and the skill body
  - `attribution.txt` must follow the established format: `# Attribution snapshot — captured {date}`, `# Source: {org/repo}`, `# Source URL: {url}`, `# Stars at capture: {n}`, `# Skill: {upstream skill name}`, `# Licence: {licence}`
- After all new skills are written, update `planifest-framework/external-skills/README.md` with new entries in the index table

## Acceptance Criteria

- [ ] All skill files in `_temp/sw-agent-skills` are evaluated; non-duplicate, non-low-quality skills are added to `planifest-framework/external-skills/`
- [ ] All skill files in `_temp/wondelai-skills` are evaluated under the same criteria
- [ ] All skill files in `_temp/garden-skills` are evaluated under the same criteria
- [ ] All skill files in `_temp/marketingskills` are evaluated under the same criteria
- [ ] Every new skill directory contains both `SKILL.md` and `attribution.txt`
- [ ] `attribution.txt` for every new skill correctly identifies the source repo, URL, and licence
- [ ] No existing skill in `planifest-framework/external-skills/` is modified or deleted by this process
- [ ] `planifest-framework/external-skills/README.md` is updated with all new skills
- [ ] Net new skill count is reported in the build log

## Dependencies

- REQ-003 (normalisation) runs as a final pass after REQ-004 writes are complete — REQ-004 must write all new skills before REQ-003 audits and renames
