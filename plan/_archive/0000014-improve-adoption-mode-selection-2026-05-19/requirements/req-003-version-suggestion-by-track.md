---
title: "Requirement: REQ-003 - Version Suggestion by Pipeline Track"
summary: "Agent suggests a version number after adoption mode is confirmed, keyed to pipeline track."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-003 - Version Suggestion by Pipeline Track

**Skill:** planifest-orchestrator
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-002
**Priority:** must-have

---

## User Story

As a framework user, I receive a suggested version number after confirming adoption mode, so that I don't have to derive it manually.

---

## Functional Requirements
- After adoption mode is confirmed, the orchestrator reads the current version (see REQ-004 and REQ-009) and suggests a bump based on pipeline track
- Fast Path → suggest patch bump (e.g. 0.5.0 → 0.5.1)
- Change Pipeline → suggest patch bump
- Feature Pipeline → suggest minor bump (e.g. 0.5.0 → 0.6.0)
- Major breaking or revolutionary changes → suggest major bump (e.g. 0.5.0 → 1.0.0); agent must cite the rationale for a major suggestion
- Greenfield mode → suggest `0.1.0` with no bump logic required
- External Anchor mode → no suggestion; human provides the version directly (REQ-005)
- Human always confirms the suggested version; it is never applied automatically
- Confirmed version is recorded in the P0 audit trail and in the plan for use at P7

## Acceptance Criteria
- [ ] Fast Path and Change Pipeline runs suggest a patch bump
- [ ] Feature Pipeline runs suggest a minor bump
- [ ] Major changes suggestion cites rationale
- [ ] Greenfield suggests `0.1.0`
- [ ] External Anchor skips suggestion and prompts human for version
- [ ] Human confirmation is required before version is recorded
- [ ] Confirmed version is written to build log and plan

## Dependencies
- REQ-004 (current version read from `docs/about.md`)
- REQ-009 (version detection hardening, regression block)
- REQ-005 (External Anchor version handling)
