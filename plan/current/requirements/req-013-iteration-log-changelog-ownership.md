---
id: REQ-013
slug: iteration-log-changelog-ownership
title: Clarify iteration log vs ship-agent changelog ownership
priority: low
status: open
---

# REQ-013 — Clarify iteration log vs changelog ownership

## User Story

As a pipeline author, I want the distinction between the docs-agent iteration log and the ship-agent changelog to be documented in both artifacts, so that future agents and humans understand which file serves which audience.

## Acceptance Criteria

- [ ] `planifest-framework/templates/iteration-log.template.md` has a preamble note stating: iteration log = machine-readable execution trace for the build-assessment-agent and post-run review; it is NOT the PR changelog
- [ ] `planifest-framework/skills/planifest-ship-agent/SKILL.md` Step 1 changelog description includes a note: the changelog is the human-readable audit trail for the PR reviewer; the iteration log (written by docs-agent) is the execution trace

## Dependencies

- REQ-008 (ship-agent P7 changelog step exists)
