# Design - 0000016-pipeline-governance-and-loop-engineering

## Feature
- Problem: The pipeline has no durable home for deferred work (scope-creeps or gets dropped), no product-level version model for multi-component projects, no governed way for P0–P6 to correct itself when a downstream phase hits an upstream design defect, no execution-time verification of acceptance criteria, and commits are too coarse (batched to one per phase gate rather than per meaningful artifact).
- Adoption mode: standard-iterative (recommended from `plan/_archive/` + `docs/about.md` signals; final confirmation deferred to implementation per human instruction, 2026-07-04)
- Feature ID: 0000016-pipeline-governance-and-loop-engineering

> Note: adoption mode, exact version bump, run mode (interactive vs. continuous), and whether to make feature-branch remote push a standing exception in `planifest-overrides/instructions/custom-001-local-git-only.md` are all recorded here as working recommendations. Per explicit human instruction, final confirmation on these is deferred to P3 (implementation) rather than blocking here.

## Product Layer
- User stories: 21 stories across 2 waves — see `plan/current/feature-brief.md` § Features for full text. Summary by theme:
  - US-001–002: backlog folder + P0 pickup protocol
  - US-003–005: `product.yml` / `versionPolicy` + ship-agent/orchestrator version detection
  - US-006: Phase → Wave terminology correction
  - US-007–008: fine-grained phase commits + feature-branch remote push cadence
  - US-009–019: loop-runner, loop state/run-log, telemetry+toggles, P0 completeness loop, design-critic + consistency checks, defect report, reversal-assessor, governed reversal execution, ratchet hook, reversal human gates
  - US-020–021: verify-by-execution, cross-model review gate (positioned before P7 archive)
- Acceptance criteria confirmed: 14 (see feature-brief.md § Acceptance Criteria)
- Constraints: skills advise / hooks enforce; maker-checker separation (REJECT-default) for critic/assessor/reviewer; ratchet rule blocks silent weakening; stop rules (iteration cap, no-progress detection) armed on every loop; human gates on re-exit from P0, budget exhaustion, and altering reversals; rollout discipline (report-only before write/act); P7 remains the lock line — no loop/reversal machinery touches archived/committed state
- Integrations: structured-telemetry-mcp (new event types); GitHub (feature-branch push/PR)

## Architecture Layer
- Latency target: not applicable — framework tooling (skills, templates, hooks), no runtime service
- Availability target: not applicable
- Scalability target: not applicable
- Security: not applicable in the traditional auth/authz sense; the equivalent trust boundary is maker-checker separation (REJECT-default verifiers never share context with the agent that produced the work under review) and the ratchet hook (deterministic block on silent criteria/scope weakening)
- Data privacy: no regulated data — all new artifacts (backlog entries, product.yml, loop state, run logs) are plain markdown/YAML in the repo
- Observability: new telemetry event types (`loop_iteration`, `phase_reversal_petitioned/granted/denied`) extending the existing feature-0000009 envelope; loop state + append-only run-log files per the loop-runner skill
- Cost boundary: not constrained explicitly; cost visibility itself is an NFR (every loop iteration/reversal attributable in telemetry, reported by P8)

## Engineering Layer
- Stack: Markdown (skills, templates) / Node.js ≥20 `.mjs` (hooks, matching existing hook stack) / shell-based tests (existing `planifest-framework/tests/` conventions) / Build target: local, distributed via existing `setup.sh` bundling
- Components:
  - `planifest-framework` (component-pack, existing) — owns all new conventions, templates, skills, and hook
  - `structured-telemetry-mcp` (microservice, existing) — gains new event types
- Data ownership: `plan/backlog/` entries and `plan/current/` loop-state/run-log/defect-reports/revision-log → planifest-framework (orchestrator); `product.yml` → planifest-framework (ship-agent writes, orchestrator reads); telemetry DB → structured-telemetry-mcp
- Deployment: no deployment topology change — framework artifacts distributed via existing `setup.sh` copy mechanism
- API versioning: not applicable

## Scope
- In: `plan/backlog/` + pickup protocol; `product.yml`/`versionPolicy` + ship-agent/orchestrator updates; Phase→Wave terminology fix; fine-grained phase commits + feature-branch push cadence; loop-runner, design-critic, reversal-assessor, verify-by-execution skills; consistency-check script; ratchet hook; loop state/run-log/telemetry/toggles; cross-model review gate (pre-P7-archive placement)
- Out: any mechanism keeping `plan/current/` editable *after* P7 archive; the 7 bug-bounty-hunter-specific E2E regression tests from PR #4; standing patrol automations; harness-level `/goal`/`/loop` integration
- Deferred: `planifest-loop-designer` meta-skill; cross-vendor critique automation for P1/P2 artifacts — both after Wave 1 evidence. Also deferred: final confirmation of adoption mode/version/run mode/push-override wording (to implementation, per human instruction)

## Assumptions
- Existing req↔component↔test traceability is sufficient to compute invalidation cascades without new metadata - impact if wrong: reversal cascade computation needs new metadata, adding scope to Wave 1
- The telemetry backend's existing event-envelope pattern extends to loop events without schema redesign - impact if wrong: telemetry work grows beyond "add event types" into a schema migration
- This framework repo's own `component.yml`-only tagging path remains valid as the single-component fallback - impact if wrong: this repo's own P9 tagging breaks when product.yml logic is added

## Risks
- Scope breadth: 21 user stories across 2 waves in one feature-id risks losing coherence in a single pipeline run. Likelihood: medium. Impact: medium. Mitigation: each wave has its own independent "Ships When" gate; Wave 0 and Wave 1 can be built/reviewed as distinguishable units even though they share one design.md.
- Unproven loop value: design-critic and reversal-protocol machinery is comparatively heavy for value that hasn't been measured yet on real features. Likelihood: medium. Impact: medium. Mitigation: report-only/toggle-off rollout discipline; Wave 1's own "Ships When" gate requires measured precision before being considered done.
- Cross-model review mis-placement: an implementation that places the review gate after P7 (matching the original brief's "before P9" wording) would violate the ship-agent's existing Hard Limit against touching code post-archive. Likelihood: low (corrected in this design). Impact: high if regressed. Mitigation: explicit acceptance criterion checks placement is "before P7 archive."

## Dependencies
- Upstream: none blocking — this is foundational framework work
- Downstream: all future features gain `plan/backlog/`, `product.yml`, and (if Wave 1 ships) the loop skills

## Active Skills
None — no external capability skills are relevant to this framework/tooling feature.

## Skill Map
| Requirement (provisional — finalized at P1) | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| Backlog folder + P0 pickup | planifest-codegen-agent | New markdown convention + orchestrator SKILL.md control-flow change |
| product.yml + versionPolicy | planifest-codegen-agent | New template + ship-agent/orchestrator skill edits |
| Phase → Wave terminology fix | planifest-docs-agent | Terminology-only correction across templates/skills, no logic change |
| Loop skills (runner, critic, assessor, verify-by-execution) | planifest-codegen-agent | New skill files following the skills spec grammar |
| Ratchet hook | planifest-codegen-agent | New `.mjs` hook, same family as `gate-write.mjs` |
| Telemetry event types | planifest-codegen-agent | Extends existing telemetry-standards.md envelope |
| Fine-grained commits + push cadence | planifest-codegen-agent | Strengthens orchestrator Hard Limit 7 |

## Repo Instructions
### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. In some cases, you don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

The exception to the rule is that you can operate with git and GitHub commands if the human expressly asks you to. Report back if unsuccessful for any reason in these exceptional cases.

> Note: this feature's own fine-grained-commit/push-cadence requirement (US-007/008) may prompt an update to this override file to make feature-branch push standing rather than per-ask. That decision is deferred to implementation per human instruction.

## Confirmation
Human confirmed this design before proceeding: yes ("build this in continuous mode", 2026-07-11)
Date confirmed: 2026-07-11
Run mode: continuous (authorized 2026-07-11; human gates mandated by the brief — altering reversals, re-exit from P0, budget exhaustion, large cascades, destructive schema ops — still stop regardless)
