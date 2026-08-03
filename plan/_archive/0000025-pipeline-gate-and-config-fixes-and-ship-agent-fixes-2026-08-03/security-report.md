# Security Report - 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes

## Threat Model (STRIDE)

| Threat | Category | Severity | Mitigation |
|---|---|---|---|
| `planifest-overrides/setup-config/{tool}.md` (req-004) commits `backendUrl` and setup flags to git history where they previously lived only in a gitignored marker — if a `backendUrl` value ever embeds basic-auth credentials (`https://user:pass@host`) or an internal-only hostname, that value becomes permanently part of tracked history. | Information Disclosure | Low | Verified in `planifest-framework/setup.sh`'s `write_setup_config_override()`: only `tool`, `flags` (fixed enum of 4 known CLI flag strings), `backendUrl`, and `writtenAt` are written — no token, password, or API-key field exists in the written shape. Consistent with Hard Limit 6 ("No credentials in context"). Residual risk is an adopter manually configuring a credential-bearing URL as their telemetry backend; this is a pre-existing risk for the gitignored marker too (same value was already written there) and is not newly introduced by this feature, only newly made git-tracked. No code change can fully close this — it is a documented adopter-configuration risk, not a defect. |
| Ship-agent's PR-footer opt-in (req-001) is gated by a `planifest-overrides/instructions/` filename scan (`restore-pr-attribution` keyword) — a malicious or careless file in that directory with a matching name could silently re-enable attribution output an adopter didn't want. | Tampering | Low | `planifest-overrides/` is explicitly human-owned (per `planifest-framework/component.yml`'s own exceptions: "Does not write to `planifest-overrides/`"); this is the framework's existing trust boundary for all repo-instruction overrides (e.g. `local-git-only`), not a new one introduced here. No escalation of privilege — the file must already be present in a directory only a human or a human-authorized process writes to. |
| Scope Lock Challenge (req-007) now dispatches 4 parallel `planifest-scope-lock-agent` subagents by default instead of on human opt-in — each subagent reads the feature brief, requirements, and ADRs confirmed so far. | Information Disclosure | Low | No new data is exposed to these subagents beyond what the opt-in path already exposed on request — same skill, same fresh-context isolation, same input scope (`planifest-scope-lock-agent/SKILL.md`'s Invocation Contract unchanged). Only the trigger condition (default vs. opt-in) and cardinality (4 upfront vs. 1 at a time) changed, not the data boundary. |
| Docs-agent's Gate B and other audited skills (req-006) now auto-proceed under `continuous_run` instead of stopping for human confirmation. | Repudiation | Low | The auto-accepted decision is logged to the P6 build log block (per req-006 AC2), preserving an audit trail equivalent to a human's explicit confirmation — this is the same pattern already established and accepted for the orchestrator's own Phase Invocation Table STOP/exception logic, not a new precedent. |

No Spoofing, Denial of Service, or Elevation of Privilege threats identified — this feature has no authentication surface, no network-facing service, and no privilege boundary it crosses (all 7 stories are single-component, `planifest-framework`-internal changes to skill files, setup scripts, and templates).

## Dependency Audit

No new dependencies introduced. `planifest-framework/setup.sh`/`setup.ps1` changes (req-004) use only existing shell/PowerShell built-ins already present in those scripts — no new library, package, or external tool added. Not applicable otherwise (no `package.json`/`go.mod`/equivalent manifest touched).

## Secrets Management

No hardcoded credentials introduced by any of the 7 stories. req-004's `write_setup_config_override()` was read line-by-line (`planifest-framework/setup.sh:1210-1225`) to confirm the written payload is limited to `tool`, `flags`, `backendUrl`, `writtenAt` — no secret-shaped field. Cross-references Risk Register R-004 (status: open → **resolved by this review**, see below).

## Authentication & Authorisation Review

Not applicable — no API, no auth surface in this feature's scope (confirmed in `plan/current/design.md`'s Architecture Layer: "no auth/authz surface").

## Input Validation Review

Not applicable — no API endpoints. The one user-facing input surface is `planifest-overrides/instructions/` filename/keyword matching for the PR-footer opt-in (req-001) and setup-config write (req-004); both operate on human-owned, human-authored files, not untrusted external input.

## Network Policy

Not applicable — no new network-facing service, port, or ingress/egress surface. `backendUrl` (req-004) is a pre-existing telemetry-posting destination, unchanged by this feature — only its storage location changed (gitignored marker → additionally, a tracked file).

## Infrastructure as Code Review

Not applicable — no IaC files exist or are touched by this feature (`design.md` stack: IaC "none").

## Risk Register Cross-Reference

| Risk | Status at P1 | Verified at P5 |
|---|---|---|
| R-004 (setup-config backend-url/flags become git-tracked) | open | **Resolved** — confirmed no secret-shaped field exists in the written payload (see Secrets Management above) |
| R-003 (dual-source-of-truth conflict on interrupted setup) | open | Not a security risk (operational/technical) — mitigation (tracked file as source of truth, reconciled on next run) is a P3 implementation detail confirmed present in `write_setup_config_override`'s fallback-to-existing-marker behavior on write failure; test-0000025-req-004 covers the permission-failure fallback case |
| R-007 (Scope Lock partial-dispatch-failure blocking the batch) | open | Not a security risk — confirmed implemented and tested (`test-0000025-req-007`, partial-failure fallback assertions pass) |
| R-006 (continuous_run audit incompleteness) | open | Not a security risk — audit findings recorded per req-006 AC4 (`test-0000025-req-006`), no gate found in spec-agent/adr-agent/codegen-agent beyond docs-agent's Gate B |
| R-001, R-002, R-005, R-008, R-009 | accepted / open / mitigated | No security dimension — operational/technical/process risks, out of this report's scope |

## Summary

Overall risk rating: **Low**

Top actions before production:
1. None blocking — no critical or high findings. All 4 Low-severity STRIDE entries are either pre-existing trust boundaries this feature doesn't alter, or informational notes about adopter-configuration risk that no code change can fully close.
2. Adopters should be aware (documentation note, not a code fix) that `backendUrl` values should never embed credentials, now that they are git-tracked by default via req-004 — worth a one-line callout in the setup documentation if not already present (non-blocking, can be a future Fast Path).
3. None.
