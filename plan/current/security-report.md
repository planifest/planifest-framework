# Security Report - 0000023-framework-pipeline-fixes

## Threat Model (STRIDE)

| Threat | Category | Severity | Mitigation |
|---|---|---|---|
| `getProductId()`'s `execFileSync("git", ["rev-parse", "--show-toplevel"], { cwd, ... })` (3 telemetry hooks) could theoretically be an injection vector if `cwd` were interpolated into a shell command string | Tampering | Low | Not exploitable: `execFileSync` invokes the binary directly with a fixed literal argument array (`["rev-parse", "--show-toplevel"]`) and no shell (`shell` option not set, defaults to `false`) — `cwd` is passed only as the working-directory option to the underlying `spawn` syscall, never concatenated into a command string or shell-interpreted. Verified by reading the actual diff, not assumed. |
| `getProductId()` failure (missing `git` binary, non-repo cwd, permission error) could crash the hook or block telemetry emission | Denial of Service | Low | `try/catch` wraps the entire call; on any failure, falls back to raw `cwd` and returns normally — matches the existing ADR-005 fail-open pattern already used elsewhere in these same 3 files. Verified by the new regression test's "missing git binary" case (3 hooks × 1 case, all passing). |
| `product_id` (a filesystem path) is now included in every telemetry event, sent to `$PLANIFEST_TELEMETRY_URL` | Information Disclosure | Low | The value is a local filesystem path already implicitly knowable from the machine running the hook (the repo root of the project being worked in) — no new category of sensitive data introduced beyond what a repo path already reveals (matches the existing `cwd`-based data already emitted elsewhere in this envelope, e.g. session context). Telemetry emission itself is opt-in, gated by the pre-existing unified signal (0000018, ADR-001) — unaffected by this feature. |
| req-003's `TOOL_HOOK_ADAPTER_DEST` change moves the copied adapter from `planifest-framework/hooks/adapters/copilot.mjs` to `.github/hooks/adapters/copilot.mjs` in the *target* (consuming) workspace | Tampering | Low | This is a destination-path correction, not a new write capability — the script already had unrestricted local filesystem write access to the target workspace before this change. The new destination is more isolated (project-local, tool-specific dir) than the old one (which wrote back into the framework's own source tree), a net improvement. |
| req-001/req-002 modify the orchestrator's own approval-gate prose (`planifest-orchestrator/SKILL.md`, `planifest-ship-agent/SKILL.md`) — a self-modification of the pipeline's own gating mechanism | Elevation of Privilege | Low | Already disclosed transparently to the human at P3 (the sandbox's automated security monitor flagged the same edit). Reviewed and confirmed as exactly the deliberate, explicitly-authorized change from this run's own P0 investigation and ADR-001 — not a novel or undisclosed escalation. The change is symmetric (restores a previously-working exception, doesn't grant a new one beyond what P4-P6 already had) and does not touch P9 (Ship), which remains a hard, non-bypassable gate per both the old and new wording. |

## Dependency Audit

No new external dependencies introduced. `execFileSync` and `child_process` are Node.js built-ins, already used elsewhere in this codebase's hook scripts (e.g. these same files already import from `node:fs`, `node:path`, `node:crypto`). No `package.json` exists at the project root — no dependency manifest to audit.

## Secrets Management

No secrets introduced, read, or handled by this feature. `product_id` is a filesystem path, not a credential. No hardcoded values found in any of the 8 modified files.

## Authentication & Authorisation Review

Not applicable — no API surface, no auth strategy in this feature (confirmed in `plan/current/design.md`).

## Input Validation Review

Not applicable in the OpenAPI sense (no API). The one input-adjacent surface is `cwd`, already resolved elsewhere in each hook from `input?.cwd ?? process.cwd()` (pre-existing code, unchanged by this feature) — this feature only adds a new *use* of that already-validated-by-precedent value (passed as a `cwd` option, not shell-interpolated, per the Threat Model row above).

## Network Policy

No new network surface. `product_id` is one additional field added to an existing POST body already sent to the pre-configured `$PLANIFEST_TELEMETRY_URL` — no new endpoint, no new outbound destination.

## Infrastructure as Code Review

Not applicable — no IaC in this feature's stack.

## Risk Register Cross-Reference

| Risk Register ID | Status after implementation |
|---|---|
| R-001 (editing orchestrator gate wording mid-run) | Mitigated as planned — this run's own gate behavior was governed by the build-log P0/ADR-001 record, not a live re-read of the file being edited; verified live: P1, P2, P3, P4 all proceeded under continuous_run without a stop, demonstrating the fix works in practice. |
| R-002 (`copilot.ps1` fix has no live pwsh verification) | Accepted, as planned — remains statically verified only; explicitly logged in `scope.md` → Deferred. |
| R-003 (dispatcher-guard regression risk for other Tier-1 `.ps1` tools) | Open → now assessed Low: the guard change nests `Install-Tier1HookRegistration` (and `Install-BeforeSubmitHookRegistration`) inside an `if ($toolConfig.SettingsFile)` check — any tool config that already had a non-null `SettingsFile` continues to enter that branch exactly as before; only Copilot (no `SettingsFile`) newly skips it, which is the intended fix, not a regression. No other `.ps1` tool config was modified by this feature. |
| R-004 (`execFileSync` subprocess call security) | Mitigated — see Threat Model row above; fixed argument list, no shell, no user-controlled input in the command itself. |

## Summary

Overall risk rating: **Low**

Top actions before production:
1. None blocking. The one deferred item (`copilot.ps1` live `pwsh` verification) is already tracked in `scope.md` as an accepted, documented gap pending environment availability — not a security concern, an environment-availability constraint.
2. Recommend the separately-flagged `cline.sh` bug (unrelated to this feature, discovered as a side effect of req-003) be picked up promptly given it currently blocks `setup.sh all` from completing cleanly — a functional gap, not a security one, but worth prioritizing since it affects every future `setup.sh all` invocation.
3. No critical, high, or medium findings — zero-findings exception applies for the P5 gate.
