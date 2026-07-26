---
title: "Requirement: req-005 - scope-lock-suggested-answers"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-005 - scope-lock-suggested-answers

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000017-ratchet-forgery-detection-and-telemetry-schema-spec
**Source:** US-005
**Priority:** must-have

---

## User Story

As a human being coached through a Scope Lock Challenge question, I'm always offered a suggested answer I can accept, edit, or reject — never one silently assumed on my behalf — so that I keep full control over scope decisions while still getting drafting help on request.

---

## Functional Requirements
- At each Scope Lock Challenge question, the orchestrator asks the human first, and always offers a "want me to suggest an answer?" option — never silently skipped, only triggered on explicit request
- If requested, `planifest-scope-lock-agent` drafts a suggestion under strict usage-only framing: describes only how the finished feature behaves for people using it, never the build/pipeline/implementation process
- For tooling/process items, the draft describes the resulting state a user/reader/operator experiences, never the act of running a tool
- The agent recognizes when a scenario question doesn't meaningfully apply (e.g. static content with no runtime state) and says so explicitly (N/A + why) instead of manufacturing an artificial narrative
- Before presenting a suggestion, the agent checks it against the latest confirmed decisions for that item and explicitly flags any contradiction, unresolved concern, or gap the plain-usage phrasing exposes — never smoothed over
- If no confirmed decisions exist yet to check against (a feature's very first scoping session), the consistency check is skipped silently and the suggestion is shown as-is
- The human must give an explicit affirmative — accept, edit, or reject — for each individual item separately; silence, no objection, flag-resolution, or the conversation moving on must never be read as approval
- Each explicit per-item confirmation is written to `build-log.md` immediately as its own entry — this is the durable record consulted on session resume

## Acceptance Criteria
- [ ] The suggested-answer option is offered at every Scope Lock Challenge question, for every item, without exception
- [ ] A draft is never presented as confirmed
- [ ] Consistency-check flags appear whenever a suggestion conflicts with a prior confirmed decision
- [ ] No item is ever treated as confirmed without an explicit human affirmative recorded in `build-log.md`

## Dependencies
- New `planifest-scope-lock-agent` skill file (authored under this requirement)
- `planifest-orchestrator` Scope Lock Challenge section update to reference the new skill
