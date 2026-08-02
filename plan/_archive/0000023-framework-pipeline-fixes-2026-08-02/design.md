# Design - 0000023-framework-pipeline-fixes

## Feature
- Problem: Five small, independently-filed defects have accumulated in the framework's own pipeline tooling — a continuous_run regression forcing three unwanted stops at P1-P3, a session-marker commit-lifecycle gap at both creation and deletion, a setup.sh crash on the Copilot target, and an unpopulated telemetry envelope field.
- Adoption mode: standard-iterative
- Feature ID: 0000023-framework-pipeline-fixes
- Version: 0.23.0 (minor bump from 0.22.0, Feature Pipeline track)
- Discovery: see `plan/current/discovery.md`

## Component Paths
- `planifest-framework/skills/planifest-orchestrator/SKILL.md`
- `planifest-framework/skills/planifest-ship-agent/`
- `planifest-framework/setup/copilot.sh`
- `planifest-framework/setup/copilot.ps1`
- `planifest-framework/hooks/telemetry/`
- `planifest-framework/standards/telemetry-standards.md`
- `planifest-framework/tests/`
- `planifest-framework/component.yml`
- `planifest-framework/adr/`

## Product Layer
- User stories:
  - US-001: As a human on the loop running continuous mode, I want P1-P3 to skip the confirmation stop the same way P4-P6 already do, so that continuous_run behaves as previously verified (0000019, 0000020).
  - US-002: As a human on the loop, I want session markers committed at creation and reliably removed at archive time, so that a lost working tree or rushed PR never strands stale sentinel state on `main`.
  - US-003: As a human running `setup.sh copilot`, I want the command to exit 0, so that Copilot tool setup actually works.
  - US-004: As anyone consuming telemetry data across multiple projects sharing one backend — a human via the log-viewer UI, an API caller, or an agent querying via MCP tools — I want every emitted event to carry `product_id`, so that events attribute to the right repo regardless of how they're consumed.
- Acceptance criteria confirmed: 6 (see `feature-brief.md`)
- Constraints: no schema change needed for `product_id` (already optional in `structured-telemetry-mcp`'s schema); `.github/hooks/planifest.json` command paths must move in lockstep with `TOOL_HOOK_ADAPTER_DEST`
- Integrations: `structured-telemetry-mcp` backend (existing, unchanged contract — additive field only)

## Architecture Layer
- Latency target: telemetry emission adds no latency beyond the existing 3s fetch-abort budget (git rev-parse is local, synchronous, sub-millisecond)
- Availability target: deferred - recorded in scope (not applicable, no runtime service)
- Scalability target: deferred - recorded in scope (not applicable)
- Security: no auth/authz surface changed; no new data classification introduced
- Data privacy: no regulated data; `product_id` is a repo path, not PII
- Observability: this feature *is* an observability fix (telemetry envelope completeness)
- Cost boundary: not constrained

## Engineering Layer
- Stack: Bash (setup scripts) / Node.js `.mjs` (hooks) / Markdown (skills, ADRs); no frontend, no database, no ORM, no IaC, no cloud, no compute; CI: existing GitHub Actions; Build target: local
- Components: `planifest-framework` (component-pack, existing) — sole component touched
- Data ownership: no new datasets; session markers already covered by `gate-write.mjs`'s always-permitted-files list
- Deployment: no deployment topology change (framework is installed via `setup.sh`/`setup.ps1` into consuming repos, unchanged by this feature)
- API versioning: not applicable

## Scope
- In: continuous_run restoration for P1-P3 (with ADR); marker commit-lifecycle fix (creation + deletion, both ends); copilot.sh/.ps1 self-copy fix + regression test; telemetry `product_id` emission across 3 hooks + envelope template + regression test
- Out: the other 7 open backlog entries (0000020-0000026, 0000029); general setup.sh/.ps1 refactor beyond the copilot DEST fix; hook wiring for tools other than Copilot; `product_id` backfill on historical rows; any `structured-telemetry-mcp` schema/DB/UI change
- Deferred: live `pwsh` verification of the `copilot.ps1` fix — no PowerShell runtime available in this environment; verified statically only, blocked until a Windows/pwsh environment is available

## Assumptions
- `planifest-framework/skills/` is the canonical source and `.claude/skills/` is a synced build artifact (confirmed stale mid-session) - impact if wrong: edits would need to also target `.claude/skills/` directly, and the live orchestrator behavior in *this very session* would not reflect the fix until a skill-sync/setup re-run
- No live `pwsh` runtime available in this environment - impact if wrong: the `copilot.ps1` fix would need re-verification if it turns out a runtime was available and untested

## Risks
- Editing `planifest-orchestrator/SKILL.md`'s gate wording while a pipeline is actively running under continuous_run — likelihood: low, impact: medium (mitigated: this run itself is not re-reading the modified STOP wording mid-flight; the fix takes effect for future runs and is validated via the build-log P0 exchange record showing intended behavior for this run instead)
- `copilot.ps1` fix unverified live (no pwsh) — likelihood: medium, impact: low (static review + structural parity with working `.sh`/other-tool `.ps1` pairs; regression coverage limited to bash)

## Dependencies
- Upstream: none
- Downstream: `.claude/skills/` (this project's own installed copy) will need a skill-sync/setup re-run to pick up the SKILL.md fix — out of scope to trigger here, noted as a recommendation at P6

## Active Skills
None

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| REQ-001 - restore continuous_run P1-P3 | planifest-adr-agent (P2), direct SKILL.md edit (P3) | Prose/config fix to the orchestrator's own gate logic; ADR records the decision and root cause |
| REQ-002 - marker commit-lifecycle | direct SKILL.md edit (ship-agent + orchestrator sections) | Prose/protocol fix, no code component |
| REQ-003 - copilot.sh/.ps1 self-copy fix | direct script edit + Bash regression test | Mechanical script fix with existing regression-test convention |
| REQ-004 - telemetry product_id emission | direct `.mjs` hook edit + regression test | Small, additive, well-specified in the source backlog handoff report |

## Repo Instructions
### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. In some cases, you don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

The exception to the rule is that you can operate with git and GitHub commands if the human expressly asks you to. Report back if unsuccessful for any reason in these exceptional cases.

### Commit Granularly, Continuously
Commit locally after every meaningful artifact write — do not batch changes waiting for a phase gate, an approval checkpoint, or task completion. A single requirement doc, ADR, TDD cycle, or config fix is a commit on its own; don't hold it pending a bigger, later commit. Uncommitted work in the working directory is unrecoverable progress — commit early and often so nothing sits unsaved.

### Prefer Subagent Decomposition for Longer Tasks
When a task within any phase is long-running or spans multiple independent units of work (multiple requirements, multiple files with no cross-references, multiple independent searches or reviews), look actively for ways to split it into multiple subagents dispatched in parallel rather than working through the units sequentially in one context. This is a standing instruction, not a per-run choice - default to decomposing before defaulting to sequential inline work. If a task genuinely cannot be split (shared mutable state, one unit depends on another's output, or it is too small to justify subagent overhead), state the reason rather than defaulting to sequential work silently.

## Confirmation
Human confirmed this design before proceeding: yes // Date and Time confirmed: 02 Aug 2026 @ 08:13 PM BST
