---
title: "Security Report - 0000007-agent-optimisation"
status: "complete"
date: "04 May 2026"
---
# Security Report — 0000007-agent-optimisation

## Threat Model (STRIDE)

| Threat | Category | Severity | Mitigation |
|--------|----------|----------|------------|
| Crafted `.planifest-manifest` causes `rm -rf` on arbitrary path | Tampering | Low | Manifest is written by setup.sh itself; attack requires prior write access to skills directory — which already grants arbitrary damage potential. No additional exposure. |
| optimise-agent skill could be prompted to suggest removal of security-load-bearing content | Tampering | Low | Skill hard limit explicitly prohibits suggesting removal of load-bearing content; suggestions require explicit human confirm; skill never modifies files. |
| All other STRIDE categories | N/A | None | No auth, no network surface, no PII, no credentials, no IaC in this feature. |

## Dependency Audit

No new external dependencies introduced. All changes are:
- Markdown files (no execution)
- Bash/PowerShell modifications to existing setup scripts
- A new bash test file using only built-in shell primitives

No CVEs applicable. No abandoned or overly-permissive packages added.

## Secrets Management

No secrets introduced or handled. The `optimise-agent` skill explicitly states it never writes files and cannot exfiltrate data. The `language-quirks-en-gb.md` and `telemetry-standards.md` standards files contain no sensitive information.

## Authentication & Authorisation Review

Not applicable — no API endpoints or authentication surfaces introduced.

## Input Validation Review

**setup.sh / setup.ps1 — manifest path handling:**

The `.planifest-manifest` file is read during re-runs and each listed path is passed to `rm -rf` (bash) or `Remove-Item -Recurse -Force` (PowerShell). There is no explicit validation that paths are within the skills directory.

**Assessment:** Low risk. The manifest is always written by the same setup script in the same invocation that reads it; entries are created from `$skills_dir/*/` glob expansion, so they are always children of the skills directory. To exploit this an attacker would need write access to `$skills_dir/.planifest-manifest` — a location they would already need to tamper with the skills directory directly. No incremental attack surface is introduced.

**Recommended hardening (non-blocking):** Add a prefix check in setup.sh before each `rm -rf` call:
```bash
if [[ "$dir_path" == "$skills_dir"/* ]]; then rm -rf "$dir_path"; fi
```
This would eliminate the theoretical risk entirely at minimal cost. Recorded as a tech debt item.

## Network Policy

Not applicable — no network configuration introduced.

## Infrastructure as Code Review

Not applicable — no IaC files introduced.

## Summary

Overall risk rating: **Low**

No critical or high findings. The one medium-low hardening opportunity (manifest path prefix check) is non-blocking and recorded as tech debt.

Top actions before production:
1. Optional hardening: add `$skills_dir/*` prefix guard in setup.sh/setup.ps1 manifest cleanup loop (non-blocking).
