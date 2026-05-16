---
title: "Requirement: REQ-004 - skill-requirement-mapping"
status: "active"
version: "0.1.0"
---
# Requirement: REQ-004 - skill-requirement-mapping

**Feature:** 0000009-framework-rail-tightening
**Source:** Feature brief AC — orchestrator produces skill-to-requirement map from P0
**Priority:** must-have

---

## Functional Requirements

- At the end of Phase 0 (before presenting the confirmed design for confirmation), the orchestrator produces a skill-to-requirement mapping table and appends it to `plan/current/design.md` under a `## Skill Map` section
- The table maps each functional requirement (req-id + slug) to the Planifest skill best suited to implement or verify it
- At each phase gate (P0→P1, P1→P2, etc.), the orchestrator re-evaluates the skill map against any new or changed requirements and presents additions or changes to the human for confirmation before the next phase begins
- Human confirmation of additions/changes is required before the phase proceeds; rejections are recorded as a note in the skill map entry
- The skill map is updated in `design.md` in place (not duplicated to a new file)
- Format:

  ```markdown
  ## Skill Map

  | Req ID | Requirement | Skill | Confirmed |
  |--------|-------------|-------|-----------|
  | REQ-001 | skips-path-fix | planifest-codegen-agent | yes |
  ```

## Acceptance Criteria

- [ ] `plan/current/design.md` contains a `## Skill Map` section after P0 completion
- [ ] Every functional requirement in the execution plan appears in the skill map
- [ ] The orchestrator SKILL.md documents the skill map protocol in Phase 0 and phase gate sections
- [ ] Re-evaluation at phase gates is documented in the orchestrator SKILL.md gate checklist

## Dependencies

- REQ-001 (design.md must be writable — gate-write must permit it; design.md is always-permitted via plan/ prefix)
