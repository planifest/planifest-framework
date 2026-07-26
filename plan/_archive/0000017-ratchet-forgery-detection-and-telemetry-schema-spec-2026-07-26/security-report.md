# Security Report - 0000017-ratchet-forgery-detection-and-telemetry-schema-spec

**Skill:** planifest-security-agent
**Tool:** Claude Code
**Model:** claude-fable-5
**Date:** 2026-07-26
**Scope reviewed:** all changes on `feat/0000017-...` since P2 gate (commits `758e645`..`40d96df`): `ratchet-check.mjs`, 3 context-mode `.mjs` hook ports, `setup.sh`/`setup.ps1` wiring, `promote-to-regression.sh` promotion, skill/template text changes, all new test suites.

## Threat Model (STRIDE)

| Threat | Category | Severity | Mitigation |
|---|---|---|---|
| Agent forges a `.ratchet-approve` entry to self-authorize weakening a governance artifact | Elevation | High (inherent) | Mitigated: instruction-gated write (ADR-001), immediate-dedicated-commit rule, and the same-uncommitted-changeset backstop in `ratchet-check.mjs` (`isUncommitted()`, `git status --porcelain` via `execFileSync` arg-vector). Uncommitted marker → write blocked with explicit message. Test-covered (19 assertions, `test-0000017-req-002-ratchet-approve.sh`). |
| Malformed/crafted marker line bypasses parsing | Tampering | Medium | Mitigated: `parseApprovalLine()` requires exactly 3 pipe-delimited non-empty fields; anything else (including extra `\|`) is treated as no-approval — fails closed for the approval, fails open only for the session. |
| Shell injection via marker path passed to git | Tampering | High (if present) | Not present: `execFileSync("git", [...args])` argument-vector invocation, path passed after `--` separator, no shell string interpolation anywhere in `ratchet-check.mjs` (verified: only `RegExp.exec` matches, no `exec/spawn/eval`). |
| Repudiation of an approval (who approved, why) | Repudiation | Medium | Mitigated: consumption copies `path \| reason \| timestamp` verbatim (reason capped 500 chars) to `plan/ratchet-audit-log.md`; marker file itself is git-tracked. |
| Untrusted tool input echoed into model-visible deny reasons (`command`, `pattern`, `path`, `url` interpolated verbatim by all 3 context-mode hooks) | Info Disclosure / prompt surface | Low | Not newly introduced — exact parity with the prior `.sh` implementations; reasons are advisory redirect text. Accepted as-is; flagged for a future hardening pass if desired. |
| Hook denial-of-enforcement via missing Node runtime | DoS (of enforcement, not session) | Medium | Mitigated by design: fail-open is the framework convention, but no longer silent — setup-time warning in `setup.sh`/`setup.ps1` AND per-invocation stderr message wired into the hook command (`\|\| echo ...`). Test-covered (`test-0000017-req-004-cross-platform-hooks.sh`). |
| Spoofing of hook identity in settings.json wiring | Spoofing | Low | Command strings are constructed from setup-internal constants (`hooks_dir`, `script_name`) — no user-supplied input reaches `context_mode_hook_command()` / `Get-ContextModeHookCommand`. |

## Dependency Audit

No dependency manifests exist or were added in this release. The `jq` runtime dependency was **removed** (req-004) — net reduction of the external-tool surface. Sole remaining runtime dependency: Node.js, already required by every other framework hook.

## Secrets Management

No hardcoded credentials, keys, or tokens in any changed file. The single scan hit (`execution-plan-guide.md:40`) is a documentation example of writing a functional requirement about a login endpoint — not a credential. No secrets are read, stored, or transmitted by any code in this release.

## Authentication & Authorisation Review

Not applicable — no API surface. The authorization-relevant mechanism in this release is the ratchet-approve human-approval flow, covered under STRIDE above: the "authentication" of an approval is the combination of explicit in-chat human instruction (procedural), a dedicated committed marker (structural), and hook-level backstop verification (technical).

## Input Validation Review

- `ratchet-check.mjs`: marker lines strictly parsed (exactly 3 non-empty pipe-delimited fields, CR-stripped); malformed → no-approval; reason truncated at 500 chars before audit-log write, per req-002's Input Validation section. Verified by tests.
- Context-mode `.mjs` hooks: stdin JSON parsed inside try/catch; parse failure → exit 0 fail-open (block-bash) or generic-placeholder deny (block-grep/webfetch) — matches prior `.sh` behavior. No dynamic execution, no filesystem writes, no network calls in any of the 3 hooks (verified by scan).

## Network Policy

Not applicable — nothing in this release opens ports, listens, or makes network calls. (The telemetry hooks are pre-existing and unchanged.)

## Infrastructure as Code Review

Not applicable — no IaC in this release.

## Risk Register Cross-Reference

| Register entry | Status after implementation |
|---|---|
| R-002 (backstop regression would reopen forgery gap) | Mitigated — backstop behavior including the explicit message is test-covered; regression pack additionally carries the 0000016 ratchet suite (updated to the new marker format) |
| R-004 (only one of the two missing-runtime messages implemented) | Mitigated — both setup-time and runtime messages implemented in both `setup.sh` and `setup.ps1`, test-asserted |
| A-001 (discovery relocation might need new scanning logic) | Resolved as assumed — relocation sufficed, no new scanning capability was needed |
| A-002 (backstop message might need a detection-logic rewrite) | Resolved as assumed — message added at the consumption-outcome layer, detection logic unchanged |
| R-001, R-003, R-005 | Process/scope risks, not code-security — unchanged, tracked in the register |

## Summary

Overall risk rating: **Low**

No critical, high, or medium findings requiring action. Low/informational notes:

1. (Low) Deny reasons echo untrusted tool input verbatim into model-visible text — pre-existing parity behavior, candidate for a future sanitization pass, not a regression.
2. (Informational) A human reason containing a `|` character invalidates the approval line (strict 3-field parse) — fails in the safe direction; worth a one-line mention in approver-facing docs at P6.
3. (Informational) The audit-log append is best-effort (`try/catch` swallow) — a failed write does not block consumption; acceptable because the git-tracked marker and run log independently record the approval.

Top actions before production: none blocking. Items 1–2 above are optional doc/hardening follow-ups.
