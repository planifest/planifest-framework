# Recommendations - pipeline-gate-and-config-fixes-and-ship-agent-fixes

**Skill:** [docs-agent](../skills/docs-agent-SKILL.md) (or any agent that identifies improvements)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Version:** 0.25.0

> These are not blockers - they are opportunities for future work.

## Recommendations

| ID | Category | Priority | Component | Recommendation | Rationale | Effort |
|----|----------|----------|-----------|---------------|-----------|--------|
| REC-001 | security | low | `setup-hook-integration` | Add a one-line callout in setup documentation (`setup.sh`/`setup.ps1` usage notes or `planifest-overrides/setup-config/` README, if one exists) warning that `backendUrl` should never embed basic-auth credentials, now that it's git-tracked by default (req-004). | From P5 security review — no code fix possible, this is an adopter-configuration risk that documentation can reduce. | small |
| REC-002 | maintainability | low | `planifest-framework` | `docs/component-registry.md`'s Notes section states "Each `ID` corresponds to a directory under `src/` containing a `component.yml` manifest" — not true for `planifest-framework` itself, which lives at the repo root (established since at least 0000023/0000024). Reword the Notes section to acknowledge the self-hosting exception explicitly, rather than leaving it as an unstated special case a future reader has to infer. | Discovered while updating this file at P6 — pre-existing, not introduced by this feature, flagged rather than silently fixed per docs-agent's drift-handling rule. | small |
| REC-003 | observability | low | `setup-hook-integration` | Consider a refresh/setup startup check that warns (not just silently reconciles) when `planifest-overrides/setup-config/{tool}.md` and `.planifest-setup-flags` disagree, so a human notices the drift happened rather than it being invisible. | Extends req-004/ADR-002's reconciliation behavior with visibility, addressing Risk Register R-003 more defensively. | small |

## Deferred Items

| Scope Item | Recommendation | When to Address |
|-----------|---------------|-----------------|
| Historical `recommendations.md` Deferred Items/Tech Debt entries from features archived before 0000025 (e.g. 0000016, 0000020, 0000022, 0000024) remain scattered in their own archived docs, not backfilled into `plan/backlog/` by req-005's new forward-only routing. | If operators report friction finding old deferred items, file a one-time migration feature that walks `plan/_archive/*/recommendations.md` and files each row as a tagged `plan/backlog/` entry. | Address only if friction is confirmed — not a default follow-up, per feature-brief.md's explicit out-of-scope note for req-005. |

## Tech Debt

None identified — all 7 stories implemented cleanly against their acceptance criteria with no shortcuts or known gaps requiring follow-up.
