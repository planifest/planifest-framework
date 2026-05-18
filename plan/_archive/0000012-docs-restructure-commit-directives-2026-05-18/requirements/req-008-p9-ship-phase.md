---
title: "Requirement: REQ-008 - p9-ship-phase"
summary: "P9 Ship: ship-agent creates git tag, asks human push/PR preference, outputs PR description."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-008 - p9-ship-phase

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000012-docs-restructure-commit-directives
**Source:** US-008
**Priority:** must-have

---

## User Story

As a pipeline orchestrator at P9, I create a git tag, ask the human whether to push and raise the PR or provide the PR description for them to use, so that the ship action is explicit and flexible.

---

## Functional Requirements
- `planifest-framework/skills/planifest-ship-agent/SKILL.md` is restructured into three phase sections: P7 Archive, P8 Build Assessment (sub-agent spawn), P9 Ship
- P7 Archive responsibilities: write changelog, handle skips, archive `plan/current/` to `plan/_archive/{feature-id}-{YYYY-MM-DD}/`, write `.feature-id` marker, commit
- P8: ship-agent spawns `planifest-build-assessment-agent` as a sub-agent, passing the archived build-log path; waits for the report to be produced before proceeding to P9
- P9 Ship responsibilities:
  1. Read version from `planifest-framework/component.yml` (field: `version`)
  2. Create local git tag: `git tag v{version} -m "{feature-id}"`
  3. Present to human: "P9: Ready to ship. Push branch + create PR, or provide PR description for you to use? [1] Agent pushes / [2] I'll do it"
  4. If [1]: `git push`, `git push --tags`, `gh pr create --title "{title}" --body "{description}"`
  5. If [2]: output PR title and description as a fenced markdown code block for copy-paste
- The `gh pr create` path must respect the `local-git-only` repo instruction — if the instruction is active, default to option [2] without asking

## Acceptance Criteria
- [ ] planifest-ship-agent/SKILL.md has distinct P7, P8, P9 sections
- [ ] P7 section covers archive, changelog, skips, .feature-id, commit — no PR
- [ ] P8 section spawns build-assessment-agent as sub-agent
- [ ] P9 creates a local git tag from component.yml version
- [ ] P9 asks human: agent push or human push
- [ ] Option [2] outputs PR title and description as a fenced markdown code block
- [ ] local-git-only instruction causes P9 to default to option [2]

## Dependencies
- REQ-007 (phase table must be updated before ship-agent restructure)

## Input Validation

- [ ] Input source: filesystem read of `planifest-framework/component.yml`, field `version`
- [ ] Allowed character pattern: `[0-9]+\.[0-9]+(\.[0-9]+)?` — semver-like
- [ ] Maximum length: 20 characters
- [ ] Failure behaviour: if version cannot be read or does not match pattern, prompt human to supply version manually — do not create the tag with an unvalidated value
- [ ] Logging policy: version value logged in P9 build log entry
