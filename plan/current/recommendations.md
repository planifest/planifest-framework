# Recommendations - Declared Product ID and Telemetry Envelope Fix

**Skill:** [docs-agent](../skills/docs-agent-SKILL.md)
**Feature:** 0000024-declared-product-id-for-telemetry
**Version:** 0.24.0

> These are not blockers - they are opportunities for future work.

## Recommendations

| ID | Category | Priority | Component | Recommendation | Rationale | Effort |
|----|----------|----------|-----------|---------------|-----------|--------|
| REC-001 | security | low | planifest-framework | Clarify in `planifest-orchestrator/SKILL.md` step 3b that the human's declared-id answer should be quote-escaped before being written into `product.yml`'s YAML | P5 security finding: an answer containing `"` could produce malformed YAML; low severity since the trust boundary is the human's own project, but a cheap doc fix | small |
| REC-002 | maintainability | low | planifest-framework | Consider a soft length cap or sanity check on `readProductId()`'s returned value, purely as defence-in-depth | P5 security finding: no length cap today; not required given the trust boundary (committed source, not external input), but cheap insurance | small |
| REC-003 | maintainability | medium | planifest-framework | Fix `docs/decisions-index.md` drift: feature 0000023's ADR section is misplaced (appears after 0000012 instead of chronologically after 0000020), and features 0000021 and 0000022 are missing entirely despite both producing 2 ADRs each (`ADR-001-opus5-model-tier-override-for-audit.md` + `ADR-002-guardrailed-baseline-gated-trim-process.md` for 0000021; `ADR-001-agent-dispatch-standards-file.md` + `ADR-002-dual-detector-content-loss-verification.md` for 0000022) | Discovered during this feature's own P6 docs update while placing the new 0000024 entry; out of scope to backfill here (would require re-deriving accurate summaries from those features' own archived ADRs, not part of this feature's requirements) | medium |

## Deferred Items

| Scope Item | Recommendation | When to Address |
|-----------|---------------|-----------------|
| Root Cause B from the 0000017 RCA (missing `loop_iteration`/`phase_reversal_*` schema entries in `structured-telemetry-mcp`'s deployed schema) | Not checked this run (no loop/reversal events were emitted during this feature's execution to test against) — verify in a future feature that actually exercises a loop toggle, and file a fresh backlog entry against `structured-telemetry-mcp` if still broken | Next feature that enables a loop/reversal toggle (`planifest-overrides/loop-toggles.yml`) |

## Tech Debt

| ID | Component | Description | Impact if Ignored | Suggested Fix |
|----|-----------|-------------|-------------------|--------------|
| TD-001 | planifest-framework | `readProductId()` is duplicated identically across all 3 telemetry hooks (`emit-phase-start.mjs`, `emit-phase-end.mjs`, `context-pressure.mjs`), consistent with this codebase's existing pattern of duplicating small helpers per file rather than a shared module | None currently — matches established convention (`recordTelemetryFailure`, `readStdin` are duplicated the same way); a future shared-helper refactor would need to address all such duplicated functions together, not just this one | If duplication ever becomes a maintenance burden across the 3 files, extract a shared `hooks/telemetry/_shared.mjs` module for all duplicated helpers at once, not just `readProductId` in isolation |
