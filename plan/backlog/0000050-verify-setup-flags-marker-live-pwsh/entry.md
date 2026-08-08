---
title: "Backlog Entry: 0000050 - Verify Write-SetupFlagsMarker with live pwsh execution"
summary: "TD-007: Write-SetupFlagsMarker (setup.ps1) was only checked statically and needs a live pwsh run before external release."
status: "open"
---
# Backlog Entry: 0000050 - Verify Write-SetupFlagsMarker with live pwsh execution

**Source feature:** 0000020-setup-refresh-skill
**Source phase:** P6 (docs-agent `recommendations.md`, feature archived — backfilled retroactively by req-006)
**Deferral source:** tech debt
**Date filed:** 2026-08-08

---

## Problem

`0000020-setup-refresh-skill`'s recommendations recorded tech debt item TD-007. See `plan/_archive/0000020-setup-refresh-skill-2026-08-01/recommendations.md` ("Tech Debt" table): `Write-SetupFlagsMarker` (in `setup.ps1`) is "unverified by live execution in this codebase's development environment" — impact if ignored: "A schema or encoding bug specific to PowerShell's `ConvertTo-Json` could ship undetected."

## Suggested Action

Run a live `pwsh` invocation of `Write-SetupFlagsMarker` (setup.ps1) on Windows or a pwsh-enabled CI runner, per the suggested fix in the source row and the related REC-001 in the same `recommendations.md`. Also see `src/setup-hook-integration/docs/quirks.md` Q-006 for the specific `ConvertTo-Json` depth/encoding quirk this verification targets.

## Why Deferred

No PowerShell runtime was available in the development environment when `0000020` shipped; the bash side was live-tested and passing, but the PowerShell side carried residual risk that this tech debt item flags for a future pass with pwsh access.
