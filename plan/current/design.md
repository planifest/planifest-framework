# Design - 0000014-improve-adoption-mode-selection

## Feature
- Problem: Phase 0 adoption mode selection is not surfaced as an explicit guided step; adoption mode is always incorrectly persisted as "retrofit" in design.md; no version suggestion mechanism exists across the pipeline
- Confirmed version: 0.14.0
- Adoption mode: retrofit
- Feature ID: 0000014-improve-adoption-mode-selection

## Product Layer
- User stories:
  - US-001: As a framework user, I am presented with a clear adoption mode recommendation with reasoning, so that I can confirm or override it with confidence
  - US-002: As a framework user, I receive a suggested version number after confirming adoption mode, so that I don't have to derive it manually
  - US-003: As a framework user, I am warned when my adoption mode or version choice conflicts with detected signals, so that I don't make uninformed decisions
- Acceptance criteria confirmed: 17
- Constraints:
  - No runtime — all changes are to markdown skill files and templates
  - Must not break existing pipeline runs in progress
  - External Anchor mode is only active when planifest-overrides/instructions/external-versioning.md is present
  - One question at a time is a core P0 instruction — enforced throughout, not just during Scope Lock
  - Agent must recommend then ask for confirmation, not ask open-ended questions
- Integrations:
  - planifest-orchestrator reads docs/about.md at P0
  - planifest-ship-agent (P7) writes docs/about.md after archiving

## Architecture Layer
- Latency target: not applicable (skill file authoring)
- Availability target: not applicable
- Scalability target: not applicable
- Security: no auth, no regulated data, no PII
- Data privacy: no regulated data
- Observability: standard defaults
- Cost boundary: not constrained

## Engineering Layer
- Stack: Markdown skill authoring — no runtime, no build step, no database, no cloud, no CI gate
- Components:
  - `planifest-orchestrator skill` — adoption mode protocol, version suggestion, conflict warnings, four-mode taxonomy, Scope Lock Challenge, structured P0 audit trail, one-question-at-a-time instruction
  - `planifest-spec-agent skill` — one-question-at-a-time instruction
  - `planifest-adr-agent skill` — one-question-at-a-time instruction
  - `planifest-codegen-agent skill` — one-question-at-a-time instruction
  - `planifest-validate-agent skill` — one-question-at-a-time instruction
  - `planifest-security-agent skill` — one-question-at-a-time instruction
  - `planifest-docs-agent skill` — one-question-at-a-time instruction + P6 gate sharpening
  - `planifest-ship-agent skill` — docs/about.md blocking write + docs/ creation + one-question-at-a-time instruction
  - `planifest-change-agent skill` — one-question-at-a-time instruction
  - `design.template.md` — update adoption mode field values; fix retrofit persistence bug
  - `about.template.md` — new template for docs/about.md (YAML frontmatter + version field)
  - `feature-brief.template.md` — add Scenario Paths section
- Data ownership:
  - `docs/about.md` owned by the pipeline (written by ship-agent at P7, read by orchestrator at P0)
  - All other artifacts owned by their respective phase agents
- Deployment: framework files — no deployment topology
- API versioning: not applicable

## Component Paths
- planifest-framework/
- docs/

## Scope
- In:
  - Four adoption modes: Greenfield, Standard Iterative, Retrofit, External Anchor
  - Explicit adoption mode selection step early in P0 (recommendation + confirmation, not buried in coaching)
  - External Anchor detection: presence of planifest-overrides/instructions/external-versioning.md triggers this mode
  - Signal conflict priority order: External Anchor > Standard Iterative > Retrofit > Greenfield
  - Version suggestion by pipeline track: Fast Path → patch, Change Pipeline → patch, Feature Pipeline → minor, major breaking → major
  - Version detection reads docs/about.md AND archive history as signals; malformed/missing version prompts human with best-guess recommendation
  - Version regression hard block: agent refuses lower-than-current version; reset requires re-versioning archives first
  - about.md template at planifest-framework/templates/about.template.md
  - docs/about.md read at P0 (Standard Iterative + Retrofit + External Anchor modes); written by ship-agent at P7 (blocking — not best-effort); ship-agent creates docs/ if absent
  - docs/ initialized at P0; P6 gate fails if docs/ does not exist (REQ-015); agent assesses whether change requires docs update, recommends, human confirms (REQ-016)
  - Conflict warnings: agent warns when human's mode or version choice conflicts with detected signals
  - Bug fix: adoption mode field in design.template.md always presents as "retrofit" — fix the template field
  - Update design.template.md adoption mode values to reflect four-mode taxonomy
  - Migration file (planifest-framework/migrations/) that: (a) scans plan/_archive/**/design.md, auto-detects best-guess adoption mode per archive from context clues, presents each to human via planifest-migrator one at a time; (b) initialises docs/about.md — suggests version derived from about.md + archive history, asks human to confirm; resumable via progress file in planifest-framework/migrations/_progress/
  - Scope Lock Challenge: agent derives relevant happy/sad/bad path scenarios from the specific feature; one question at a time; immediate capture + brief clarify + explicit resume loop; probes vague "no" answers; formal deferred capture to Scope → Deferred and build log
  - Structured P0 audit trail: build log P0 notes capture questions asked, answers given, items deferred; feeds P8 build assessment
  - One-question-at-a-time as framework-wide core instruction: enforced in orchestrator and all phase skills (spec-agent, adr-agent, codegen-agent, validate-agent, security-agent, docs-agent, ship-agent, change-agent); agent recommends then confirms, never asks open-ended; P0 additionally walks happy/sad/bad paths before scope locks
  - Feature Brief template: add Scenario Paths section prompting for first-run, error states, upgrade path, cross-session continuity
- Out:
  - Runtime code of any kind
  - Changes to CI or deployment pipeline
  - docs/about.md UI or tooling outside the orchestrator/ship-agent
- Deferred: None

## Assumptions
- docs/ directory exists or is created at P6 (docs-agent) — impact if wrong: ship-agent write of about.md fails at P7; mitigate by having ship-agent create docs/ if absent
- The "always retrofit" bug is in design.template.md field values, not in the orchestrator write logic — impact if wrong: fix target is wrong; will investigate during codegen

## Risks
- Risk: Changing the adoption mode taxonomy breaks existing references to "agent-interface" in prior skill files — likelihood: medium, impact: low (prior archives unaffected; only active skill files)
- Risk: about.md write at P7 conflicts with existing docs/ content — likelihood: low, impact: low (file is new; only risk is if docs/ already has an about.md from a prior manual run)

## Dependencies
- Upstream: planifest-orchestrator skill (read)
- Downstream: planifest-ship-agent (about.md write); any consumer that reads docs/about.md

## Active Skills
None

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| REQ-001 — adoption mode detection signals | planifest-codegen-agent | Editing skill file prose — structured content generation |
| REQ-002 — explicit mode selection step in P0 | planifest-codegen-agent | Editing skill file prose — structured content generation |
| REQ-003 — version suggestion by pipeline track | planifest-codegen-agent | Editing skill file prose — structured content generation |
| REQ-004 — about.md template and read/write protocol | planifest-codegen-agent | New template file + skill file edit |
| REQ-005 — External Anchor override detection | planifest-codegen-agent | Editing skill file prose — conditional logic |
| REQ-006 — conflict warnings for mode and version | planifest-codegen-agent | Editing skill file prose — warning protocol |
| REQ-007 — bug fix: design.template.md adoption mode field | planifest-codegen-agent | Single-file template fix |
| REQ-008 — migration: fix archived design.md adoption modes + init docs/about.md | planifest-codegen-agent | New migration file + resumable progress tracking |
| REQ-009 — signal conflict priority + version detection hardening | planifest-codegen-agent | Priority order, malformed fallback, regression block, archive signal |
| REQ-010 — Scope Lock Challenge protocol | planifest-codegen-agent | Derived scenarios, capture+clarify+resume loop, formal deferred capture |
| REQ-011 — structured P0 audit trail | planifest-codegen-agent | Build log P0 notes structured; feeds P8 |
| REQ-012 — one-question-at-a-time as framework-wide core instruction | planifest-codegen-agent | Enforced in orchestrator + all phase skills; recommend-then-confirm; P0 path-walking |
| REQ-013 — ship-agent docs/ creation + blocking about.md write | planifest-codegen-agent | Ship-agent creates docs/ if absent; write is blocking |
| REQ-014 — migration resumable with progress file | planifest-codegen-agent | Progress file in migrations/_progress/ |
| REQ-015 — P6 gate A: docs/ existence check | planifest-codegen-agent | Gate fails if docs/ does not exist |
| REQ-016 — P6 gate B: docs update recommendation | planifest-codegen-agent | Agent assesses and recommends whether docs update needed; human confirms |
| REQ-017 — Feature Brief template: Scenario Paths section | planifest-codegen-agent | Add section prompting for first-run path, error states, upgrade/rollback path, and cross-session continuity before coaching begins |

## Repo Instructions
### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. You don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

## Confirmation
Human confirmed this design before proceeding: yes
Date confirmed: 19 May 2026
