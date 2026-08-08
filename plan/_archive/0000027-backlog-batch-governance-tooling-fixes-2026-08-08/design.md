# Design - 0000027-backlog-batch-governance-tooling-fixes

## Feature
- Problem: 8 confirmed governance/tooling gaps in the Planifest framework and its setup tooling — two setup-script bugs that can abort a clean install, two orchestrator-conduct gaps risking silent telemetry loss, one subagent-dispatch process fix, one historical-backlog backfill, one new P0 flow for framework-dependency updates, and one artifact-minimization fix plus its governing ADR.
- Adoption mode: standard-iterative
- Feature ID: 0000027-backlog-batch-governance-tooling-fixes
- Discovery: see `plan/current/discovery.md` (raw P0 findings — this document records confirmed decisions only)

## Product Layer
- User stories:
  - US-001 (0000043): As the human on the loop, I want phase_start/phase_end telemetry hooks wired into setup.sh/setup.ps1 alongside context-pressure.mjs, so that all hooks gated by the unified telemetry signal are actually registered.
  - US-002 (0000034): As a downstream adopter running setup.sh for Cline, I want the boot-file and skills-dir paths in cline.sh/cline.ps1 to stop colliding, so that `setup.sh cline` and `setup.sh all` complete on a fresh workspace.
  - US-003 (0000035): As a dispatched phase-agent subagent, I want explicit instruction to file an out-of-scope discovery to plan/backlog/ directly, so discoveries enter the Planifest backlog-pickup protocol instead of a host-tool side channel.
  - US-004 (0000044): As the orchestrator, I want a deterministic backstop checking plan/.telemetry-failures/ at every phase boundary and verifying agent-driven emit_event calls happened, so compliance doesn't rest on prose and memory.
  - US-005 (0000045): As the human on the loop, I want deferred items/tech debt from pre-0000025 recommendations.md files backfilled into plan/backlog/, so a backlog-only pickup pass surfaces them too.
  - US-006 (0000046): As the human on the loop, I want P0 to distinguish a planifest-framework/ dependency update from an arbitrary code push, requiring my confirmation of both the update and its provenance.
  - US-007 (0000024): As a framework maintainer, I want an ADR recording the "does this skill earn its place" test with the four TDD-loop skills as worked examples.
  - US-008 (0000021): As a framework maintainer, I want a minimal default Phase 1 artifact set with explicit trigger conditions for cost model/SLOs/ops model, reflected in feature-pipeline.md and planifest-spec-agent.
- Acceptance criteria confirmed: 8 (top-level, one per user story — see `feature-brief.md`; each will be broken into granular criteria at P1)
- Constraints: no new stack/service/infra; all changes modify existing planifest-framework/setup-hook-integration files in place; data-ownership boundaries in discovery.md (no shared writes between the two components) must hold
- Integrations: none new — existing setup.sh→hooks/telemetry/*.mjs contract is fixed, not changed

## Architecture Layer
- Latency target: N/A — no deployed runtime service
- Availability target: N/A — no deployed runtime service
- Scalability target: N/A — no deployed runtime service
- Security: no auth strategy applies (no runtime auth surface); data classification: none (no user/PII data, framework's own scripts/docs only)
- Data privacy: no regulated data
- Observability: standard defaults; this feature strengthens the framework's own telemetry observability (US-001, US-004) as in-scope work, not a separate NFR
- Cost boundary: not constrained (no infra)
- Feature-specific NFRs (see feature-brief.md): setup.sh cline/all exit 0 on a fresh workspace (regression test); phase_start/phase_end hooks registered and firing for 100% of phase transitions when the unified telemetry signal is active

## Engineering Layer
- Stack: Bash + Node.js (ESM) + Markdown; no DB/ORM/frontend/IaC/cloud/compute; testing via existing tests/test-*.sh convention; CI: GitHub Actions (.github/workflows/planifest.yml); Build target: local
- Components: `planifest-framework` (orchestrator skill, phase skills, ADRs, workflows, hook sources, migrations, planifest-spec-agent); `setup-hook-integration` (setup.sh/ps1, cline.sh/cline.ps1, hook wiring)
- Data ownership: N/A — no runtime data stores; artifacts are the framework's own files
- Deployment: N/A — no service deployment; changes ship via this repo and reach downstream adopters through their own `setup.sh`/framework-folder update mechanism (unchanged by this feature, except US-006 which adds explicit P0 handling for that mechanism)
- API versioning: not applicable

## Scope
- In: implement all 8 backlog items (0000043, 0000034, 0000035, 0000044, 0000045, 0000046, 0000024, 0000021) as this feature's requirements
- Out: backlog entries 0000040/0000041 referenced from 0000046 (not present in this repo's plan/backlog/, external to this run); retroactively rewriting archived recommendations.md beyond the one-time 0000045 backfill; remaining plan/backlog/ entries not in this batch (0000020, 0000022, 0000023, 0000025, 0000026, 0000042)
- Deferred: nothing newly deferred — each item's own "Why Deferred" is resolved by inclusion in this batch

## Assumptions
- 0000046's and 0000044's exact mechanisms are explicitly undecided in their backlog entries — impact if wrong: P2 ADRs may need a second pass if the first design choice doesn't hold up in P3/P4; mitigated by resolving both as ADRs before codegen
- Ops model/cost model/SLOs are N/A for this feature (judgment call per 0000021's own not-yet-shipped rule, confirmed with the human at P0) — impact if wrong: none, this feature has zero deployed runtime footprint regardless of which artifact-set rule governs it

## Risks
- 0000034's fix may not match Cline's actual expected directory layout — likelihood: medium, impact: low (caught by the regression test before merge)
- 0000046's scope (new agent vs. extending planifest-migrator) is explicitly undecided — likelihood: medium (scope growth during P2), impact: medium (could expand this item's footprint)
- 0000044's backstop mechanism (hook vs. lint-check vs. both) is explicitly undecided — likelihood: medium (scope growth during P2), impact: medium

## Dependencies
- Upstream: none — all 8 items are independent framework/setup-tooling fixes; no hard dependency order (suggested-only sequencing: 0000043/0000034 before 0000044, per feature-brief.md; 0000024/0000021 can run in parallel with any of the above)
- Downstream: downstream adopter projects that copy planifest-framework/ and run setup.sh benefit from these fixes on their next framework update; no adopter is blocked pending this feature

## Active Skills
None — skills-inbox empty, no capability skills installed for this run

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| 0000043 - wire telemetry hooks | planifest-codegen-agent | Standard shell-script wiring fix + regression test; no specialized skill needed |
| 0000034 - fix cline.sh collision | planifest-codegen-agent | Shell script bug fix + regression test, standard TDD inner loop |
| 0000035 - subagent backlog-filing instruction | planifest-codegen-agent | Edits to orchestrator dispatch template and phase-skill files — framework's own instruction content, not a docs/ living-state artifact |
| 0000044 - telemetry compliance backstop | planifest-codegen-agent | New hook script and/or gate-check logic, same pattern as existing enforcement hooks; ADR resolves the open mechanism choice first (P2) |
| 0000045 - backfill historical recommendations | planifest-codegen-agent | One-time migration script over plan/_archive/*/recommendations.md |
| 0000046 - P0 framework-update flow | planifest-codegen-agent | Edits orchestrator SKILL.md's P0 flow; P2 ADR first resolves new-agent-vs-extend-migrator question |
| 0000024 - skill-scope ADR | planifest-adr-agent | Directly produces an ADR — the item's entire deliverable |
| 0000021 - minimal artifact set | planifest-codegen-agent | Edits feature-pipeline.md and planifest-spec-agent skill content |

## Repo Instructions

### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. In some cases, you don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

The exception to the rule is that you can operate with git and GitHub commands if the human expressly asks you to. Report back if unsuccessful for any reason in these exceptional cases.

### Commit Granularly, Continuously
Commit locally after every meaningful artifact write — do not batch changes waiting for a phase gate, an approval checkpoint, or task completion. A single requirement doc, ADR, TDD cycle, or config fix is a commit on its own; don't hold it pending a bigger, later commit. Uncommitted work in the working directory is unrecoverable progress — commit early and often so nothing sits unsaved.

### Prefer Subagent Decomposition for Longer Tasks
When a task within any phase is long-running or spans multiple independent units of work (multiple requirements, multiple files with no cross-references, multiple independent searches or reviews), look actively for ways to split it into multiple subagents dispatched in parallel rather than working through the units sequentially in one context. This is a standing instruction, not a per-run choice - default to decomposing before defaulting to sequential inline work. The orchestrator's Parallelism Rules and Agent Dispatch Template (and each phase skill's own dispatch checklist) define the mechanics; this override raises the bar for when decomposition is attempted in the first place. If a task genuinely cannot be split (shared mutable state, one unit depends on another's output, or it is too small to justify subagent overhead), state the reason rather than defaulting to sequential work silently.

### Shorthand: GUTD
When the human sends "GUTD", treat it as shorthand for "git up to date": check out main, pull the latest, and check for any untracked files. (Full rule in `planifest-overrides/instructions/custom-003-git-up-to-date-shorthand.md` — not applicable mid-pipeline, recorded here for completeness only.)

## Confirmation
Human confirmed this design before proceeding: yes // Date and Time confirmed: 08 Aug 2026 @ 08:42 AM BST
