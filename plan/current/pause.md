---
phase: "P0"
active_task: "Coaching backlog-bundle scope (0000002, 0000008, 0000009, 0000010) toward a confirmed design.md, after descoping 0000005 to a separate structured-telemetry-mcp session"
last_artifact: "plan/current/telemetry-mcp-rca-and-fix-spec.md"
---
# Pause Record - 0000017-ratchet-forgery-detection-and-telemetry-schema-spec

**Paused:** 2026-07-11T21:00:00Z
**Phase:** P0 — Assess & Coach

## In-Progress State

**Feature branch:** `feat/0000017-ratchet-forgery-detection-and-telemetry-schema-spec`, created off `main` (already synced to `origin/main` `8487630`, all prior PRs merged, stale local branches deleted).

**Scope (Feature Pipeline — bundled backlog release):**
- `0000002` — promote 0000016's governance test suite (ratchet/product-version/consistency-check, 97 assertions) to the regression pack via `scripts/promote-to-regression.sh`
- `0000005` — **descoped from this release.** RCA complete (see below) and handed off to a separate repo/session. No further work on it happens in this pipeline run.
- `0000008` — implement ratchet marker same-changeset forgery detection (ADR-004's "where detectable" follow-through; P5 medium finding REC-003). ADR-004 already specifies the mechanism: reject `.ratchet-approve` consumption when the marker line was added in the same uncommitted change set as the guarded write (`git diff`/working-tree status check).
- `0000009` — sweep remaining Phase→Wave decomposition-sense wording in guide files (`feature-brief-guide.md` etc.) that REQ-006 didn't cover (REC-005)
- `0000010` — context-mode-hooks portability debt: `jq` hard dependency (no pure-bash fallback), Windows requires bash-compatible shell. Backlog entry itself says: assess real-world impact first before committing engineering effort — may resolve to "just document it" rather than code changes.
- Also verify the README "agile" rationale wording already landed in PR #40 is finished/correct (it reads complete on inspection — no further action identified yet, but not formally signed off).

**Adoption mode confirmed:** Standard Iterative (plan/_archive has prior features, docs/about.md exists at 0.16.0).
**Version confirmed:** 0.17.0 (minor bump, Feature Pipeline track).
**Repo instructions loaded:** `planifest-overrides/instructions/custom-001-local-git-only.md` (local-git-only, with human-expressly-asked exception; commit granularly).

**0000005 investigation — completed, for context:**
Investigated `docs/0008c`'s claimed root cause for R-009 (`emit_event` rejecting all calls with `"(root): must be object"` during the 0000016 run) by reading the live `structured-telemetry-mcp` repo (local sibling clone). Found `docs/0008c` is stale — all its cited schema gaps shipped 19 Apr 2026. Reproduced the real root cause via `npx tsx` against the live `validateEvent()`: (A) the `emit_event` MCP tool argument is typed `z.unknown()`, exposing no object structure to calling models — confirmed via `zodToJsonSchema` — and several plausible malformed payloads (stringified envelope, `undefined`, `null`, array-wrapped) all reproduce the exact recorded error; (B) cross-referencing every framework skill's `## Telemetry` section against the deployed schema found 4 live gaps — `loop_iteration`, `phase_reversal_petitioned`, `phase_reversal_granted`, `phase_reversal_denied` (from `planifest-loop-runner`) are missing from the deployed enum, postdating the April schema update. Full RCA + implementation/test/docs spec + Definition of Done written to `plan/current/telemetry-mcp-rca-and-fix-spec.md` in this repo (audit trail, marked handed-off) and copied to `structured-telemetry-mcp/plan/current/emit-event-rca-and-fix-spec.md` (local sibling clone) as a candidate scope item for that repo's next P0 — it sits alongside an existing unrelated, unconfirmed pre-P0 `feature-brief.md` there (systemd/launchd deploy work, dated 4 Jul) which was left untouched.

**What remains before P0 → P1 gate:**
1. Coach problem statement / user stories / acceptance criteria for the four remaining items (0000002, 0000008, 0000009, 0000010) — not yet started.
2. Specifically pending: confirm with the human whether ADR-004's mechanism for 0000008 should be treated as binding design (git-status check on `.ratchet-approve` at consumption time) or reconsidered now that it's actually being implemented. This question was asked but not yet answered when the session paused.
3. Run the Scope Lock Challenge (four scenario-path questions) once the brief is otherwise complete.
4. Confirm continuous-run vs interactive mode for the rest of this pipeline.
5. Write `plan/current/design.md` (does not exist yet) and get human confirmation before proceeding to P1.

**Sentinel state:** `plan/.orchestrator-active` contains `0000017-ratchet-forgery-detection-and-telemetry-schema-spec`. `plan/.run-mode` not yet written (mode not yet confirmed). `plan/current/build-log.md` exists with a P0 phase block, notes updated through the 0000005 handoff.

## Resume Instructions

On next session start, the orchestrator will detect this file and open with:

```
P0: Resuming — Coaching backlog-bundle scope (0000002, 0000008, 0000009, 0000010) toward a confirmed design.md, after descoping 0000005 to a separate structured-telemetry-mcp session
```

After re-reading this file, continue from the in-progress state above — resume directly at the ADR-004-binding-or-reconsider question for 0000008, then proceed through the remaining three items one at a time per the coaching priority order, before running the Scope Lock Challenge and writing design.md.

Delete this file once the interrupted task has been re-engaged.
