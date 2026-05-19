---
title: "Requirement: REQ-013 - Ship-Agent docs/ Creation and Blocking about.md Write"
summary: "Ship-agent creates docs/ if absent; about.md write at P7 is a blocking step."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-013 - Ship-Agent docs/ Creation and Blocking about.md Write

**Skill:** planifest-ship-agent
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-002
**Priority:** must-have

---

## User Story

As a framework user, I receive a suggested version number after confirming adoption mode, so that I don't have to derive it manually.

---

## Functional Requirements
- At P0 start, the orchestrator ensures `docs/` exists — creates it if absent
- At P7, before writing `docs/about.md`, the ship-agent checks for `docs/` and creates it if absent
- The write of `docs/about.md` at P7 is a blocking step: if the write fails for any reason other than missing directory (which is handled), the pipeline halts with a clear error message naming the failure reason
- `docs/about.md` is included in the P7 git commit — it is not an optional artifact
- The orchestrator initialises `docs/` at P0 so the docs-agent (P6) always has a valid target directory

## Acceptance Criteria
- [ ] Orchestrator creates `docs/` at P0 if absent
- [ ] Ship-agent creates `docs/` at P7 if absent (defensive check)
- [ ] `docs/about.md` write failure at P7 halts the pipeline with a named error
- [ ] `docs/about.md` is staged and committed in the P7 commit
- [ ] P6 docs-agent never encounters a missing `docs/` directory

## Dependencies
- REQ-004 (about.md template and write content)
- REQ-015 (P6 gate A checks docs/ exists)
