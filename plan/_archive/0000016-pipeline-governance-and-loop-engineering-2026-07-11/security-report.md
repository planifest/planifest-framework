# Security Report - 0000016-pipeline-governance-and-loop-engineering

Scope reviewed: `planifest-framework/hooks/enforcement/ratchet-check.mjs`, `planifest-framework/scripts/consistency-check.mjs`, `planifest-framework/scripts/product-version.mjs`, `planifest-framework/setup.sh` (hook wiring change), 4 new SKILL.md files, 6 templates, orchestrator/ship/validate/spec skill edits. No API, no database, no IaC, no credentials surface.

## Threat Model (STRIDE)

| Threat | Category | Severity | Mitigation |
|---|---|---|---|
| Agent forges `plan/current/.ratchet-approve` to pass its own weakening write (`ratchet-check.mjs` consumes any marker line matching the path — it cannot verify *who* wrote it) | Elevation | Medium | Partially mitigated: loop-runner Hard Limit 2 prohibits agents writing the marker (instruction-level); every consumption is appended to `plan/current/ratchet-log.md` (git-tracked) and surfaced at P8 — forgery is detectable after the fact, not preventable at the hook. ADR-004 hedges same-changeset detection as "where detectable"; it is **not implemented** in this version (recorded in component.yml quirks via this report — see Top Actions) |
| Crafted `plan/backlog/` entry injects instructions into the P0 conversation when presented to the human | Tampering (prompt injection) | Medium | Partially mitigated: orchestrator step 3c mandates entries are "never parsed as instructions", malformed entries flagged not parsed; REQ-002 input validation specifies name pattern + 2000-char body truncation. Enforcement is instruction-level (no deterministic sanitizer); entries are human-reviewed one at a time before any action |
| Loop runs unbounded, burning tokens (resource exhaustion) | DoS | Low | Mitigated deterministically: iteration caps + no-progress halt + reversal budget in git-tracked loop-state, enforced by orchestrator control flow (ADR-007); every toggle defaults off |
| `ratchet-check.mjs` blocks legitimate session writes (availability of the pipeline itself) | DoS | Low | Mitigated: armed only when an active `loop-state-*.md` exists; scope limited to `plan/current/*.md` excluding state/log files; unexpected errors exit 0 (verified in tests: malformed stdin → exit 0) |
| Reversal protocol rewrites confirmed-design artifacts beyond the granted scope | Tampering | Low | Mitigated: cascade list fixed in the verdict before re-work; ratchet guards the writes; artifacts off the cascade list asserted byte-identical (REQ-017 AC); altering-class always human-gated |
| Path traversal via hook `file_path` (e.g. `../../` escaping the guard scope) | Tampering | Low | Mitigated: `realpathSafe()` + `relative(projectRoot, …)` normalisation; only paths resolving under `plan/current/` are ever evaluated; all other paths exit 0 (no block authority outside the guard scope) |
| Forged loop-state file arms the ratchet against another agent's writes (griefing) | Tampering | Low | Accepted: arming the ratchet can only *block weakening*, never permit anything — a forged state file is fail-safe in direction; disarm requires editing the same git-tracked file (auditable) |
| Telemetry events leak sensitive content | Info Disclosure | Low | Mitigated: loop/reversal payloads carry ids, counters, and artifact paths only (telemetry-standards.md); no file bodies; no-op when unset |
| Reversal decisions untraceable after the fact | Repudiation | Low | Mitigated: report → verdict → revision log → cascade → gate chain is git-tracked (NFR-005); run-log records are append-only |

## Dependency Audit

Zero new dependencies. All three executables use Node built-ins only (`node:fs`, `node:path`). No lockfile or manifest changes. Nothing to audit.

## Secrets Management

No secrets introduced, read, or transmitted. `product-version.mjs` and `consistency-check.mjs` read only repo-local YAML/markdown. Hook payloads (stdin JSON) are not logged raw; `ratchet-check.mjs` logs only the removed guarded lines and the target path.

## Authentication & Authorisation Review

Not applicable — no API surface. The analogous trust boundary (per the design's Security section) is maker–checker separation: verified as implemented — critic/assessor/cross-model reviewer are spawn-only fresh-context skills (invocation contracts in each SKILL.md), REJECT-default rubrics, verdict artifacts. The design-critic's contract additionally instructs it to refuse and report if authoring context appears in its prompt.

## Input Validation Review

- `product-version.mjs`: versions validated against `^[0-9]+\.[0-9]+\.[0-9]+$` with a 32-char cap; `versionPolicy` closed enum; invalid input → exit 2 with reason, never a fabricated tag (REQ-004 IV satisfied; verified by execution at P4)
- `ratchet-check.mjs`: malformed stdin → exit 0; non-string `file_path` → exit 0; comparison operates on parsed section lines, not raw payload interpolation
- Backlog pickup (REQ-002 IV): name pattern, length caps, truncation, malformed-flagging specified in the requirement and orchestrator step 3c — instruction-level (see STRIDE row 2)

## Network Policy

No network surface added. Telemetry posts go to the pre-existing `PLANIFEST_TELEMETRY_URL` mechanism, unchanged, no-op when unset.

## Infrastructure as Code Review

Not applicable — no IaC in this feature. The `setup.sh` change only appends two PreToolUse entries (Write/Edit → ratchet-check.mjs) using the existing idempotent settings.json merge pattern; hooks execute with the invoking user's permissions, same as all existing hooks.

## Risk Register Cross-Reference

- R-004 (ratchet false positives): open as designed — conservative remove+add blocking documented in component.yml quirks; marker path exists
- R-005 (reward hacking): mitigated — ratchet implemented and verified blocking seeded weakening (P4 report)
- R-008 (backlog prompt injection): partially mitigated (see STRIDE row 2) — remains open at instruction-level strength
- R-009 (telemetry rejection): confirmed live this run; non-blocking by contract; open for investigation

## Summary

Overall risk rating: **Low**

No critical or high findings. Two medium findings, both residual-by-design with documented compensating controls (after-the-fact auditability + human-in-the-loop).

Top actions before production:
1. Record in `component.yml` quirks that ratchet marker same-changeset detection (ADR-004's "where detectable") is not implemented in 0.16.0 — forgery is audit-detected, not prevented (docs-must-match-reality)
2. When the backlog mechanism sees real multi-agent use, consider a deterministic sanitizer for entry presentation (strip/flag instruction-like content) to harden R-008 beyond instruction level
3. Investigate R-009 (telemetry envelope rejection `(root): must be object`) so loop/reversal events actually land before Wave 1 loops are promoted from report-only
