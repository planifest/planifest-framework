---
title: "Requirement: REQ-009 - Signal Conflict Priority and Version Detection Hardening"
summary: "Priority order for conflicting mode signals; malformed version fallback; version regression hard block."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-009 - Signal Conflict Priority and Version Detection Hardening

**Skill:** planifest-orchestrator
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-003
**Priority:** must-have

---

## User Story

As a framework user, I am warned when my adoption mode or version choice conflicts with detected signals, so that I don't make uninformed decisions.

---

## Functional Requirements
- Signal conflict priority order is: External Anchor > Standard Iterative > Retrofit > Greenfield — higher priority always wins
- When multiple signals are present, the orchestrator applies the priority order silently and states which signal won and why in the mode recommendation
- Version detection reads both `docs/about.md` and archive history (most recent archived feature's version) as signals
- When `docs/about.md` version is malformed or missing: orchestrator reads archive history, recommends a best-guess version, and asks human to confirm — one question
- Version regression hard block: if the human confirms a version lower than the currently recorded version, the orchestrator refuses and states the current version and why regression is blocked; instructs that archives must be re-versioned to reset
- External Anchor cannot be overridden by the human regardless of stated preference

## Acceptance Criteria
- [ ] External Anchor takes priority over all other signals — override attempt is rejected
- [ ] Standard Iterative takes priority over Retrofit when both signals are present
- [ ] Version detection reads `docs/about.md` first, then archive history as fallback
- [ ] Malformed/missing version triggers best-guess recommendation from archive history + human confirmation
- [ ] Version lower than current is hard-blocked with specific error message citing current version
- [ ] Regression block message instructs human on the re-versioning path

## Input Validation
- [ ] Input source: `docs/about.md` version field and archive design.md version fields
- [ ] Allowed character pattern: `[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?` — semver; non-matching treated as malformed
- [ ] Maximum length: 32 characters
- [ ] Failure behaviour: malformed → fall back to archive history; archive history unreadable → ask human directly
- [ ] Logging policy: version signals read logged in P0 audit trail

## Dependencies
- REQ-001 (mode detection)
- REQ-004 (about.md read)
