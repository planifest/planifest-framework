# Security Report - 0000019-self-description-and-session-hygiene-fixes

**Skill:** [security-agent](../skills/planifest-security-agent-SKILL.md)
**Tool:** Claude Code
**Model:** claude-sonnet-5
**Feature:** 0000019-self-description-and-session-hygiene-fixes

---

## Threat Model (STRIDE)

| Threat | Category | Severity | Mitigation |
|---|---|---|---|
| `self-description-check.mjs` reflects README-diagram path tokens verbatim into its CI error output (`structure diagram names "${relPath}", which does not exist...`) | Information Disclosure | Low | The reflected text is exactly what a PR author already wrote into `README.md` in the same diff — publicly visible in the PR anyway. No new information crosses a trust boundary; the script only reports existence/non-existence, never file contents. Not mitigated further — not warranted at this severity. |
| `self-description-check.mjs` calls `existsSync`/`readdirSync` with `join(repoRoot, token)` where `token` is parsed from README.md text, so a crafted diagram line (e.g. `../../../../etc/passwd`) is checked for existence on the CI runner | Tampering / Info Disclosure | Low | `existsSync` returns only a boolean; no file content is ever read by this check. A PR author who could craft such a line already has arbitrary-file-read-adjacent capability via the PR's own CI job regardless (standard GitHub Actions PR-trigger threat model — no secrets are exposed to this job, see below). Not exploitable beyond "confirm a path exists," which is not a meaningful escalation. |
| Shipped hooks' matcher regex changed from `.*component\.json` to `.*component\.yml` in `.github/workflows/planifest.yml`, `planifest-framework/hooks/planifest.yml`, `hooks/pre-push`, `hooks/pre-commit` | Tampering | Low | Reviewed for ReDoS: the pattern is a single greedy `.*` followed by a fixed literal, linear-time, no nested/overlapping quantifiers — not vulnerable. Reviewed for scope widening: the fix is a like-for-like extension substitution: no anchoring change, no broadening of what constitutes a match beyond swapping `.json`→`.yml`. Pre-existing characteristic (unchanged by this diff): the pattern has no end-anchor, so `foo/component.yml.bak` would still match — this is inherited from the original `component.json` version and not introduced or worsened by req-002. Noted, not treated as a new finding. |
| `context-pressure.mjs` envelope field change (`phase: "monitoring"` → `phase: "orchestrator"`) | Tampering | N/A | Pure string-literal change to a value already being sent over the network to the configured telemetry endpoint. No new data crosses the boundary that wasn't already being sent; no new attacker-controlled input involved. |
| Repudiation | Repudiation | N/A | No auth/session/audit-trail surface touched by this batch. |
| Denial of Service via a pathological `README.md` (huge file, many diagram lines) fed to `self-description-check.mjs` | Denial of Service | Low | All parsing is single-pass, linear-time string/regex operations (`split`, simple anchored regexes, one `readdirSync` bounded by the actual `planifest-framework/` directory size). No recursive or exponential-time construct. A multi-megabyte README would slow the check proportionally, not catastrophically. |
| Elevation of Privilege | Elevation of Privilege | N/A | No privilege boundary in this batch — no auth, no role model, no new CI permissions requested (`self-description-check` job in `.github/workflows/planifest.yml` uses only `actions/checkout@v4`, no `secrets:` block, no write permissions requested). |

**Shipped-hooks-specific check (explicitly requested):** `hooks/pre-push` and `hooks/pre-commit` build `CHANGED_FILES`/`COMMIT_MESSAGES`/`STAGED_FILES` via `$(git diff --name-only ...)` / `$(git log ... --format="%s")`, then always reference them as `"$CHANGED_FILES"` (quoted) inside `echo "$VAR" | grep -qE "<static pattern>"`. The grep pattern itself is a fixed literal in every call — repo content (filenames, commit messages) is never interpolated into the pattern, only piped as quoted stdin to `grep`. req-002/req-003 changed only the pattern's literal text (`component\.json`→`component\.yml`) and surrounding echo strings — the quoting and sourcing structure is untouched. No new shell-injection surface.

---

## Dependency Audit

No new dependencies. `self-description-check.mjs` imports only Node built-ins (`node:fs`, `node:path`) — no `package.json` addition, no third-party package, no version to audit.

---

## Secrets Management

No secrets touched. The `self-description-check` CI job added to `.github/workflows/planifest.yml` has no `env:`/`secrets:` block and needs none — it only reads `README.md` and the local filesystem. No hardcoded credentials introduced anywhere in this batch.

---

## Authentication & Authorisation Review

Not applicable — no API, no auth surface in this batch.

---

## Input Validation Review

Not applicable in the API sense (no API). The one genuinely new "parses external-ish content" surface is `self-description-check.mjs` parsing `README.md`'s Markdown structure — covered under Threat Model above; low severity, no exploitable path.

---

## Network Policy

Unchanged. The only network call in scope is the pre-existing telemetry `/emit` POST (`context-pressure.mjs`), whose only change this batch is the `phase` field value, not its network behaviour.

---

## Infrastructure as Code Review

Not applicable — no IaC in this batch.

---

## Risk Register Cross-Reference

Per `plan/current/risk-register.md`:

| Risk | Security-relevant? | Status after implementation |
|---|---|---|
| R-001 (component.yml regex could open a real gap) | Yes | Mitigated — two new tests (`test-0000019-req-002-component-yml-matcher.sh`) assert both the pass case and the fail case against the shipped hooks directly; both pass. Confirmed RED against the pre-fix hooks, GREEN after. |
| R-002 (context-clear logic could disrupt session continuity) | Operational, not security | Not this report's scope — covered by P4 validation. |
| R-003 (single-wave context load) | Operational, not security | Not this report's scope. |
| R-004 (self-description-check ordering vs req-001) | Operational, not security | Mitigated — implemented after req-001, verified clean. |
| R-005 (context-pressure phase-mapping semantic choice) | Low security relevance | Accepted per ADR-002; no exploitable surface, purely a categorisation choice. |
| A-001/A-002/A-003 (assumptions) | Not security-relevant | No change. |

No open, security-relevant risk from the register remains unmitigated.

---

## Summary

**Overall risk rating: Low.**

This batch has no new attack surface of consequence: no auth, no new dependencies, no secrets, no IaC, and the one new script (`self-description-check.mjs`) does read-only filesystem existence checks with no file-content exposure and no shell/eval surface. The shipped-hooks regex change was specifically checked for ReDoS and scope-widening and found clean.

Top actions before shipping:
1. None blocking. No critical or high findings.
2. Optional, non-blocking, out of this batch's scope: consider anchoring the `component\.yml` matcher (`\.yml$` rather than an unanchored `component\.yml`) in a future pass — pre-existing characteristic, not introduced by this feature, not worth expanding scope for here.
3. None further.
