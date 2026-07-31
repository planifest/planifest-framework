# Security Report - 0000018-telemetry-emission-consistency

## Threat Model (STRIDE)

| Threat | Category | Severity | Mitigation |
|---|---|---|---|
| A misconfigured `--backend-url` (e.g. `https://user:token@host/emit`) causes an embedded credential to surface in a fetch error message, which `recordTelemetryFailure()` writes verbatim into `plan/.telemetry-failures/<slug>.json` — a directory that is NOT in `.gitignore` (`planifest-framework/hooks/telemetry/emit-phase-start.mjs:100`, `:118`, checked against `/Users/martinmayer/d/planifest/framework/.gitignore`) — so a broad `git add -A`/`git add .` could commit it | Information Disclosure | Low | Not mitigated. Default `BACKEND_URL="http://localhost:3741"` (`setup.sh:22`) has no credentials, so this requires an unusual human-supplied `--backend-url`; still a real path with no redaction or truncation on `error_message` (only the *filename* slug is truncated to 60 chars, `emit-phase-start.mjs:102` — the JSON field itself is not, `emit-phase-start.mjs:100,134`). Recommend: either add `plan/.telemetry-failures/` to `.gitignore`, or redact userinfo from any URL substring before writing `error_message` to disk. |
| A pipeline run with telemetry enabled but the `structured-telemetry-mcp` backend permanently down accumulates failure markers under `plan/.telemetry-failures/` indefinitely if a human always answers "proceed without telemetry" | Denial of Service (self, low-severity) | Low | Mitigated by design: req-003's marker deletion happens "once acknowledged" (`planifest-orchestrator/SKILL.md:1124`), and `occurrences`/`last_seen` fields prevent unbounded file growth per root cause — bounded by number of distinct root causes, not by call count. No action needed. |
| A crafted/adversarial hook error message could theoretically break the marker filename via path traversal (e.g. `../../etc/passwd` fragments in `error.message`) | Tampering | Low | Mitigated. `fileSlug` generation (`emit-phase-start.mjs:109-112`) splits on `"::"`, then strips every character outside `[a-zA-Z0-9_-]` per segment before rejoining — `/`, `.`, and `\` cannot survive into the final path. Confirmed by code inspection; no traversal is possible in the current implementation. |
| `setup.sh`'s removal of the `--context-mode-mcp` AND-condition (`setup.sh:1132-1136`) could theoretically install telemetry hooks with looser gating than intended, widening what triggers outbound network calls | Elevation of Privilege | Low | Not a privilege change — the hooks were already gated correctly by `STRUCTURED_TELEMETRY_MCP`; the removed condition only ever *prevented* correct installation (the bug this feature fixes), it never added a missing check elsewhere. No new attack surface introduced. |
| Repudiation: a human answers "proceed without telemetry" for a masked failure and later disputes that they were asked | Repudiation | Low | Mitigated. `planifest-orchestrator/SKILL.md:1123` requires the answer to be recorded as a durable `Telemetry` line in `build-log.md`, which is archived at P7 — an auditable record survives the session. |

## Dependency Audit

No new dependencies introduced. `req-002`'s hooks use only Node built-ins (`node:fs`, `node:os`, `node:path`, `node:crypto`) already used by the pre-existing hook files. `setup.sh`/`setup.ps1` changes are pure conditional-logic edits — no new external tool invocations. No dependency audit findings.

## Secrets Management

No hardcoded credentials found in any changed file (`setup.sh`, `setup.ps1`, the 3 hook `.mjs` files, all 9 edited `SKILL.md` files, `telemetry-standards.md`, `build-log.template.md`). `PLANIFEST_TELEMETRY_URL` is read from the environment, never hardcoded. See the Information Disclosure finding above for the one path by which a *human-supplied* credential-bearing URL could leak into a git-visible file — this is a configuration risk, not a hardcoded secret in this codebase.

## Authentication & Authorisation Review

Not applicable — this feature adds no API, no new auth surface (confirmed by design.md's Architecture Layer: "no new auth/authz surface").

## Input Validation Review

Not applicable — no API endpoints. The one user-influenced input into new logic is `err.message`/`err.name` from a failed `fetch()` call, handled defensively: wrapped in `String(...)`, sanitized before use in a filename, and only ever written to a local JSON file (never interpolated into a shell command, HTML, or query). No injection vector found.

## Network Policy

No new network surface. The 3 hooks make the same outbound `fetch(`${BACKEND_URL}/emit`)` POST call that existed prior to this feature — this feature only changes what happens *after* that call fails (marker write instead of pure swallow) and which flag gates the hook's installation. No new ports, no new listeners.

## Infrastructure as Code Review

Not applicable — no IaC files in scope for this feature.

## Summary

Overall risk rating: **Low**

Top actions before production:
1. Add `plan/.telemetry-failures/` to `.gitignore`, or redact URL userinfo from `error_message` before writing markers to disk — closes the one identified (low-probability, human-configuration-dependent) information-disclosure path.
2. No other actions required — all other STRIDE categories assessed as mitigated or not applicable.
3. (Optional, non-blocking) Consider documenting the `--backend-url` flag's expectation that it never carry embedded credentials, in `setup.sh`'s `--help` output or `telemetry-standards.md`.
