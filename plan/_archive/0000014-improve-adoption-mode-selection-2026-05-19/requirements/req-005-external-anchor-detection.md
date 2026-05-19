---
title: "Requirement: REQ-005 - External Anchor Detection"
summary: "Presence of external-versioning.md activates External Anchor mode; human provides version at P0."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-005 - External Anchor Detection

**Skill:** planifest-orchestrator, planifest-ship-agent
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-001
**Priority:** must-have

---

## User Story

As a framework user, I am presented with a clear adoption mode recommendation with reasoning, so that I can confirm or override it with confidence.

---

## Functional Requirements
- When `planifest-overrides/instructions/external-versioning.md` is present, the orchestrator activates External Anchor mode regardless of other signals
- The orchestrator reads `planifest-overrides/instructions/external-versioning.md` and summarises its content to the human as part of the mode recommendation
- The human is prompted to provide the version number directly — no suggestion is made
- The provided version is recorded in the plan during P0 and written to `docs/about.md` at P7 by the ship-agent
- `docs/about.md` is still written at P7 even in External Anchor mode (REQ-004 applies)

## Acceptance Criteria
- [ ] External Anchor mode activates when `planifest-overrides/instructions/external-versioning.md` exists
- [ ] Orchestrator summarises the external-versioning.md content to the human during mode recommendation
- [ ] Human is prompted for a version number (not a confirmation of a suggestion)
- [ ] Provided version is recorded in the plan
- [ ] Ship-agent writes the provided version to `docs/about.md` at P7

## Input Validation
- [ ] Input source: filesystem read of `planifest-overrides/instructions/external-versioning.md`
- [ ] Allowed character pattern: any valid markdown — no character restriction on file content
- [ ] Maximum length: summarise content exceeding 500 characters rather than displaying in full
- [ ] Failure behaviour: if file is unreadable, report error to human and ask them to describe the external constraint manually
- [ ] Logging policy: file path logged in P0 audit trail; full content not injected into build log

## Dependencies
- REQ-001 (External Anchor is the highest-priority detection signal)
- REQ-004 (about.md write at P7 still applies)
