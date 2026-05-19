# Design - 0000015-pipeline-session-cleanup

## Feature
- Problem: Pipeline session state (run-mode) persists across features; build log phase blocks are skipped in most phases; P9 has no cleanup or handoff protocol; interrupted P9 leaves partial state with no recovery path
- Confirmed version: 0.15.0
- Adoption mode: standard-iterative
- Feature ID: 0000015-pipeline-session-cleanup

## Product Layer
- User stories:
  - US-001: As a pipeline operator, I want each new feature to start with a completely clean session state, so that stale settings from a previous run never contaminate a new P0
  - US-002: As a pipeline operator, I want the build log to capture every phase boundary, so that P8 build assessment has a complete picture of the run
  - US-003: As a pipeline operator, I want P9 to recommend a new session before I start the next feature, so that context window pressure from the previous run doesn't affect the next P0
- Acceptance criteria confirmed: 6
- Constraints: docs-only changes — no runtime code, no TDD loop
- Integrations: none

## Architecture Layer
- Latency target: not applicable
- Availability target: not applicable
- Scalability target: not applicable
- Security: no regulated data; no auth changes
- Data privacy: no regulated data
- Observability: build log completeness is the primary observable
- Cost boundary: not constrained

## Engineering Layer
- Stack: markdown — no runtime, no build target
- Components:
  - planifest-orchestrator — owns P0 pre-flight (stale run-mode check, version wording) and build log enforcement
  - planifest-ship-agent — owns P9 cleanup (run-mode deletion, new-session recommendation) and interrupted-P9 detection
- Data ownership: no data stores
- Deployment: skill files in planifest-framework/skills/
- API versioning: not applicable

## Component Paths
- planifest-framework/

## Scope
- In:
  - REQ-001: orchestrator writes build log phase block before every phase P0–P9
  - REQ-002: ship-agent deletes plan/.run-mode at P9 cleanup (Step 6)
  - REQ-003: orchestrator P0 pre-flight detects stale plan/.run-mode, errors, clears, warns human
  - REQ-004: after P9 final confirm, orchestrator recommends new session before next feature
  - REQ-005: version suggestion step explicitly states "last known version was X" before proposing bump
  - REQ-006: interrupted P9 detected on resume (plan/current/ empty but .orchestrator-active present); orchestrator completes cleanup before new P0
- Out:
  - Changes to any phase skill other than orchestrator and ship-agent
  - Runtime code, tests, infrastructure
- Deferred: none

## Assumptions
- An interrupted P9 can be reliably detected by the combination of plan/current/ being empty and plan/.orchestrator-active still present — impact if wrong: resume detection routes incorrectly to P0 instead of completing P9 cleanup

## Risks
- Low/Low: orchestrator skill is large; edits may conflict with 0000014 changes — mitigated by reading the file before editing

## Dependencies
- Upstream: planifest-framework/skills/planifest-orchestrator/SKILL.md (modified by 0000014)
- Downstream: none

## Active Skills
None

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| REQ-001 - build-log-all-phases | planifest-codegen-agent | direct edit to orchestrator skill |
| REQ-002 - clear-run-mode-p9 | planifest-codegen-agent | direct edit to ship-agent skill |
| REQ-003 - stale-run-mode-check | planifest-codegen-agent | direct edit to orchestrator skill |
| REQ-004 - recommend-new-session | planifest-codegen-agent | direct edit to ship-agent skill |
| REQ-005 - version-wording | planifest-codegen-agent | direct edit to orchestrator skill |
| REQ-006 - interrupted-p9-resume | planifest-codegen-agent | direct edit to orchestrator resume detection |

## Repo Instructions
None

## Confirmation
Human confirmed this design before proceeding: yes
Date confirmed: 19 May 2026
