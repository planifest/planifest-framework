---
title: "Requirement: REQ-008 - check-design-inject"
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-008 - check-design-inject

**Feature:** 0000005-framework-governance
**Source:** check-design hard inject user story (feature-brief.md)
**Priority:** should-have

---

## Functional Requirements

- `planifest-framework/hooks/enforcement/check-design.mjs` must be extended: when `plan/current/feature-brief.md` does not exist AND `plan/.orchestrator-active` does not exist, inject a hard STOP directive into the prompt context directing the agent to load the orchestrator skill before proceeding
- The STOP directive must be injected as additional context (UserPromptSubmit hook), not as an error exit — this is guidance injection, not blocking
- If either file exists, normal check-design behaviour proceeds unchanged

## Acceptance Criteria

- [ ] check-design injects hard STOP when both feature-brief.md and sentinel are absent
- [ ] check-design does not inject STOP when either file is present
- [ ] Existing check-design behaviour (scope injection) is unaffected

## Dependencies

- REQ-007 (orchestrator-sentinel) — sentinel file used in check
