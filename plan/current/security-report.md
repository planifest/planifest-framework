# Security Report - 0000020-setup-refresh-skill

## Threat Model (STRIDE)

| Threat | Category | Severity | Mitigation |
|---|---|---|---|
| Deletion allowlist (`CLAUDE.md`/`AGENTS.md`) enforced only by prose instructions in `planifest-refresh-setup/SKILL.md`, no deterministic backstop against agent error or a maliciously crafted repo file inducing a wider deletion | Tampering / Elevation of Privilege | High (found) -> Low (mitigated) | **Fixed during this review.** Deletion now runs through `planifest-framework/scripts/refresh-delete-boot-files.sh` / `.ps1`, which hardcode the exact two filenames in executable code and take no arguments (verified: `test-0000020-req-004-boot-file-deletion-script.sh`, 13 assertions, including a static check that no argument-reading pattern exists in the script). `SKILL.md` Step 6 now instructs invoking the script, not a freeform `rm`. |
| `.planifest-setup-flags` for the `copilot` tool written outside any gitignored directory (`.github/skills/` is ignored, `.github/` itself is not), risking accidental commit of tool name, flag names, and telemetry backend URL | Information Disclosure | Medium (found) -> Low (mitigated) | **Fixed during this review.** Added a global `.planifest-setup-flags` gitignore pattern (matches at any depth), covering `copilot` and `opencode` (whose tool directory was not gitignored at all) in addition to the tools already covered by their wholesale-ignored directories. Verified live for `copilot`, `opencode`, and `claude-code` (`git check-ignore -v` confirms all three). |
| A tampered or stale `.planifest-setup-flags` marker file is read at "high confidence" and could mislead the human on the loop into confirming a flag set (e.g. a malicious `--backend-url`) they would otherwise question | Tampering | Low | REQ-003/ADR-003's mandatory confirmation gate always displays every flag, its source, and the exact command before any action, in every run including high-confidence ones. Residual risk is human-factors (confirmation fatigue), not a missing technical control; not further mitigated in this feature. |
| Marker file (`.planifest-setup-flags`) contains a `backendUrl` value that could reveal an internal telemetry endpoint if the file were ever exposed | Information Disclosure | Low | No credentials are stored (see Secrets Management below); the gitignore fix above is the primary mitigation. Residual exposure is limited to a URL, not a secret. |
| Setup re-invocation failure leaves the repo mid-refresh (boot files deleted, setup not yet complete) | Denial of Service (local, self-inflicted) | Low | REQ-009/REQ-010 write recoverable state to the marker file before deletion and detect/recover from this exact state on the next invocation; not a remotely triggerable DoS, purely a local interrupted-process scenario already designed for. |
| Spoofing (tool impersonation, e.g. a repo signals `.claude/` presence to trick the skill into "refreshing" the wrong tool) | Spoofing | Low | Not applicable in a meaningful sense: the human on the loop always names or confirms the target tool (REQ-001/ADR-004) and confirms the exact command before execution (REQ-003); there is no cross-trust-boundary actor who could benefit from this. |
| Repudiation (no audit trail of who ran a refresh or what flags were applied) | Repudiation | Low | Not applicable: this is a local, single-operator CLI tool with no multi-user audit requirement (see `plan/current/operational-model.md`, confirmed design Architecture Layer: no regulated data, standard console output). |

## Dependency Audit

No new external dependencies introduced (confirmed design Constraints; `execution-plan.md` NFRs). `planifest-refresh-setup/SKILL.md` is Markdown; `refresh-delete-boot-files.sh`/`.ps1` use only Bash/PowerShell builtins. No `package.json`, `requirements.txt`, or equivalent manifest changed. Nothing to audit against `library-standards/`.

## Secrets Management

No credentials are read, stored, or transmitted by this feature. `.planifest-setup-flags` records flag names, a tool identifier, a timestamp, and (when telemetry is enabled) a backend URL, none of these are secrets. Confirmed no hardcoded credentials in `setup.sh`, `setup.ps1`, `refresh-delete-boot-files.sh`/`.ps1`, or `planifest-refresh-setup/SKILL.md` (manual review; no API keys, tokens, or passwords appear in any file this feature touched).

## Authentication & Authorisation Review

Not applicable. No API is exposed or consumed by this feature (confirmed design: "not applicable" for API versioning; no OpenAPI spec produced).

## Input Validation Review

Not applicable in the traditional sense (no HTTP endpoints). The closest analogue, the `--backend-url` value accepted by `setup.sh`/`setup.ps1` and echoed into the marker file, predates this feature (existing flag, unchanged parsing) and is not re-validated by this feature beyond what already exists.

## Network Policy

Not applicable. No network calls are introduced (the marker file is purely local filesystem state; `--backend-url` is stored, not dialed, by this feature's code).

## Infrastructure as Code Review

Not applicable. No IaC files exist for this feature (confirmed design: IaC "none").

## Findings Fixed During This Review

1. **Deletion allowlist hardening** (`planifest-framework/scripts/refresh-delete-boot-files.sh`/`.ps1`), closes the High Tampering/Elevation-of-Privilege finding above.
2. **`.planifest-setup-flags` gitignore gap** (`.gitignore`), closes the Medium Information Disclosure finding above.

## Findings Deferred (Out of Scope, Filed to Backlog)

- **`setup.sh copilot` / `setup.ps1 copilot` crash on every invocation** (pre-existing `TOOL_HOOK_ADAPTER_DEST` self-copy bug in `setup/copilot.sh`, discovered while verifying the gitignore fix across all tools), this is an availability/correctness defect, not a security vulnerability, and is unrelated to this feature's scope. Filed as `plan/backlog/0000027-setup-sh-copilot-broken-self-copy/entry.md`.

## Summary

Overall risk rating: **Low** (both findings raised to High/Medium severity during this review were fixed within this pipeline run; no unmitigated finding above Low remains).

Top actions before shipping:
1. None blocking, both actionable findings (deletion allowlist, gitignore gap) are fixed and test-covered in this same feature.
2. Recommend prioritising backlog entry `0000027` (copilot setup crash) separately, given its severity as a functional defect, even though it is not a security finding.
3. Recommend a live `pwsh` verification of `Write-SetupFlagsMarker` and `refresh-delete-boot-files.ps1` on Windows or a pwsh-enabled CI runner before external release, per `src/setup-hook-integration/docs/quirks.md` Q-006 (no PowerShell runtime was available in this development environment; both `.ps1` additions were checked statically only).
