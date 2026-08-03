# Design - 0000024-declared-product-id-for-telemetry

## Feature
- Problem: `product_id` on telemetry events is a machine-local filesystem path instead of a declared identity, and agent-driven telemetry (12 of 14 event types) has been failing 100% of the time since `structured-telemetry-mcp` renamed the `emit_event` argument from `event` to `envelope` — a fix this repo diagnosed and handed off (0000017) but never verified or updated its own instructions for.
- Adoption mode: standard-iterative
- Version: 0.24.0 (confirmed — minor bump from 0.23.0, Feature Pipeline)
- Feature ID: 0000024-declared-product-id-for-telemetry
- Discovery: see `plan/current/discovery.md`

## Product Layer
- User stories:
  - US-001: As a telemetry consumer querying events across multiple projects on one shared backend, I want `product_id` sourced from a durable, human-declared identifier instead of a machine-local filesystem path, so that the same product is attributed consistently regardless of clone location or machine.
  - US-002: As a telemetry consumer, I want the 12 agent-driven event types the framework specifies to actually reach the backend, so that ADR decisions, security findings, deviations, and other quality signals are queryable instead of silently missing.
- Acceptance criteria confirmed: 7 (see `feature-brief.md`)
- Constraints: cannot modify `structured-telemetry-mcp` (separate repo); hooks are non-interactive fire-and-forget subprocesses (ADR-005) — cannot themselves prompt a human
- Integrations: `structured-telemetry-mcp` (`/emit` HTTP endpoint, `emit_event` MCP tool) — consumer only, no changes made there

## Architecture Layer
- Latency target: deferred — not applicable, no new user-facing latency surface
- Availability target: deferred — not applicable
- Scalability target: deferred — not applicable
- Security: no auth/authz surface change; no new data classification (product_id is a human-chosen non-sensitive string)
- Data privacy: no regulated data
- Observability: this feature *is* an observability fix — see Business Goal
- Cost boundary: not constrained

## Engineering Layer
- Stack: inherited (Node `.mjs` hooks, Markdown skills, bash regression tests) — no new stack choice
- Components: `planifest-framework` (existing) — owns the 3 telemetry hooks, `telemetry-standards.md`, and the orchestrator's own P0 logic
- Data ownership: `product.yml` (`id` field) owned by `planifest-framework`, read by the 3 hooks, orchestrator P0, and agent-driven `emit_event` callers
- Deployment: no deployment topology change — this ships as framework source, consumed by any project running `setup.sh`
- API versioning: not applicable

## Scope
- In: delete `getProductId()`/git-path fallback from all 3 hooks; hooks read `product.yml` id only, route failure to existing `recordTelemetryFailure()` marker (no fallback value, never blocks); orchestrator P0 step 3b hard-stops and prompts if `product.yml`/`id` absent or malformed; fix `telemetry-standards.md`'s `emit_event` argument documentation (`event`→`envelope`) and its `product_id` sourcing description; audit all 8 phase skills' Telemetry sections for the same stale-argument gap; new P2 ADR extending 0000016 ADR-002; live re-verification of at least one agent-driven event landing; regression tests for 4 hook cases (declared id, absent file, malformed YAML, missing id field — all non-path outcomes)
- Out: any change inside `structured-telemetry-mcp`; Root Cause B from the 0000017 RCA (missing `loop_iteration`/`phase_reversal_*` schema entries) unless found still broken during live re-verification, in which case file a fresh backlog entry rather than fix here; new event types; schema/query/backend changes; backfilling historical data
- Deferred: none identified — Scope Lock Challenge complete, no deferred items surfaced

## Assumptions
- `structured-telemetry-mcp`'s `emit_event` fix (real object schema, `envelope` argument) is stable/deployed, not transient — confirmed via live test this session (`{"ok":true,"id":"f1332a6e-..."}`) — impact if wrong: story 2's live re-verification step will fail and surface this immediately, no silent risk
- Every pipeline run has an orchestrator-led P0 phase, so a once-per-run hard-stop prompt is sufficient coverage — impact if wrong: a hook-only invocation with no prior P0 in that session would hit the failure-marker path instead of the prompt, which is the designed fallback, not a gap

## Risks
- Deleting the git-path fallback is a behavioural regression for any downstream Planifest-managed project that hasn't yet declared a `product.yml` `id` — their telemetry will silently stop resolving `product_id` (routed to failure markers) until they run a P0 or manually add `product.yml`. Likelihood: medium (affects every existing adopter without a declared id). Impact: low (ADR-005 non-blocking behaviour preserved; failure is surfaced via existing marker mechanism, not silent data loss — the marker records it)
- Audit of all 8 phase skills' Telemetry sections may surface more stale-argument references than anticipated, expanding story 2's actual file count. Likelihood: low (0000023 ADR-002 centralised telemetry docs specifically to avoid this). Impact: low (mechanical fix, same pattern per file)

## Dependencies
- Upstream: `structured-telemetry-mcp`'s `emit_event` fix (0000017 handoff) — already deployed, confirmed live this session
- Downstream: none — no other component or project depends on this feature's output at build time

## Active Skills
None — no capability skills relevant to this stack (Markdown + Node hooks + bash tests)

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| US-001 - declared product_id | planifest-codegen-agent | Implements hook rewrite + orchestrator P0 logic change via TDD inner loop |
| US-001 - ADR for product.yml extension | planifest-adr-agent | Records the extension to 0000016 ADR-002 |
| US-002 - envelope parameter fix | planifest-codegen-agent | Documentation fix (telemetry-standards.md) + skill audit, same component |
| US-002 - live re-verification | planifest-validate-agent | Confirms real event lands via `query_telemetry`, part of CI/validation gate |

## Repo Instructions

### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. In some cases, you don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

The exception to the rule is that you can operate with git and GitHub commands if the human expressly asks you to. Report back if unsuccessful for any reason in these exceptional cases.

### Commit Granularly, Continuously
Commit locally after every meaningful artifact write — do not batch changes waiting for a phase gate, an approval checkpoint, or task completion. A single requirement doc, ADR, TDD cycle, or config fix is a commit on its own; don't hold it pending a bigger, later commit. Uncommitted work in the working directory is unrecoverable progress — commit early and often so nothing sits unsaved.

### Prefer Subagent Decomposition for Longer Tasks
When a task within any phase is long-running or spans multiple independent units of work (multiple requirements, multiple files with no cross-references, multiple independent searches or reviews), look actively for ways to split it into multiple subagents dispatched in parallel rather than working through the units sequentially in one context. This is a standing instruction, not a per-run choice - default to decomposing before defaulting to sequential inline work. The orchestrator's Parallelism Rules and Agent Dispatch Template (and each phase skill's own dispatch checklist) define the mechanics; this override raises the bar for when decomposition is attempted in the first place. If a task genuinely cannot be split (shared mutable state, one unit depends on another's output, or it is too small to justify subagent overhead), state the reason rather than defaulting to sequential work silently.

### Shorthand: GUTD
**When the human sends "GUTD", treat it as shorthand for "git up to date": check out `main`, pull the latest, and check for any untracked files.**
(Full rule in `planifest-overrides/instructions/custom-003-git-up-to-date-shorthand.md` — not reproduced in full here as it is operational guidance unrelated to this feature's implementation.)

## Confirmation
Human confirmed this design before proceeding: yes // Date and Time confirmed: 03 Aug 2026 @ 12:23 AM BST
