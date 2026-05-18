---
title: "Requirement: REQ-010 - retroactive-release-tags-migration"
summary: "Migration file for tagging historical merge-to-main commits with release version tags."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-010 - retroactive-release-tags-migration

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000012-docs-restructure-commit-directives
**Source:** US-010
**Priority:** must-have

---

## User Story

As a repository maintainer, I can run a migration that tags historical merge-to-main commits with their release versions, so that the git history has a complete version tag record.

---

## Functional Requirements
- A migration file is created at `planifest-framework/migrations/retroactive-release-tags.md`
- The migration file follows the Planifest migration format (frontmatter with title, type, description; body with steps)
- Migration body:
  1. Lists the known historical releases with their expected version tags (e.g. v0.1 through v0.10)
  2. Instructs the migrator skill to run `git log --oneline --merges origin/main` (or equivalent) and present the output for the human to map commits to versions
  3. For each confirmed commit→version mapping: run `git tag {version} {commit-sha} -m "{version}"`
  4. After all tags are created: instruct human to run `git push origin --tags`
- The migration is interactive — the human confirms each commit→version mapping before the tag is created
- The migration does not attempt `git push` (local-git-only constraint)

## Acceptance Criteria
- [ ] `planifest-framework/migrations/retroactive-release-tags.md` exists
- [ ] File follows Planifest migration frontmatter format
- [ ] Migration presents git log output for human to map commits to versions
- [ ] Migration creates tags locally only — no push
- [ ] Migration instructs human to push tags separately
- [ ] Human confirmation required for each tag before creation

## Dependencies
- None

## Input Validation

- [ ] Input source: stdout of `git log --oneline --merges` — commit SHAs used in `git tag` commands
- [ ] Allowed character pattern: `[0-9a-f]{7,40}` for commit SHAs — must match before use in git tag command
- [ ] Maximum length: 40 characters per SHA
- [ ] Failure behaviour: if SHA does not match pattern, do not run the tag command — prompt human to supply SHA manually
- [ ] Logging policy: commit SHAs displayed verbatim in human-facing confirmation prompt
