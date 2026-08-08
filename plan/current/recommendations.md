# Recommendations - backlog-batch-governance-tooling-fixes

**Skill:** [docs-agent](../skills/docs-agent-SKILL.md) (or any agent that identifies improvements)
**Feature:** 0000027-backlog-batch-governance-tooling-fixes
**Version:** 0.27.0

> These are not blockers - they are opportunities for future work.

## Recommendations

| ID | Category | Priority | Component | Recommendation | Rationale | Effort |
|----|----------|----------|-----------|---------------|-----------|--------|
| REC-001 | maintainability | low | `planifest-framework` | `docs/component-registry.md`'s Notes section still states "Each `ID` corresponds to a directory under `src/` containing a `component.yml` manifest" — not true for `planifest-framework` itself (repo root). This was already flagged as REC-002 in `0000025`'s own recommendations.md and was not fixed. Re-flagging rather than silently fixing, per docs-agent's drift-handling rule (out of this feature's declared scope). | Pre-existing since at least `0000023`/`0000024`; flagged twice now without action. | small |
| REC-002 | testing | medium | `planifest-framework` | Exercise `resolve-phase.mjs`'s `PreToolUse(Skill)` matcher against a live Claude Code hook firing (a real orchestrator session invoking a phase-agent Skill) before this ships to downstream adopters — it was verified only by direct script invocation during P3/P4, not by an actual hook trigger, since no live orchestrator session was available in that environment. | Closes the one live-verification gap in this feature's headline mechanism (phase telemetry wiring, req-001/req-004). | small |
| REC-003 | maintainability | low | `planifest-framework` | Consolidate `check-telemetry-receipts.mjs`'s `PHASE_NUMBER_TO_ENUM` map and `resolve-phase.mjs`'s `PHASE_SKILLS` map into one shared source once this repo has a components-shared-code convention; today every hook file duplicates its own helpers by design. | Tech debt noted at P3 codegen; not a functional problem today, just duplication. | small |
| REC-004 | observability | low | `planifest-framework` | Consider having the orchestrator explicitly signal true phase completion (not just relying on the `Stop` hook's per-turn firing) so `resolve-phase.mjs`'s `phase_end` duration is accurate for multi-turn phases. | Documented limitation from req-001: presence of the event is guaranteed, but `duration_ms` under-reports for phases spanning multiple turns. | medium |
| REC-005 | security | low | `setup-hook-integration` | Document the new `--backend-url` validation constraint (plain `http(s)://host[:port][/path]`, no userinfo, no query string) in setup usage help/docs, so an operator who needs a URL with query parameters or embedded credentials knows why it's rejected rather than treating it as a bug. | From this feature's own P5 security fix (backlog 0000055, resolved inline) — the regex is intentionally strict; adopters should know the boundary. | small |

## Deferred Items

| Scope Item | Recommendation | When to Address |
|-----------|---------------|-----------------|
| Precise `phase_end` timing for multi-turn phases (see REC-004) requires the orchestrator to explicitly signal phase completion — an orchestrator `SKILL.md` behaviour change, out of scope for req-001 (a hook-wiring requirement, not an orchestrator conduct change). | Pick up as its own requirement once duration accuracy for multi-turn phases is actually needed by a telemetry consumer (e.g. build-assessment reporting). | Address if a future feature's build assessment or telemetry dashboard shows duration data is materially wrong for multi-turn phases. |

## Tech Debt

| ID | Component | Description | Impact if Ignored | Suggested Fix |
|----|-----------|-------------|-------------------|--------------|
| TD-001 | `planifest-framework` | `check-telemetry-receipts.mjs`'s phase-number-to-name table duplicates `resolve-phase.mjs`'s own `PHASE_SKILLS` map conceptually (see REC-003). | None today — both maps are small, static, and rarely change; a future edit to one without the other could silently drift. | Extract to one shared module once a components-shared-code convention exists in this repo. |
| TD-002 | `planifest-framework` | `resolve-phase.mjs`'s `PreToolUse(Skill)` matcher and `tool_input.skill` field name were not verified against a live Claude Code hook firing during P3/P4 (see REC-002). | If the Skill tool's actual `tool_input` shape differs from what this hook assumes, `phase_start` would silently fail to fire (fail-open, per ADR-005) — no crash, but a quiet telemetry gap exactly like the one this feature exists to close. | Run a live orchestrator session and confirm `phase_start`/`phase_end` receipts actually appear under `plan/.telemetry-receipts/` for a real phase transition. |
