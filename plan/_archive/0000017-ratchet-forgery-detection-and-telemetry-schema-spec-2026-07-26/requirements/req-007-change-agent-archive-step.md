---
title: "Requirement: req-007 - change-agent-archive-step"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-007 - change-agent-archive-step

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000017-ratchet-forgery-detection-and-telemetry-schema-spec
**Source:** US-007
**Priority:** must-have

---

## User Story

As anyone reading this framework's documentation after a Change Pipeline run, I find `plan/current/` archived to `plan/_archive/{feature-id}-{date}/` exactly like a Feature Pipeline run, with no stale links left pointing at the pre-archive path — so that the repo's `plan/` layout is always consistent regardless of which pipeline route built a given feature, and no agent ever infers "archiving is optional" from a mixed layout.

---

## Functional Requirements
- Add a `### Phase 6 - Archive` step to `planifest-change-agent`'s SKILL.md, immediately after the existing Phase 5 (Update Documentation), per the diff in `plan/backlog/0000011-change-agent-missing-archive-step/change-agent-SKILL.md.diff`: copy-then-delete `plan/current/` (or the active working folder) to `plan/_archive/{feature-id}-{YYYY-MM-DD}/` (suffix `-2`, `-3`, ... on collision), confirm the copy before deleting, delete `plan/.orchestrator-active` last
- Add a cross-reference check to the same new Phase 6 step: before moving, search the repo for links pointing at the pre-move path (`docs/*.md`, `src/*/docs/*.md`, `plan/changelog/*.md`, and any other living doc referencing `plan/current/adr/`, `plan/current/...`, or the feature's slug) and update every found reference to the new archive path in the same commit as the move
- Add the same cross-reference check to `planifest-ship-agent`'s existing P7 Step 6, per the diff in `plan/backlog/0000011-change-agent-missing-archive-step/ship-agent-SKILL.md.diff` — closing the same gap for Feature Pipeline archiving (confirmed in practice against a downstream repo: `0000010`'s own ADR links in `decisions-index.md` were left stale after P7 ran)
- Add a 10th Hard Limit to `planifest-orchestrator`'s Hard Limits list mandating archiving for both the Feature Pipeline and Change Pipeline routes — this failure mode was already observed once (a fresh agent with no session memory inferred "Change Pipeline doesn't archive" from a mixed `plan/` layout and replicated the bug on two more features in a downstream repo)

## Acceptance Criteria
- [ ] `planifest-change-agent`'s SKILL.md has a Phase 6 - Archive step matching the diff's copy-then-delete pattern
- [ ] The new Phase 6 step includes the cross-reference check before moving
- [ ] `planifest-ship-agent`'s P7 Step 6 includes the same cross-reference check
- [ ] `planifest-orchestrator`'s Hard Limits list has a 10th entry mandating archiving for both pipeline routes
- [ ] A Change Pipeline run leaves no permanent top-level `plan/{feature-id}/` folder — every run ends archived to `plan/_archive/`

## Dependencies
- None — additive changes to two existing skills, no interaction with req-001 through req-006

## Source

Picked up from `plan/backlog/0000011-change-agent-missing-archive-step/entry.md` — filed 25 Jul 2026 by a cross-repo, read-only investigation in the sibling `structured-telemetry-mcp` repo. The entry's two open sub-decisions (whether to add a Hard Limit; whether the diff text alone is sufficient) are resolved above: both — apply the diffs as specified AND add the Hard Limit, since the failure mode has already recurred once and the addition is small.
