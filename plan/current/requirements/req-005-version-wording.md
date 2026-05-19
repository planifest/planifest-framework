---
title: "Requirement: REQ-005 - Version Suggestion States Last Known Version"
summary: "Orchestrator step 3b explicitly states the last known version before suggesting a bump."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-005 - Version Suggestion States Last Known Version

**Skill:** planifest-codegen-agent
**Feature:** 0000015-pipeline-session-cleanup
**Source:** US-001
**Priority:** must-have

---

## User Story

As a pipeline operator, I want each new feature to start with a completely clean session state, so that stale settings from a previous run never contaminate a new P0.

---

## Functional Requirements
- The version suggestion message in orchestrator step 3b must include the phrase "Last known version: `{version}`" before presenting the suggested bump
- Format:
  ```
  P0: Last known version: `{version}` (from docs/about.md).
  Suggested version for this {track}: `{suggested}`.
  Confirm? ({suggested} / other)
  ```
- If `docs/about.md` is absent, the message states: "No prior version found (docs/about.md absent)." and suggests `0.1.0` for Feature Pipeline or asks the human to provide a version

## Acceptance Criteria
- [ ] Version suggestion message explicitly states the last known version and its source
- [ ] The suggested bump is shown on a separate line from the last known version
- [ ] When docs/about.md is absent, the message explicitly says so rather than showing a blank or `null`
