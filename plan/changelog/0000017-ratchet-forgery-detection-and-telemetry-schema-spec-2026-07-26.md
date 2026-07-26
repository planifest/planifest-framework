# Changelog — 0000017-ratchet-forgery-detection-and-telemetry-schema-spec — 26 Jul 2026

**Feature:** Ratchet Forgery Detection and Telemetry Schema Spec
**Pipeline run:** P0–P6 completed, continuous run authorized at design confirmation; no phases skipped
**Version:** 0.16.0 → 0.17.0

## What Was Built

A bundled backlog release closing five governance/portability gaps in the Planifest framework, plus two items discovered mid-session:

- **Ratchet-approve forgery detection, finalized** — `.ratchet-approve` reverses its original 0000016 human-only-write restriction: the agent may now write the marker, but only on explicit in-the-moment human instruction (path, reason, go-ahead in the same turn). Format extended to `path | reason | timestamp`; write must land in its own immediate commit; the same-uncommitted-changeset backstop is kept and now surfaces an explicit message instead of blocking silently; consumption copies the full record to a new permanent audit log at `plan/ratchet-audit-log.md`.
- **Regression suite promotion** — 0000016's 87 governance assertions (ratchet/product-version/consistency-check) promoted into the permanent regression pack via the pre-existing `scripts/promote-to-regression.sh`.
- **Phase/Wave terminology sweep** — 187 instances reviewed across `docs/`, `planifest-framework/`, `plan/current/`, and root `README.md`; 14 decomposition-sense corrections across 8 files (the canonical orchestrator/spec-agent skills were already correct from 0000016 — this closed the remaining template/guide gaps that sweep missed).
- **Cross-platform hook ports** — `block-bash`, `block-grep`, `block-webfetch` ported from `.sh` to `.mjs`, removing the `jq` and Git Bash/WSL dependency entirely; `setup.sh`/`setup.ps1` updated with setup-time and runtime missing-Node messages (fail-open preserved).
- **Scope Lock suggested-answers** — a new `planifest-scope-lock-agent` skill drafts Scope Lock Challenge answers on explicit human request only; usage-only framing, outcome-not-action, N/A recognition, consistency-checking against confirmed decisions, and strict no-implicit-confirmation are all dogfooded from this session's own live corrections.
- **Structured P0 discovery pass** — every adoption mode (not just Retrofit) now runs a discovery pass before coaching, writing to a new `plan/current/discovery.md` — fresh each pipeline run, archived at P7 alongside `build-log.md`/`design.md`.
- **Change-agent archive step** (picked up from backlog 0000011, filed by a cross-repo investigation in `structured-telemetry-mcp`) — the Change Pipeline previously had no close-out step, leaving permanent unarchived `plan/{feature-id}/` folders; `planifest-change-agent` gained a Phase 6 - Archive step mirroring the ship-agent's copy-then-delete pattern, plus a cross-reference check (also added to ship-agent's own P7 Step 6) so archiving never leaves stale `docs/decisions-index.md` links behind. A 10th orchestrator Hard Limit now mandates archiving for both pipeline routes.

Backlog 0000005 (telemetry schema gaps in `structured-telemetry-mcp`) was assessed, RCA'd, and handed off as a separate pipeline run in that sibling repo — confirmed complete by the human, no further action in this repo.

## Artifacts Produced

- `plan/current/`: design (7 user stories), 7 requirement files, execution-plan, scope, risk-register (5 risks + 2 assumptions), domain-glossary (13 terms), operational-model, slo-definitions, cost-model, 4 ADRs, security-report (risk Low), recommendations, `req-003-phase-wave-sweep-report.md`, build-log
- `planifest-framework/`: `ratchet-check.mjs` rewritten, 3 hooks ported to `.mjs`, `setup.sh`/`setup.ps1` wiring, new `planifest-scope-lock-agent` skill, new `discovery.template.md`, orchestrator/change-agent/ship-agent/loop-runner skill updates, 8 template/guide corrections, 5 new framework test suites (req-001/002/004/005/006/007) + 1 traceability test (req-003)
- `src/context-mode-hooks/`: `component.yml` (v0.1.0 → v0.2.0, stack bash→node, quirks Q-002/Q-005 removed, risk R-004 removed), all 8 `docs/` files synced, 3 component test files repointed to `.mjs`
- Living docs: component-registry, dependency-graph (jq/awk/grep removed, node-only), decisions-index (+4 ADRs, ADR-004 marked amended), architecture-overview

## Decisions

- ADR-001 (this feature): ratchet-approve — agent write on explicit instruction; supersedes 0000016 ADR-004's write prohibition
- ADR-002 (this feature): cross-platform hook runtime unification, `.sh` → `.mjs`
- ADR-003 (this feature): Scope Lock suggested answers via on-demand subagent; extends 0000014 ADR-007/ADR-008
- ADR-004 (this feature): structured P0 discovery pass and `discovery.md` lifecycle

## Skipped Phases

None.
