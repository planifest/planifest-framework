---
title: "Requirement: REQ-019 - planifest-ship-agent SKILL.md (new Phase 7 skill)"
summary: "A new dedicated skill for Phase 7: raise PR, write changelog, archive plan/current/."
status: "done"
version: "0.1.0"
---
# Requirement: REQ-019 - planifest-ship-agent SKILL.md

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief Track D scope; DD-008, DD-012
**Priority:** must-have

---

## Functional Requirements

- Create `planifest-framework/skills/planifest-ship-agent/SKILL.md` as a standalone skill file.
- The ship-agent is the Phase 7 agent: it handles PR creation, changelog writing, and plan archiving.
- The ship-agent SKILL.md specifies the `P7:` prefix convention on all responses.
- Ship process steps:
  1. Read `plan/current/feature-brief.md` and all artefacts to produce the PR description.
  2. Write `plan/changelog/{feature-id}-{YYYY-MM-DD}.md` as the audit trail.
  3. Append `.skips` content to the iteration log under `## Skipped Phases`; delete `.skips`.
  4. Raise the PR (gh pr create or equivalent).
  5. Write `plan/current/.feature-id` with the feature ID (marker for resume detection of stale artefacts).
  6. **Copy** `plan/current/` → `plan/archive/{feature-id}-{YYYY-MM-DD}/` with `-{n}` collision suffix if same-day re-run. Copy first; delete after successful copy.
  7. Delete `plan/current/` contents (including `.skips`, `.planifest-session`, `.feature-id`) after archive copy confirmed.
  8. Confirm archive path and PR URL to human.
- The ship-agent uses `"phase": "ship"` in telemetry events (requires coordinated MCP enum update).
- The ship-agent is invoked by the orchestrator at Phase 7; it is not invoked standalone.

## Acceptance Criteria

- [ ] `planifest-framework/skills/planifest-ship-agent/SKILL.md` exists with the 6 ship steps documented.
- [ ] Ship agent uses `P7:` prefix on all responses.
- [ ] Archive uses copy-then-delete (not move); re-run after failed archive adds `-{n}` suffix and proceeds.
- [ ] `.feature-id` marker written before archive copy begins.
- [ ] `.skips`, `.planifest-session`, and `.feature-id` are all deleted after archive copy confirmed.
- [ ] Ship agent SKILL.md references the `"ship"` phase value for telemetry.

## Dependencies

- REQ-017 (`.skips` file must be handled in ship).
- Structured-telemetry-mcp `"ship"` enum addition (coordinated deploy — see risk register R-001).
- DD-012 (archive path and collision suffix specification).
