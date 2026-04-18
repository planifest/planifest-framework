---
title: "Requirement: REQ-022 - CLAUDE.md updated to note active hook enforcement"
summary: "CLAUDE.md gains a note that enforcement hooks are active and manual compliance checks are now redundant documentation."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-022 - CLAUDE.md update

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief Track B scope
**Priority:** should-have

---

## Functional Requirements

- `CLAUDE.md` is updated with a note under the relevant Hard Limits or Operational Directives section:
  `"Hook enforcement is active: gate-write.mjs blocks writes outside confirmed design scope; check-design.mjs injects scope context on every turn. Manual scope checks in these instructions are retained as documentation but are now redundant enforcement."`
- The note does not remove any existing Hard Limits — it adds context so agents understand the hook layer exists.
- The note references the setup scripts for hook installation guidance.

## Acceptance Criteria

- [ ] `CLAUDE.md` contains a note that hook enforcement is active.
- [ ] Existing Hard Limits are unchanged.
- [ ] The note is placed in a logical position (after Hard Limit 1 or in Operational Directives).

## Dependencies

- REQ-006 (`gate-write.mjs` must exist before the note is accurate).
- REQ-005 (`check-design.mjs` must exist before the note is accurate).
- REQ-008 (setup scripts must install the hooks for the note to be actionable).
