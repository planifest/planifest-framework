# Recommendations - 0000017-ratchet-forgery-detection-and-telemetry-schema-spec

**Skill:** planifest-docs-agent
**Date:** 2026-07-26

> Constructive, specific suggestions for future iterations. Not blocking; not acted on in this release.

---

1. **Force the `.mjs` hook node-fallback vs jq-path distinction is now moot — delete the closed TD-003 remediation note's `FORCE_NODE_FALLBACK` env-var idea outright next time tech-debt.md is touched.** It's already marked resolved; a future pass could remove the historical section entirely once nobody needs the pre-0000017 context (`src/context-mode-hooks/docs/tech-debt.md`).

2. **A reason field containing a literal `\|` character silently invalidates a `.ratchet-approve` line** (strict 3-field parse in `ratchet-check.mjs`). This fails in the safe direction (no approval, not a forged one) but could confuse a human approver who doesn't know the delimiter is significant. Worth a one-line callout in whatever approver-facing documentation eventually exists (there isn't a dedicated one yet — the mechanism currently lives only in `planifest-loop-runner`'s Hard Limit 2 and ADR-001).

3. **`plan/ratchet-audit-log.md` has no rotation, size cap, or archival story.** It's a single ever-growing file at the repo root, outside `plan/current/` and therefore outside the P7 archive-per-feature lifecycle. Fine at current scale; worth a policy decision (rotate yearly? archive alongside `plan/_archive/`?) before it becomes unwieldy.

4. **`discovery.md`'s External Anchor mode has never been exercised in this repo** (no `external-versioning.md` present) — its "whichever underlying mode's content applies" logic is specified but untested against a real repo shape. Worth a targeted smoke test the next time a project actually uses External Anchor mode.

5. **This release's own P0 surfaced that the Retrofit-mode discovery content ("6-step scan") was the only mode with pre-existing structure — the other 3 modes' discovery.md sections were written from what P0 already informally gathered, not from fresh design work.** If a future feature finds that Standard Iterative or Greenfield mode's P0 behavior includes steps not captured in req-006's specification, that's expected drift to reconcile, not a regression — flagged here so it isn't mistaken for one.

6. **The 4 background subagents dispatched for req-001/002/003/004 were interrupted mid-run by the session's monthly spend limit**, requiring inline recovery by the orchestrator (with a mid-session model switch to claude-fable-5, later switched back to claude-sonnet-5). No data was lost — every agent had left inspectable partial state (uncommitted diffs, in-progress reports) — but it's worth noting for future large-parallel-dispatch pipeline runs: verify remaining budget before dispatching several concurrent subagents on a single release.
