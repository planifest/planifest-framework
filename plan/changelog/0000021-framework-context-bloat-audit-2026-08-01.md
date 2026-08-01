# Changelog — 0000021-framework-context-bloat-audit — 01 Aug 2026

**Change:** Fresh-context claude-opus-5 audit and guardrailed trim of redundant/implicit content across `planifest-framework/skills/`, `planifest-framework/standards/`, `planifest-framework/templates/`, and root `CLAUDE.md` (Feature Pipeline)
**Backlog entries closed:** 0000019 (populate the regression pack — pulled into this feature as a prerequisite)
**Backlog entries left open:** 0000020 (decompose the orchestrator skill), 0000021 (define a minimal artifact set), 0000024 (record a skill-scope principle ADR) — explicitly deferred per human direction at P0; this feature's real in-file trim ceiling for `planifest-orchestrator/SKILL.md` (21.1% reduction achievable in-file after two full audit rounds) is concrete evidence for backlog 0000020's next attempt

---

## Baseline (req-001)

Regression pack populated: 1 pre-existing test → 22 tests (21 promoted from `planifest-framework/tests/`, human-reviewed list). Discovered and fixed a pre-existing defect in `planifest-framework/scripts/promote-to-regression.sh` (no path adjustment for `tests/regression/` sitting one directory level deeper than `tests/`) — every promoted test but the original broke on first use; fixed at the tool level plus two bespoke fixes for self-referential tests. Baseline: 33 feature suites + 22 regression tests, 0 failures, exit 0.

## Audit (req-002)

Three parallel fresh-context `claude-opus-5` subagents (per ADR-001), scope narrowed to exclude `.cursorindexingignore`-matched guide/evaluation files (already opt-in-only). Findings: `plan/current/audit-findings-report.md` + 3 detail files.

## Trim (req-003) — two rounds

| Corpus | Baseline | Round 1 | Round 2 (final) | Reduction |
|--------|---------:|--------:|-----------------:|----------:|
| Skills (`skills/*/SKILL.md`) | 3,959 | 3,406 (14.0%) | **3,071** | **22.4%** |
| Standards (in-scope) | 2,750 | 1,563 | 1,563 | **43.2%** |
| Templates (in-scope) + CLAUDE.md | 1,834 | — | **1,318** | **28.1%** |

Round 1 alone fell short of NFR-001's ≥20% floor on the skills corpus (14.0%). Two independent closing-the-gap agents confirmed every round-1 audit recommendation was already fully applied — the shortfall was the audit's own summary-table percentages not reconciling with its itemized findings, not unapplied work. Escalated to the human; a second, deeper `claude-opus-5` audit pass was commissioned specifically for the shortfall files, found genuinely new redundancy (23 new items in the orchestrator alone), and closed the gap. `planifest-orchestrator/SKILL.md`: 1,195 → 943 lines (21.1%) across two full audit rounds — in-file only, no structural decomposition, per the human's explicit decision to keep backlog 0000020 deferred even after this feature demonstrated the in-file ceiling.

**Guardrail catch:** the post-round-2 regression run surfaced 24 real failures — the dual-guardrail process (ADR-002) working as designed. Root causes: the DUP-1 "Commit Cadence" removal broke a test requiring 6 skills to each locally carry "meaningful artifact write"; the DUP-2 telemetry gate paragraph was over-condensed in 7 skills, losing 4-5 test-required literal phrases each; two of this session's own correctness-fix instructions (a section merge in `validate-agent`, a relocation in `ship-agent`) broke tests tied to the prior exact structure; plus assorted single-phrase casualties across `codegen-agent`, `orchestrator` (×2), `change-agent` (×2), `reversal-assessor`, `optimise-agent`, `refresh-setup`, and `telemetry-standards.md`. All fixed with minimal, test-informed restorations — not full reverts. Final re-run: 33 feature suites + 22 regression tests, 0 failures, exit 0, matching the baseline exactly. No new failures, no self-correction/escalation increase versus baseline.

## Incidental correctness fixes (bundled in, files already touched)

- `planifest-ship-agent/SKILL.md`: Step 8/Step 9 phase-prefix table collision fixed (renumbered Steps 8-12)
- `planifest-validate-agent/SKILL.md`: two duplicate parallelism sections merged
- `component.template.yml`: dead "p007" doc reference checked (confirmed nonexistent, removed)
- Root `CLAUDE.md`: MCP tool name corrected (`mcp__context-mode__...` → `mcp__plugin_context-mode_context-mode__...`); one stale sentence removed (also removed from `standard-boot.md`)
- `adr.template.md`: frontmatter/body status-enum mismatch reconciled
- `feature-brief.template.md`, `execution-plan.template.md`: stale skill-path footers fixed
- `test-writer`, `docs-agent`, `refresh-setup`: several small cross-reference/duplication defects found during round-2 audit and fixed (see build log for full list)

## Not Fixed / Deferred

- Orchestrator structural decomposition into a router + `references/` pattern (backlog 0000020) — deferred per explicit human decision, re-affirmed mid-feature when directly asked whether new evidence changed the call
- Skill-scope principle ADR (backlog 0000024) — deferred, same rationale
- `CLAUDE.md`'s trims exist on disk but are not committed to this repo's git history — the file is intentionally gitignored (part of the "Agent tool config" block alongside `.claude/`), discovered while staging this feature's changes

## Verification

`bash planifest-framework/tests/run-tests.sh`: baseline 33/22 passed, 0 failed → post-trim (round 1) 24 failed → post-guardrail-fix 33/22 passed, 0 failed. Identical to baseline.
