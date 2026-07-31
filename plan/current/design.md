# Design - 0000019-self-description-and-session-hygiene-fixes

## Feature
- Problem: The framework's own self-description has drifted from reality (wrong README counts/paths, a component.json/component.yml mismatch that falsely rejects valid changes, an overclaimed CI parity guarantee, an unfalsifiable Hard Limit) and several orchestrator/session-hygiene gaps went unaddressed (no timestamp disambiguation on design confirmations, no context-window hygiene at phase boundaries, no documented backlog ID convention). A framework whose own specification is inaccurate undercuts adoption; the session-hygiene gaps degrade agent behaviour on long runs.
- Adoption mode: standard-iterative
- Feature ID: 0000019-self-description-and-session-hygiene-fixes
- Version: `0.18.0` → `0.19.0` (minor bump — Feature Pipeline default; last known version from `docs/about.md`)
- Discovery: see `plan/current/discovery.md`

## Product Layer
- User stories:
  - US-001: As a framework maintainer, I want the README's counts, paths, and claims to match the actual repository, so that a new reader's first thirty seconds of trust isn't undermined by easily-checked errors.
  - US-002: As a repo adopter, I want the shipped `pre-push`/`pre-commit` hooks to match against `component.yml` (the real manifest name), so that a correct change to `src/` plus its manifest isn't falsely rejected.
  - US-003: As a human running a pipeline session, I want design confirmations timestamped and context-window hygiene applied at phase boundaries, so that same-day version iterations are disambiguated and long sessions don't degrade on stale context.
  - US-004: As an agent filing a backlog entry, I want the ID-sequence convention documented where I'll actually meet it, so that I don't have to reverse-engineer or accidentally corrupt the sequence.
- Acceptance criteria confirmed: 9 (one per item below; each item's own backlog entry `## Suggested Action` is the acceptance criterion, confirmed as-is with the human)
- Constraints: local-git-only for routine work (`planifest-overrides/instructions/custom-001-local-git-only.md`), remote git ops (fetch/push/PR) permitted this run only by explicit human grant
- Integrations: none — self-contained framework-repo maintenance

## Architecture Layer
- Latency target: deferred - not applicable, no runtime service
- Availability target: deferred - not applicable, no runtime service
- Scalability target: deferred - not applicable, no runtime service
- Security: no new auth/authz surface; 0000015 tightens (not loosens) an enforcement hook; no regulated data touched
- Data privacy: no regulated data — framework-authoring artifacts only
- Observability: this run's own telemetry is the observability surface in question (0000027, already fixed and verified in P0); standard build-log/discovery audit trail otherwise
- Cost boundary: not constrained

## Engineering Layer
- Stack: N/A — framework tooling (Markdown, YAML, bash, Node). No frontend/backend/database/ORM/IaC/cloud/compute layer applies; Build target: none.
- Components (single wave, no sub-waves — human directive):
  - 0000014: `README.md` — remove Count column, fix `feature-structure.md`/`docs/` paths, align setup/-row and line 42
  - 0000015: `.github/workflows/planifest.yml`, `planifest-framework/hooks/planifest.yml`, `hooks/pre-push`, `hooks/pre-commit` — `component.json` → `component.yml`, plus two new tests
  - 0000016: same CI/hook files as 0000015 — reword parity-check messaging and README Hard Limits/Limitations
  - 0000017: `README.md:109` — reword Hard Limit 1; align orchestrator wording
  - 0000018: new repository-scoped CI script (path TBD by spec-agent) — verifies structure-diagram paths and folder-table coverage; depends on 0000014 landing first
  - 0000011: `.claude/skills/planifest-orchestrator/SKILL.md` — add local timestamp + `//` delimiter to confirmation format
  - 0000012: `.claude/skills/planifest-orchestrator/SKILL.md` — Phase 0 start `/clear` trigger (or human prompt fallback), dynamic compaction monitoring, P9 completion `/clear` trigger
  - 0000026: `planifest-framework/templates/backlog-entry.template.md`, orchestrator P0 backlog-pickup step — document the backlog ID sequence convention
  - 0000027: **already implemented and committed in P0** — `planifest-framework/hooks/telemetry/context-pressure.mjs` `phase: "monitoring"` → `phase: "orchestrator"`, verified 400→200 against the running backend
- Data ownership: not applicable — no data-owning components
- Deployment: not applicable
- API versioning: not applicable

## Scope
- In: 0000011, 0000012, 0000014, 0000015, 0000016, 0000017, 0000018, 0000026, 0000027 (0000027 pre-implemented in P0)
- Out: 0000013 (setup refresh skill) — explicitly deferred to next release, not discarded
- Deferred: 0000019 (populate regression pack), 0000020 (decompose orchestrator skill — depends on 0000019), 0000021 (minimal artifact set — needs human judgement call), 0000022/0000023 (token accounting / baseline comparison — sequenced pair, needs 0000021 first), 0000024 (skill-scope ADR — low severity, strategic), 0000025 (adoption position — needs human positioning decision). None of these are blocked by this batch; all remain in `plan/backlog/` untouched.

## Assumptions
- The `component\.json` regex in the shipped hooks is over-strict (false rejection), not an enforcement hole — impact if wrong: 0000015's fix could open a real gap; mitigated by the two new pass/fail tests specified in the backlog entry, run against the shipped `hooks/` files directly, not just the workflow.
- `docs/about.md` version `0.18.0` is the correct baseline for this run's bump — impact if wrong: version-ordering hard block would catch a stale baseline before it's recorded.
- Mapping `context-pressure`'s telemetry event to `phase: "orchestrator"` (0000027) is semantically correct rather than merely schema-legal — impact if wrong: a future telemetry consumer misattributes context-pressure events to orchestrator-phase work; low impact, easily correctable in a later pass.

## Risks
- Likelihood low / impact low: 0000015's regex fix is touched by both this batch and could theoretically collide with an in-flight consumer repo's hook version — mitigated by this being a framework-source fix consumers pull via `setup.sh` on their own schedule.
- Likelihood low / impact medium: 0000012's `/clear`-at-phase-boundary logic is behavioural, not just textual — if implemented incorrectly it could disrupt session continuity for other in-flight orchestrator sessions. Mitigated by P4 validation and explicit test coverage.
- Likelihood low / impact low: single-wave execution (human-directed, overriding the initial multi-wave recommendation) means all 9 items load into P3 codegen context at once rather than in smaller batches — mitigated by the items being individually small and mostly file-disjoint.

## Dependencies
- Upstream: none
- Downstream: 0000018 depends on 0000014 landing first (sequenced within the single wave, not a separate wave)

## Active Skills
None

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| 0000014 - readme-accuracy | planifest-docs-agent | README structure/content correction is a documentation artifact |
| 0000015 - component-yml-matcher | planifest-codegen-agent | Hook/CI regex fix plus new tests is implementation work |
| 0000016 - honest-parity-wording | planifest-docs-agent | Wording-only change to messages and README |
| 0000017 - reword-hard-limit-1 | planifest-docs-agent | Wording-only change to README and orchestrator skill |
| 0000018 - self-description-ci-check | planifest-codegen-agent | New script + CI wiring is implementation work |
| 0000011 - confirmation-timestamp | planifest-codegen-agent | Format change to orchestrator skill logic |
| 0000012 - context-clear-compaction | planifest-codegen-agent | New behavioural logic in orchestrator skill |
| 0000026 - backlog-id-convention-docs | planifest-docs-agent | Documentation-only addition to template and skill |
| 0000027 - context-pressure-phase-fix | planifest-codegen-agent | Already implemented directly in P0 (one-line hook fix); no further dispatch needed |

## Repo Instructions
### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. In some cases, you don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

The exception to the rule is that you can operate with git and GitHub commands if the human expressly asks you to. Report back if unsuccessful for any reason in these exceptional cases.

**This run:** human has expressly granted fetch/push/PR-creation permission for this session (used already to verify `main` was up to date via `git fetch`). Standing rule otherwise unchanged — routine work stays local-only.

### Commit Granularly, Continuously
Commit locally after every meaningful artifact write — do not batch changes waiting for a phase gate, an approval checkpoint, or task completion. A single requirement doc, ADR, TDD cycle, or config fix is a commit on its own; don't hold it pending a bigger, later commit. Uncommitted work in the working directory is unrecoverable progress — commit early and often so nothing sits unsaved.

## Confirmation
Human confirmed this design before proceeding: yes // Date and Time confirmed: 31 Jul 2026 @ 10:13 PM BST
