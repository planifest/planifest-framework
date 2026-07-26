# Design - 0000017-ratchet-forgery-detection-and-telemetry-schema-spec

## Feature
- Problem: A bundled backlog release closing five small governance/portability gaps in the Planifest framework itself, plus one framework-improvement item discovered mid-session: hardening the ratchet-approve mechanism against forgery, promoting 0000016's governance tests to the permanent regression pack, correcting Phase/Wave terminology drift, making enforcement hooks work without a Unix shell, formalizing the Scope Lock Challenge's suggested-answer behavior, and giving every adoption mode a structured, file-backed discovery pass at P0.
- Adoption mode: standard-iterative
- Feature ID: 0000017-ratchet-forgery-detection-and-telemetry-schema-spec

## Product Layer
- User stories:
  - US-001: As a maintainer running the regression suite, I see all governance assertions (ratchet/product-version/consistency-check) running as first-class regression tests, so that a future change can't silently regress governance behavior without a test catching it.
  - US-002: As a human approver, I can authorize a ratchet weakening in the moment by telling the agent to write `.ratchet-approve` with my reason, so that the approval is transcribed exactly and lands in its own commit before the weakening edit proceeds — and if I forget to commit it, the hook catches that before letting the edit through.
  - US-003: As anyone reading Planifest docs, I see "Phase" and "Wave" used correctly and consistently everywhere, so that the pipeline-phase sense (P0-P9) is never confused with the decomposition sense.
  - US-004: As a Windows user without Git Bash or WSL, enforcement hooks work identically to every other platform, so that I get the same protection regardless of what shell tooling I happen to have installed.
  - US-005: As a human being coached through a Scope Lock Challenge question, I'm always offered a suggested answer I can accept, edit, or reject — never one silently assumed on my behalf — so that I keep full control over scope decisions while still getting drafting help on request.
  - US-006: As a human starting P0 in any adoption mode, I see a structured discovery pass run before coaching begins, with its findings written to `discovery.md` — separate from the audit trail and the confirmed design — so that I can see exactly what the orchestrator already knows before it starts asking me questions.
  - US-007: As anyone reading this framework's documentation after a Change Pipeline run, I find `plan/current/` archived exactly like a Feature Pipeline run, with no stale links left behind, so the repo's `plan/` layout is always consistent and no agent infers archiving is optional.
- Acceptance criteria confirmed: 7 items, each mechanism-confirmed through full Scope Lock Challenge (happy/first-run/error/cross-session) for items 1-6; item 7 (req-007) picked up from backlog mid-P3 with diffs already drafted by the filing investigation — see `build-log.md` P0 exchange entries for the complete record.
- Constraints: Local Git Only (no remote git operations; commit to feature branch, human pushes/PRs) — `planifest-overrides/instructions/custom-001-local-git-only.md`. Commit granularly and continuously — same file.
- Integrations: `structured-telemetry-mcp` (sibling repo) — RCA and fix spec handed off there for backlog 0000005; human confirmed that work is complete and running. No further integration required in this release.

## Architecture Layer
- Latency target: not applicable — framework tooling, no runtime request path
- Availability target: not applicable
- Scalability target: not applicable
- Reliability (measurable NFR): 100% cross-platform hook parity (0000010) — enforcement behavior must be identical whether or not WSL/Git Bash is present; 87/87 promoted governance assertions passing with zero false positives (0000002 — count corrected from the P0 estimate of 97 at P3)
- Security: the ratchet-approve mechanism (US-002) is the security-relevant surface — governs who can authorize weakening a governance guardrail. No new auth/authz model; existing hook-based enforcement extended.
- Data privacy: no regulated data — this release touches only framework skills, hooks, docs, and test harness
- Observability: no new telemetry events required by this release; existing `phase_start`/`phase_end`/`adr_decision` emission unaffected
- Cost boundary: not constrained

## Engineering Layer
- Stack: bash → `.mjs` (Node) for hooks; Markdown for skills/templates/docs; shell scripts for the regression-pack promotion. No new external dependencies, no database, no IaC. Build target: n/a (framework tooling, not a deployed service).
- Components:
  - `scripts/promote-to-regression.sh` + regression suite membership — reclassifies 0000016's 87 governance assertions (0000002)
  - `.ratchet-approve` marker format + `ratchet-check.mjs` consumption logic + audit log — human-approval mechanism (0000008)
  - `planifest-framework/`, `docs/`, root `README.md` — Phase/Wave terminology sweep + report (0000009)
  - `block-bash.mjs`, `block-grep.mjs`, `block-webfetch.mjs` (replacing the `.sh` originals) + `setup.sh`/`setup.ps1` wiring + `src/context-mode-hooks/component.yml` — cross-platform hook execution (0000010)
  - `planifest-scope-lock-agent` (new skill) + `planifest-orchestrator` Scope Lock Challenge section — suggested-answers mechanism (item 5)
  - `planifest-orchestrator` Adoption Modes section (all 4 modes) + `design.template.md` + `plan/current/discovery.md` lifecycle (created fresh each P0, archived at P7) — structured discovery pass (item 6)
  - `planifest-change-agent` (new Phase 6 - Archive step) + `planifest-ship-agent` (P7 Step 6 cross-reference check) + `planifest-orchestrator` (10th Hard Limit) — change-agent archive step (item 7, picked up from backlog 0000011)
- Data ownership: not applicable — no data model
- Deployment: not applicable — framework tooling distributed via `setup.sh`/`setup.ps1` to consuming projects
- API versioning: not applicable
- Dependency order: none of the 6 items depend on each other's implementation — all independently buildable/committable in any order. Not phased; single pipeline run.

## Scope
- In: 0000002 (regression suite promotion), 0000008 (ratchet marker human-approval mechanism, final design), 0000009 (Phase/Wave terminology sweep + report), 0000010 (cross-platform `.mjs` hook ports), Scope Lock suggested-answers requirement (`planifest-scope-lock-agent`), structured P0 discovery pass + `discovery.md` for all 4 adoption modes, 0000011 (change-agent Phase 6 - Archive step + ship-agent cross-reference check + 10th Hard Limit)
- Out: `setup.sh` itself remaining bash-only (one-time install step, explicitly out of scope for 0000010); any change to `structured-telemetry-mcp` internals (separate repo, separate pipeline run)
- Deferred: 0000005 (telemetry schema gaps) — cross-repo, RCA and fix spec handed off to `structured-telemetry-mcp/plan/current/emit-event-rca-and-fix-spec.md`; human has confirmed that work is complete and running, so this item requires no further action in this repo

## Assumptions
- `plan/current/discovery.md`'s Retrofit-mode content (the only mode with a pre-existing structured spec) generalizes cleanly to the other 3 modes without needing new discovery activity beyond what each mode's P0 already gathers today - impact if wrong: Greenfield/Standard Iterative/External Anchor discovery sections may need real new scanning logic, not just relocation, expanding item 6's implementation size
- The same-uncommitted-changeset backstop for `.ratchet-approve` can be extended with an explicit human-facing message without changing its detection logic - impact if wrong: 0000008's message-surfacing requirement may need a larger hook rewrite than expected

## Risks
- Item 6 (structured discovery pass) grew mid-session from a Retrofit-only file relocation to a 4-mode requirement — likelihood: realized (already happened); impact: larger P1/P3 scope than the original 5-item release; mitigate by sizing it as its own requirement at P1, not folding into 0000009's or 0000010's estimate
- `.ratchet-approve` mechanism (0000008) reverses ADR-004's original design mid-session (hard block → agent-may-write-on-instruction) — likelihood: low further reversal risk (rigor-checked and reconfirmed twice); impact if wrong: forgery-detection gap in the ratchet system, high severity — ADR amendment at P2 must be explicit about superseding ADR-004
- Bundled 6-item release increases coordination surface — likelihood: medium; impact: a partial implementation failure in one item could block archiving the whole release; mitigate by keeping each item's commits independently revertible (already established convention: dedicated commits per artifact)

## Dependencies
- Upstream: none blocking — `structured-telemetry-mcp` handoff (0000005) confirmed complete by human, informational only
- Downstream: none — this release does not change any public interface consumed by other repos

## Active Skills
None — no external capability-skill intake this session. `planifest-scope-lock-agent` is a new first-party Planifest skill authored as part of this release's own scope (item 5), not an externally-sourced capability skill.

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| REQ-001 - regression-suite-promotion (0000002) | planifest-codegen-agent | Mechanical script run + regression-suite membership change; tests already exist, no new authoring |
| REQ-002 - ratchet-marker-approval-mechanism (0000008) | planifest-codegen-agent | Implements hook consumption/audit-log logic; `planifest-adr-agent` separately handles the ADR-004-superseding ADR at P2 |
| REQ-003 - phase-wave-terminology-sweep (0000009) | planifest-docs-agent | Documentation correction + audit report across docs/, planifest-framework/, README.md |
| REQ-004 - cross-platform-hook-ports (0000010) | planifest-codegen-agent | Ports 3 shell hooks to `.mjs`, updates setup.sh/setup.ps1 wiring and component.yml quirks |
| REQ-005 - scope-lock-suggested-answers | planifest-codegen-agent | Authors the new `planifest-scope-lock-agent` skill file and the orchestrator's Scope Lock Challenge section updates |
| REQ-006 - structured-p0-discovery-pass | planifest-codegen-agent | Rewrites the orchestrator's Adoption Modes section (all 4 modes) and `design.template.md`/build-log wiring for `discovery.md`'s create-at-P0/archive-at-P7 lifecycle |
| REQ-007 - change-agent-archive-step | planifest-codegen-agent | Applies the two pre-drafted diffs (change-agent Phase 6, ship-agent P7 cross-reference check) plus a new orchestrator Hard Limit |

Final REQ-NNN numbering will be assigned by the spec-agent at P1; this table uses placeholder ordering matching the 7 scope items above.

## Repo Instructions
### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. In some cases, you don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

The exception to the rule is that you can operate with git and GitHub commands if the human expressly asks you to. Report back if unsuccessful for any reason in these exceptional cases.

### Commit Granularly, Continuously
Commit locally after every meaningful artifact write — do not batch changes waiting for a phase gate, an approval checkpoint, or task completion. A single requirement doc, ADR, TDD cycle, or config fix is a commit on its own; don't hold it pending a bigger, later commit. Uncommitted work in the working directory is unrecoverable progress — commit early and often so nothing sits unsaved.

## Confirmation
Human confirmed this design before proceeding: yes
Date confirmed: 25 Jul 2026
