# Design - 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes

## Feature
- Problem: Seven small, independently-discovered defects in the Planifest pipeline's own tooling (ship-agent output correctness, phase-skill gates ignoring session run-mode, subagent dispatch parallelism, setup config durability, and deferred-item discoverability) accumulate operator friction and silent-correctness risk across every future pipeline run until fixed.
- Adoption mode: standard-iterative
- Version: 0.25.0 (confirmed — minor bump from 0.24.0, Feature Pipeline)
- Feature ID: 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
- Discovery: see `plan/current/discovery.md`

## Product Layer
- User stories:
  - US-001: As a human on the loop, I want the ship-agent's PR description template to omit the AI-attribution footer by default, so that I don't have to manually strip it from every PR.
  - US-002: As a human on the loop, I want the P7 archive commit's `git add` to explicitly name `plan/current/`, so that the archive commit doesn't silently depend on git's rename-detection heuristic.
  - US-003: As a human on the loop, I want independent, non-cross-referencing writes across all pipeline phases (not just P1/P3) dispatched in parallel subagents, so that pipeline wall-clock time drops without changing output quality.
  - US-004: As a human on the loop, I want the active setup flags/backend-url to live in a versioned `planifest-overrides/setup-config/` file, so that setup configuration is tracked and survives like the rest of overrides.
  - US-005: As a human on the loop, I want `recommendations.md`'s Deferred Items and Tech Debt tables routed into `plan/backlog/` tagged by source, so that deferred work is centrally discoverable.
  - US-006: As a human on the loop, I want `planifest-docs-agent`'s P6 Gate B (and any phase skill with the same pattern) to check `continuous_run` before stopping for confirmation, so that a continuous-run session isn't interrupted by redundant prompts.
  - US-007: As a human on the loop, I want the Scope Lock Challenge to default to drafting all four scenario-path answers up front and presenting them in one batch, so that I do one accept/edit/reject pass instead of four sequential round-trips.
- Acceptance criteria confirmed: 7 (see `feature-brief.md`)
- Constraints: Local Git Only unless explicitly overridden; Commit Granularly, Continuously; Prefer Subagent Decomposition
- Integrations: none — all changes internal to `planifest-framework`

## Architecture Layer
- Latency target: not applicable (pipeline tooling, not a runtime service)
- Availability target: not applicable
- Scalability target: not applicable
- Pipeline efficiency target (US-003): 100% of phase batches with 2+ independent, non-cross-referencing writes dispatch in parallel, not sequentially — measured via the `Parallel task batches` field already tracked per phase in `build-log.md`
- Security: no new attack surface — all changes to trusted, human-reviewed skill/script files in this repo; no auth/authz surface
- Data privacy: no regulated data
- Observability: unchanged — existing telemetry-standards.md conventions apply to any new agent-driven events these fixes touch
- Cost boundary: not constrained

## Engineering Layer
- Stack: inherited (Markdown skills/standards, Node `.mjs` hooks/scripts, Bash setup scripts and regression tests) — no new stack choice
- Components: `planifest-framework` (existing) — owns all seven stories' files (skills, standards, setup scripts)
- Data ownership: not applicable — no data stores touched
- Deployment: no deployment topology change — ships as framework source, consumed by any project running `setup.sh`/`setup.ps1`
- API versioning: not applicable

## Scope
- In: see `feature-brief.md` Scope Boundaries → In Scope (ship-agent PR footer + P7 git-add fix; parallelism expansion beyond P1/P3; `planifest-overrides/setup-config/` relocation; backlog-routing for deferred items; docs-agent Gate B `continuous_run` check + audit of other phase skills; Scope Lock default-drafted/batch-presented answers with a new superseding ADR)
- Out: `structured-telemetry-mcp` or other external MCP changes; new capability skills/components; the 12 backlog items reviewed and left at P0; retroactive rewriting of already-archived `recommendations.md` files
- Deferred: PR-footer toggle mechanism (hardcoded removal vs. `planifest-overrides/instructions/`-gated) — left for P1/P2 to decide with the human

## Assumptions
- The two downstream-filed backlog entries (0000040, 0000041) reflect real friction in a genuine Planifest deployment - impact if wrong: low, since both are independently corroborated by this repo's own history (0000029 filed by feature 0000016) and by direct human confirmation at P0

## Risks
- Bundling 7 stories in one pipeline run exceeds the framework's own "≤3 stories" decomposition rule of thumb. Likelihood: n/a (accepted risk). Impact: low — all stories are small, same-component, low-risk; human explicitly confirmed proceeding as one run at P0 rather than splitting into waves
- US-007 reverses `0000017-ADR-003` and touches the edge of `0000014-ADR-008`'s one-question-at-a-time convention. Likelihood: medium (scope creep into unrelated framework conventions if not carefully bounded). Impact: low — P2 ADR will scope the change narrowly to the Scope Lock Challenge only, per discovery.md's constraining-ADR note

## Dependencies
- Upstream: none
- Downstream: none — no other component or project depends on this feature's output at build time

## Active Skills
None — no capability skills relevant to this stack (Markdown + Node hooks + Bash scripts)

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| US-001 - ship-agent PR footer removal | planifest-codegen-agent | Skill-file template edit (`planifest-ship-agent/SKILL.md`), same TDD-adjacent implementation flow as other framework fixes |
| US-002 - ship-agent P7 git-add fix | planifest-codegen-agent | Same file family as US-001, mechanical correctness fix |
| US-003 - subagent parallelism expansion | planifest-codegen-agent | Edits orchestrator dispatch guidance and relevant phase skills' checklists |
| US-004 - setup config relocation | planifest-codegen-agent | Setup script (`setup.sh`/`setup.ps1`) and tool-adapter changes |
| US-005 - backlog unification | planifest-codegen-agent | Edits `recommendations.md` template / docs-agent behavior |
| US-006 - docs-agent continuous_run respect | planifest-codegen-agent | Edits `planifest-docs-agent/SKILL.md` Gate B plus audited phase skills |
| US-007 - Scope Lock default-drafted, batch-presented | planifest-codegen-agent | Implements orchestrator protocol change |
| US-007 - new ADR superseding 0000017-ADR-003 | planifest-adr-agent | Records the Scope Lock default-behavior change, scoped against 0000014-ADR-008 |
| All stories - CI validation | planifest-validate-agent | Runs regression tests / lint across all seven fixes |

## Repo Instructions

### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. In some cases, you don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

The exception to the rule is that you can operate with git and GitHub commands if the human expressly asks you to. Report back if unsuccessful for any reason in these exceptional cases.

**This session's override:** human explicitly authorized pushing the feature branch after each phase-gate commit and opening the PR directly at P9 via `gh pr create` (recorded in `plan/current/build-log.md`, P0 phase block). One-time per-session grant, not a standing change to this instruction.

### Commit Granularly, Continuously
Commit locally after every meaningful artifact write — do not batch changes waiting for a phase gate, an approval checkpoint, or task completion. A single requirement doc, ADR, TDD cycle, or config fix is a commit on its own; don't hold it pending a bigger, later commit. Uncommitted work in the working directory is unrecoverable progress — commit early and often so nothing sits unsaved.

### Prefer Subagent Decomposition for Longer Tasks
When a task within any phase is long-running or spans multiple independent units of work (multiple requirements, multiple files with no cross-references, multiple independent searches or reviews), look actively for ways to split it into multiple subagents dispatched in parallel rather than working through the units sequentially in one context. This is a standing instruction, not a per-run choice - default to decomposing before defaulting to sequential inline work. The orchestrator's Parallelism Rules and Agent Dispatch Template (and each phase skill's own dispatch checklist) define the mechanics; this override raises the bar for when decomposition is attempted in the first place. If a task genuinely cannot be split (shared mutable state, one unit depends on another's output, or it is too small to justify subagent overhead), state the reason rather than defaulting to sequential work silently.

**Directly relevant to US-003** — this feature's own codegen pass should apply the parallelism pattern being fixed, per the Phase Conventions' Subagent Decomposition Directive.

### Shorthand: GUTD
When the human sends "GUTD", check out `main`, pull the latest, and check for any untracked files. (Full rule in `planifest-overrides/instructions/custom-003-git-up-to-date-shorthand.md` — not reproduced in full here as it is operational guidance unrelated to this feature's implementation.)

## Confirmation
Human confirmed this design before proceeding: yes // Date and Time confirmed: 03 Aug 2026 @ 02:10 AM BST
