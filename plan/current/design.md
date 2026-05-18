# Design - 0000012-docs-restructure-commit-directives

## Feature
- Problem: Framework docs were monolithic; build logs skipped; run mode not persisted; agents invented phase numbers; no formal ship phase; no P0 branch pre-flight.
- Adoption mode: retrofit
- Feature ID: 0000012-docs-restructure-commit-directives

## Product Layer
- User stories:
  - US-001: As a framework user reading getting-started.md, I see a lean 5-step onboarding guide, so that I can set up Planifest without wading through operational detail
  - US-002: As a framework user reading pipeline-reference.md, I find comprehensive step-by-step phase guidance, so that I have a single authoritative reference for the full pipeline
  - US-003: As a framework user reading project-operations.md, I find a concise ops reference, so that I can manage running projects without re-reading the full pipeline
  - US-004: As a pipeline agent, I commit plan/current/ at each phase gate, so that design evolution is preserved in git history incrementally
  - US-005: As a pipeline agent, I write a build log entry at every phase start and gate, so that P8 always has complete data to analyse
  - US-006: As a pipeline orchestrator, I write a run-mode sentinel file at P0 and record explicit human acceptance at each interactive phase gate, so that the run mode and gate acceptance history are permanently recorded
  - US-007: As a pipeline agent, I reference only canonical phases P0–P9 in all output, so that invented phase numbers never appear and every phase has a defined purpose
  - US-008: As a pipeline orchestrator at P9, I create a git tag, ask the human whether to push and raise the PR or provide the PR description for them to use, so that the ship action is explicit and flexible
  - US-009: As a pipeline orchestrator at P0 start, I check the current branch, confirm all previous PRs are merged, and offer to create the feature branch, so that every pipeline run starts from a clean known state
  - US-010: As a repository maintainer, I can run a migration that tags historical merge-to-main commits with their release versions, so that the git history has a complete version tag record
- Acceptance criteria confirmed: 12
- Constraints: Local git only; commit-msg hook enforced; no src/ writes; P9 cannot push without human passphrase
- Integrations: ship-agent spawns build-assessment-agent as sub-agent at P8

## Architecture Layer
- Latency target: not applicable
- Availability target: not applicable
- Scalability target: not applicable
- Security: not applicable — documentation and directive changes only
- Data privacy: no regulated data
- Observability: build log as primary telemetry artifact; 100% phase coverage required
- Cost boundary: not constrained

## Engineering Layer
- Stack: Markdown / YAML — no runtime, no build step, build target: local
- Components:
  - planifest-framework (existing) — docs, orchestrator skill, ship-agent, build-assessment-agent, templates, standards, migrations
- Data ownership: plan/current/ and planifest-framework/migrations/ owned by planifest-framework
- Deployment: local only — committed to feat/ branch, human pushes and raises PR
- API versioning: not applicable

## Scope
- In: docs three-file restructure; plan/_archive correction; phase commit directives; build log Hard Limit; run-mode sentinel; pipeline P0–P9 (P7=Archive, P8=Build Assessment, P9=Ship); P0 pre-flight; P9 git tag + push decision + PR description; ship-agent P7/P8/P9 split; build-assessment-agent sub-agent clarification; pipeline-reference.md P9 addition; component.yml update; retroactive tags migration file
- Out: other phase skills (spec, codegen, validate, security, docs); src/; setup scripts; CI configuration
- Deferred: none

## Assumptions
- SKILL.md edits do not require setup.sh re-run — impact if wrong: human must re-run setup.sh
- build-assessment-agent SKILL.md change is clarification only, no behavioural change — impact if wrong: additional edits needed
- Historical merge commits on main are identifiable from git log — impact if wrong: human must supply commit SHAs manually for the migration

## Risks
- planifest-orchestrator/SKILL.md and planifest-ship-agent/SKILL.md are central; edits to gate and phase behaviour could cause regressions — likelihood: medium, impact: medium; mitigation: targeted edits only, review each section before writing

## Dependencies
- Upstream: patches 001–003 already applied (docs restructure + initial commit directives)
- Downstream: P8 build-assessment-agent depends on build log completeness (US-005); retroactive tags migration depends on human confirming commit→version mapping

## Active Skills
None

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| US-001 to US-004 — docs restructure + commit directives | already implemented via patches 001–003 | retrofit — no further codegen required |
| US-005 — build log Hard Limit | planifest-change-agent | targeted SKILL.md edit; single Hard Limit addition |
| US-006 — run-mode sentinel + gate acceptance | planifest-change-agent | targeted SKILL.md edit; new P0 start action + gate protocol |
| US-007 — phase number enforcement P0–P9 | planifest-change-agent | targeted SKILL.md edit; phase table update + Hard Limit |
| US-008 — P9 Ship phase | planifest-change-agent | ship-agent SKILL.md split; new P9 section with tag/push/PR protocol |
| US-009 — P0 pre-flight | planifest-change-agent | targeted orchestrator SKILL.md edit; new P0 start action |
| US-010 — retroactive tags migration | planifest-change-agent | new migration file in planifest-framework/migrations/ |

## Repo Instructions
### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. You don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees — ensure you are on a feat/ branch but work directly in the working directory.

## Confirmation
Human confirmed this design before proceeding: yes
Date confirmed: 18 May 2026
