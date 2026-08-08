# Security Report - 0000027-backlog-batch-governance-tooling-fixes

## Threat Model (STRIDE)

| Threat | Category | Severity | Mitigation |
|---|---|---|---|
| `emit-event-receipt.mjs` constructed a receipt file path directly from `envelope.phase`/`envelope.event` (agent-supplied `emit_event` tool-call arguments) without validating either against a closed set — `node:path`'s `join()` does not sandbox `..` segments embedded in a single path component, so a crafted phase/event string (e.g. `../../../../tmp/evil`) could write a `.marker` file outside `plan/.telemetry-receipts/`, anywhere the process has write access. | Tampering (CWE-22, Path Traversal) | Medium | **Fixed during this review.** Added `KNOWN_PHASES`/`KNOWN_EVENT_TYPES` closed-set validation (the 7 phases and 14 event types documented in `telemetry-standards.md`) before path construction; anything outside either set is rejected and routed through the existing `plan/.telemetry-failures/` marker mechanism instead of being used in a path. Locked in by a new regression test (`test-0000027-req-004-telemetry-compliance-backstop.sh`, scenario 3b) asserting no file is written outside the workspace for a crafted phase/event value. Full suite re-verified green after the fix. |
| `merge_telemetry_hook_settings()` in `setup.sh`/`setup.ps1` interpolates `backend_url` (a CLI-supplied value) directly into a shell command string (`PLANIFEST_TELEMETRY_URL=$backend_url node ...`) that is then written into `.claude/settings.json` as a hook `command`, executed by the shell whenever that hook fires. A `backend_url` containing shell metacharacters could result in command injection at hook-fire time. Pre-existing pattern (already present for `context-pressure.mjs` before this feature); req-001 had propagated it to 2 more call sites (`start_cmd`, `end_cmd`). | Tampering / Elevation (command injection) | Medium | **Fixed, scope expanded per human direction at the P5 gate.** `--backend-url` is now validated once at CLI-parse time in both `setup.sh` and `setup.ps1` against a plain-http(s)-URL regex (`^https?://[A-Za-z0-9.-]+(:[0-9]+)?(/[A-Za-z0-9._/-]*)?$`); anything else exits 1 before it can reach any of the 3 telemetry hook command strings. Verified live: a `--backend-url` containing `;touch ...` now exits 1 and the injected command never runs; a plain URL still installs successfully. Locked in by a new regression test (`test-0000027-req-004-telemetry-compliance-backstop.sh`, scenario 9). Full suite re-verified green. The backlog entry originally filed for this (`0000055`) was withdrawn since the fix landed in this same feature instead of being deferred. |
| A dispatched subagent could file a `plan/backlog/` entry using a human-supplied or attacker-influenced `id`/`slug` that escapes `plan/backlog/` via path traversal in the folder name. | Tampering | Low | Not exercised by this feature's own changes — req-003 only adds *instructional* text (agents should pre-compute and use a numeric ID); it does not add new code that constructs a backlog path from unvalidated input. Existing backlog-entry creation in this session used plain numeric IDs throughout. No code change in scope here to review. |
| `resolve-phase.mjs`'s `end` mode reads `input.cwd` (from the Stop hook's own JSON payload, supplied by Claude Code, not by external/untrusted content) to locate the active-phase marker file. | Tampering | Low | `cwd` is a host-tool-supplied hook field, not user/external input — same trust boundary every other hook in this repo already relies on (`context-pressure.mjs`, `check-telemetry-failures.mjs`, etc.). Not a new trust assumption introduced by this feature. |
| `emit-event-receipt.mjs`/`check-telemetry-receipts.mjs` write/read `plan/.telemetry-receipts/*.marker` files containing only `phase`, `event_type`, `timestamp`, `schema_version`, `product_id` — no secrets, no PII. | Information Disclosure | Low | No sensitive data enters these files by construction (fields are copied from the envelope's own non-secret metadata). |
| `verify-telemetry-hooks.mjs` (a setup-time, non-fail-open check) exits 1 with a message on stderr if hook wiring is incomplete — could be used to probe which hooks are installed on a target machine if run by an untrusted party. | Information Disclosure | Low | This is a local, operator-invoked setup-verification script, not network-exposed; no new attack surface. |
| Denial of Service: `resolve-phase.mjs`/`emit-event-receipt.mjs` are hook scripts that run on every `Skill`/`Stop`/`emit_event` tool call; a bug causing them to hang could stall the session. | Denial of Service | Low | Both are fully synchronous/short-lived Node scripts with no network calls, no infinite loops, and fail-open on every error path (`try/catch` wrapping the entire body, `process.exit(0)` on any exception) — consistent with ADR-005's "never block a turn" precedent already enforced across this hook family. |

## Dependency Audit

No new dependency manifest was added or modified (`package.json` untouched) — all 4 new files (`resolve-phase.mjs`, `emit-event-receipt.mjs`, `check-telemetry-receipts.mjs`, `verify-telemetry-hooks.mjs`) use only Node.js builtins (`node:fs`, `node:os`, `node:path`, `node:child_process`). No third-party packages introduced, no known-vulnerability surface added.

## Secrets Management

No hardcoded credentials, API keys, or tokens found in any file changed by this feature. `PLANIFEST_TELEMETRY_URL` (an endpoint URL, not a credential) is the only environment-variable-driven configuration touched, and it follows the exact same pattern already in use by `context-pressure.mjs` prior to this feature.

## Authentication & Authorisation Review

Not applicable — no API surface was added or modified by this feature (confirmed at P1: no OpenAPI spec produced, per the confirmed design).

## Input Validation Review

- **`emit-event-receipt.mjs`**: `envelope.phase`/`envelope.event` — **finding fixed** (see Threat Model above).
- **`resolve-phase.mjs`**: the Skill name extracted from `tool_input.skill`/`tool_input.name` is looked up in a fixed internal map (`PHASE_SKILLS`) before ever reaching a file path or shell command — unrecognised values exit 0 silently, no injection surface.
- **`check-telemetry-receipts.mjs`**: `phase` values used for path lookups come only from a fixed internal map (`PHASE_NUMBER_TO_ENUM`), never from external input.
- **`verify-telemetry-hooks.mjs`**: the settings-file path is a CLI argument supplied by the operator running the script directly, not by any automated or remote caller.

## Network Policy

No new network-facing surface. `PLANIFEST_TELEMETRY_URL` (pre-existing) is the only network egress point touched, unchanged in behaviour by this feature.

## Infrastructure as Code Review

Not applicable — no IaC files exist in this stack (declared `none` in `plan/current/design.md`'s Stack table).

## Summary

Overall risk rating: **Low**

Both Medium findings were found and fixed during this same review: path traversal in `emit-event-receipt.mjs` (CWE-22, fixed inline), and shell-interpolation of `backend_url` in `setup.sh`/`setup.ps1`'s telemetry hook registration (fixed with an expanded, human-confirmed scope covering all 3 call sites, not just the 2 this feature introduced). Both have regression tests locking in the fix. Full test suite (75 skill checks + 51 feature suites + 22 regression suites) re-verified green after both fixes. Zero Critical or High findings, zero outstanding Medium findings.

Top actions before production: none outstanding.
