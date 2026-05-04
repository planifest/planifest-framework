---
title: "Requirement: req-003 - optimise-agent-skill"
status: "active"
version: "0.1.0"
---
# Requirement: req-003 — planifest-optimise-agent skill

**Feature:** 0000007-agent-optimisation
**Source:** User story — "As a developer, I invoke planifest-optimise-agent on demand and receive one suggestion at a time for removing superfluous content from Planifest skill files; I confirm or reject each; confirmed items become requirements"
**Priority:** must-have

---

## Functional Requirements

- `planifest-framework/skills/planifest-optimise-agent/SKILL.md` MUST exist with valid frontmatter (`name`, `description`, `bundle_standards`, `hooks`)

- The skill MUST target `planifest-framework/skills/` only — it MUST NOT review `planifest-overrides/capability-skills/` or workflow files

- The skill MUST identify and present the following categories of superfluous content:
  - Implicit model knowledge stated explicitly (things any capable model already knows)
  - Instructions duplicated from hook enforcement (already enforced by gate-write, CLAUDE.md, etc.)
  - Boilerplate repeated verbatim across multiple skill files (no unique signal per file)
  - Sections with stale references to non-existent files or deleted artifacts

- The skill MUST present one suggestion at a time in chat, with:
  - The category of superfluity
  - The exact content proposed for removal (file path, section name, quoted text)
  - A one-line rationale

- The skill MUST wait for human `confirm` or `reject` before presenting the next suggestion

- Confirmed items MUST be accumulated in a numbered list visible in the conversation

- At the end of the review, the skill MUST produce a confirmed-changes summary suitable as input to a Change Pipeline run

- The skill MUST NOT apply any changes itself — suggestions only

## Acceptance Criteria

- [ ] `planifest-optimise-agent/SKILL.md` exists with correct frontmatter
- [ ] Skill presents exactly one suggestion at a time before waiting for input
- [ ] Skill correctly identifies at least the four categories of superfluous content listed above
- [ ] Confirmed items are accumulated and shown as a numbered list
- [ ] End-of-review summary is produced listing all confirmed changes
- [ ] Skill never modifies any file

## Dependencies

- None — this is a new standalone skill
