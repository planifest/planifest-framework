---
title: "Requirement: REQ-020 - Raise PR after P8 build assessment, not before archive"
summary: "The ship agent currently raises the PR in Step 4, before archiving plan/current/ and invoking the P8 build assessment. This means archive commits and the build-report.md are not included in the PR branch at raise time, forcing a second PR or branch. The PR must be raised after P8 completes so all artefacts are present."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-020 - Raise PR after P8 build assessment, not before archive

**Skill:** spec-agent
**Feature:** 0000011-setup-parity-and-consistency
**Priority:** must-have

---

## User Story

As a developer completing a Planifest feature pipeline, I want the PR to be raised after the archive and build assessment are complete so that the archive commits and build-report.md are part of the same PR without needing a second branch.

## Functional Requirements

### Step reordering in planifest-ship-agent/SKILL.md

The ship agent execution sequence must be reordered so that `gh pr create` is called **after** Step 8 (P8 Build Assessment), not before the archive. The new step order is:

1. Produce PR description (draft only — do not raise yet)
2. Write changelog (leave `PR:` field as `{pending}` placeholder)
3. Process `.skips`
4. Write `.feature-id` marker
5. Step R — Regression confirmation
6. Step T — Test report
7. Archive `plan/current/` to `plan/_archive/{feature-id}-{YYYY-MM-DD}/`
8. Invoke P8 Build Assessment (build-report.md written to archive)
9. **Raise the PR** — all archive and build report commits are now on the branch
10. Update changelog `PR:` field with the URL returned by `gh pr create`
11. Confirm to human

The ship-agent description, opening statement, and telemetry `phase_end` comment must be updated to reflect that the PR is raised at the end, after P8.

### planifest-orchestrator/SKILL.md

The P7 gate description must be updated:
- Remove any statement that the PR is raised during P7 before archive
- Clarify that the PR is raised after P8 completes, as the final step before the human confirmation stop

## Acceptance Criteria

- [ ] `planifest-ship-agent/SKILL.md`: PR description draft step precedes archive; `gh pr create` step follows P8 invocation
- [ ] `planifest-ship-agent/SKILL.md`: changelog `PR:` field is noted as updated after `gh pr create` completes
- [ ] `planifest-ship-agent/SKILL.md`: description frontmatter and opening statement no longer describe PR raise as a pre-archive action
- [ ] `planifest-orchestrator/SKILL.md`: P7 gate description reflects the post-P8 PR raise sequence

## Dependencies

- None
