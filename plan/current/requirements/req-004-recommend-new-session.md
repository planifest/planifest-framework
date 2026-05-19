---
title: "Requirement: REQ-004 - Recommend New Session After P9"
summary: "After P9 final confirmation, orchestrator recommends starting a new session before the next feature."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-004 - Recommend New Session After P9

**Skill:** planifest-codegen-agent
**Feature:** 0000015-pipeline-session-cleanup
**Source:** US-003
**Priority:** must-have

---

## User Story

As a pipeline operator, I want P9 to recommend a new session before I start the next feature, so that context window pressure from the previous run doesn't affect the next P0.

---

## Functional Requirements
- After the P9 final confirmation message (Step 10 of ship-agent), the orchestrator appends a new-session recommendation:
  ```
  P9: Complete — {feature-id} shipped at v{version}.

  ⚡ Start a new session before beginning the next feature.
  This clears the context window and ensures a clean P0 with full pre-flight.
  ```
- The recommendation is always shown — it is not conditional on run mode or context pressure
- No action is taken by the orchestrator after this message — it stops

## Acceptance Criteria
- [ ] P9 final output includes the new-session recommendation
- [ ] The recommendation appears after the PR/tag summary, not before
- [ ] The orchestrator does not attempt to begin a new P0 in the same session after P9
