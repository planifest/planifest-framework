# Design - 0000018-telemetry-emission-consistency

## Feature
- Problem: Planifest pipeline runs do not reliably emit telemetry, even when explicitly enabled — emission is soft-gated in agent instructions ("skip silently if unavailable") with zero enforcement, so an agent can complete an entire P0-P9 run without emitting a single event and nothing surfaces that fact. This defeats the purpose of enabling telemetry at all.
- Adoption mode: standard-iterative
- Feature ID: 0000018-telemetry-emission-consistency
- Discovery: see `plan/current/discovery.md` (raw P0 findings — do not embed them here; this document records confirmed decisions only)

## Product Layer
- User stories:
  - US-001: As a human running a Planifest pipeline with telemetry enabled, I see every event the phase skills specify actually emitted during the run, so that the collected data reflects real pipeline behavior, not whatever an agent happened to remember.
  - US-002: As a human running a pipeline, when telemetry emission fails or the tool is unavailable, I am told exactly what failed and asked explicitly whether to proceed without telemetry or block until it's resolved, so that the pipeline never silently chooses either path on my behalf.
  - US-003: As a human running P0 in any adoption mode, I can trust that discovery.md was actually created and populated before coaching began, because a missing or incomplete one is a pipeline error the orchestrator stops on — not a silently-skipped step I have to notice myself.
- Acceptance criteria confirmed: 9 (AC1-AC8 for US-001/US-002; AC9 for US-003 — see build-log.md P0 exchange entries for the full derivation)
- AC9: discovery.md's existence and completeness for the confirmed adoption mode is elevated to Hard Limit status in `planifest-orchestrator/SKILL.md` (matching build-log.md's Hard Limit 8 pattern: stated in the Hard Limits list, referenced back at the Phase 0 Start Actions step where it happens, and added to the Phase 0 → Phase 1 Gate Checklist as a redundant catch) — not merely a numbered sub-step with no enforcement teeth.
- Constraints: ADR-005 (0000003, exit-zero failure mode) — hook-driven emission must never exit non-zero or block the session, even on failure. ADR-002 (0000007, telemetry guidance centralised) — envelope/event documentation lives in `telemetry-standards.md`; skill files reference it, they don't duplicate it.
- Integrations: `structured-telemetry-mcp` (sibling repo) — `emit_event` and `query_telemetry` both verified functional this session (live test calls, write→read confirmed end to end for the correct event type). No changes needed there for this feature.

## Architecture Layer
- Latency target: not applicable — framework tooling, no runtime request path
- Availability target: not applicable
- Scalability target: not applicable
- Security: no new auth/authz surface. Data classification: telemetry events carry operational metadata only (phase names, timestamps, model/agent/tool identifiers, durations, error strings) — no PII, no credentials, no regulated data.
- Data privacy: no regulated data
- Observability: this feature IS the observability-reliability mechanism — see Product Layer
- Cost boundary: not constrained

## Engineering Layer
- Stack: unchanged from prior releases — Markdown skill/template edits, Node `.mjs` hook scripts, bash (`setup.sh`) + PowerShell (`setup.ps1`). No new stack choice, no new dependencies.
- Components:
  - `planifest-framework/setup.sh` + `setup.ps1` — remove the `--context-mode-mcp` coupling from telemetry hook installation; `--structured-telemetry-mcp` alone becomes sufficient to wire the hooks
  - `planifest-framework/hooks/telemetry/{emit-phase-start,emit-phase-end,context-pressure}.mjs` — on emission failure, write a durable failure marker instead of pure-silent-swallow (ADR-005's exit-zero/never-block property unchanged)
  - `planifest-framework/skills/planifest-orchestrator/SKILL.md` — check the failure marker at each phase-start checkpoint; surface the block-or-proceed question once per distinct root cause per run; record the human's answer in build-log.md and honor it for the rest of the run
  - All 8 phase skills' Telemetry sections (orchestrator, spec-agent, adr-agent, codegen-agent, validate-agent, security-agent, docs-agent, ship-agent) — rewritten so agent-driven emission failure is immediately interactive (stop, exact error, block-or-proceed), not soft-skip
  - `planifest-framework/templates/build-log.template.md` (or equivalent instruction) — per-phase telemetry-activity record (emitted / failed-with-recorded-choice / confirmed-disabled)
  - `planifest-framework/standards/telemetry-standards.md` — updated to document the unified signal and the interactive-failure protocol as the single source of truth (ADR-002, 0000007)
  - `planifest-framework/skills/planifest-orchestrator/SKILL.md` — discovery.md elevated to Hard Limit status (new Hard Limit entry, updated Phase 0 Start Actions step 3d text, new Phase 0 → Phase 1 Gate Checklist item) — a self-audit finding from this feature's own P0: discovery.md (0000017, req-006) was silently skipped this session precisely because it was a numbered sub-step with no enforcement teeth, the same failure class this feature exists to fix for telemetry
- Data ownership: not applicable — no data-owning components in scope
- Deployment: not applicable — framework tooling distributed via `setup.sh`/`setup.ps1`
- API versioning: not applicable

## Scope
- In: unify the two telemetry gating signals by removing the `--context-mode-mcp` coupling from hook installation (`--structured-telemetry-mcp` alone sufficient); hook-driven emission writes a durable failure marker on error (never blocks, ADR-005 unchanged); orchestrator checks the marker at phase-start checkpoints and surfaces an interactive block-or-proceed question once per distinct root cause per run; every phase skill's Telemetry section rewritten for immediate-interactive agent-driven failure; build-log gets a per-phase telemetry-activity record; discovery.md elevated to Hard Limit status (self-audit finding from this feature's own P0 — picked up mid-session, same failure class as the telemetry problem itself)
- Out: `query_telemetry`/backend changes (confirmed fully functional this session, not our repo); new telemetry event types beyond the existing 14; changes to `structured-telemetry-mcp` itself; unrelated loop toggles (cross-model review, reversal protocol, etc.); a migration mechanism for legacy single-signal projects (no practical legacy install base exists — human-confirmed)
- Deferred: none identified

## Assumptions
- Removing the `--context-mode-mcp` coupling from telemetry hook installation has no other unstated technical dependency (e.g. a shared directory or settings.json section the two installers assume already exists) - impact if wrong: hook installation could fail in a new way for the `--structured-telemetry-mcp`-only path; needs verification at P3 by reading the actual installer code path, not just the flag-gating condition
- "Once per distinct root cause" is implementable with a reasonably simple identity check (e.g. error message + hook name, or event type + error) without needing a sophisticated fingerprinting mechanism - impact if wrong: either too many repeat prompts (if identity check is too granular) or too few (if it collapses genuinely different failures together)

## Risks
- Technical: the failure-marker mechanism itself could fail to write (e.g. disk full, permissions) — likelihood low, impact medium (a failure would then go fully unnoticed, exactly the problem this feature exists to prevent). Mitigate: the marker write should itself follow ADR-005 (best-effort, never throw), but the *absence* of a marker after a known-attempted emission should not be silently interpreted as success — needs explicit design attention at P1/P2.
- Operational: this feature touches 8 phase skills' Telemetry sections plus the orchestrator's own Resume Detection / phase-start logic — a moderate blast radius for a single release. Likelihood medium, impact low (framework tooling, all changes test-covered per this repo's own convention). Mitigate: keep the interactive-prompt logic in ONE place (orchestrator) rather than duplicated per skill, per ADR-002 (0000007)'s centralization principle.
- Process: `.claude/` (this session's local generated skill/hook copy) has now gone stale twice across two consecutive releases (0000017, 0000018) due to `setup.sh` not being re-run automatically after skill changes ship. Likelihood high (already recurred), impact low (caught and fixed both times, but relies on someone noticing). Not in this feature's scope per explicit human decision, but flagged here for future backlog consideration.

## Dependencies
- Upstream: `structured-telemetry-mcp` (`emit_event`/`query_telemetry`) — confirmed functional, no blocking dependency
- Downstream: none — no other repo consumes this framework's telemetry-emission mechanism directly

## Active Skills
None — no external capability-skill intake this session.

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| REQ-001 - remove-context-mode-mcp-coupling | planifest-codegen-agent | Bash/PowerShell installer logic change in setup.sh/setup.ps1 |
| REQ-002 - hook-failure-marker | planifest-codegen-agent | Node .mjs hook script changes, ADR-005-constrained |
| REQ-003 - orchestrator-marker-check-and-prompt | planifest-codegen-agent | Skill markdown logic change to planifest-orchestrator/SKILL.md |
| REQ-004 - phase-skill-telemetry-rewrite | planifest-codegen-agent | Coordinated edits across 8 phase-skill Telemetry sections |
| REQ-005 - build-log-telemetry-record | planifest-codegen-agent | Template/instruction addition, mechanical |
| REQ-006 - telemetry-standards-update | planifest-docs-agent | Centralizing documentation per ADR-002 (0000007) |
| REQ-007 - discovery-md-hard-limit | planifest-codegen-agent | Skill markdown logic change to planifest-orchestrator/SKILL.md's Hard Limits, Phase 0 Start Actions, and Gate Checklist |

Final REQ-NNN numbering and count will be assigned by the spec-agent at P1; this table uses placeholder ordering matching the 7 components above.

## Repo Instructions
### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. In some cases, you don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

The exception to the rule is that you can operate with git and GitHub commands if the human expressly asks you to. Report back if unsuccessful for any reason in these exceptional cases.

### Commit Granularly, Continuously
Commit locally after every meaningful artifact write — do not batch changes waiting for a phase gate, an approval checkpoint, or task completion. A single requirement doc, ADR, TDD cycle, or config fix is a commit on its own; don't hold it pending a bigger, later commit. Uncommitted work in the working directory is unrecoverable progress — commit early and often so nothing sits unsaved.

## Confirmation
Human confirmed this design before proceeding: yes
Date confirmed: 31 Jul 2026
