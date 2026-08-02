---
title: "Requirement: req-003 - Copilot Setup Self-Copy Fix"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-003 - Copilot Setup Self-Copy Fix

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000023-framework-pipeline-fixes
**Source:** US-003
**Priority:** must-have

## User Story

> One requirement doc = one user story.

As a human running `setup.sh copilot`, I want the command to exit 0, so that Copilot tool setup actually works.

## Functional Requirements

- In `planifest-framework/setup/copilot.sh`, change `TOOL_HOOK_ADAPTER_DEST` from `"planifest-framework/hooks/adapters/copilot.mjs"` to a project-local path consistent with every other Tier-1 tool, `.github/hooks/adapters/copilot.mjs` (mirrors `cursor.sh`'s `TOOL_HOOK_ADAPTER_DEST=".cursor/hooks/adapters/cursor.mjs"`). Today `TOOL_HOOK_ADAPTER_SRC="hooks/adapters/copilot.mjs"` and `TOOL_HOOK_ADAPTER_DEST="planifest-framework/hooks/adapters/copilot.mjs"` resolve to the identical absolute path once `install_tier1_hooks()` (`planifest-framework/setup.sh`, function at line 403) prepends `$SCRIPT_DIR` / `$PROJECT_ROOT` respectively, so its `cp "$adapter_src" "$adapter_dest"` (line 425) fails with BSD/macOS cp's "identical, not copied" (exit 1), and `setup.sh` runs under `set -euo pipefail`, aborting every invocation of `setup.sh copilot` and `setup.sh all`.
- In the same file, update both `"command"` fields in the `.github/hooks/planifest.json` heredoc (currently `node planifest-framework/hooks/adapters/copilot.mjs` at lines 32 and 38) to `node .github/hooks/adapters/copilot.mjs`, so the registered hook invokes the copied destination rather than reaching back into `planifest-framework/` source.
- In `planifest-framework/setup/copilot.ps1`, add the equivalent Tier-1 keys to the tool-config hashtable, using the exact key names `Install-Tier1Hooks` / `Install-Tier1HookRegistration` consume in `planifest-framework/setup.ps1` (confirmed by reading `cursor.ps1`'s working hashtable and `setup.ps1` lines ~556–637 and ~1206–1220):
  - `HookAdapterSrc  = 'hooks\adapters\copilot.mjs'`
  - `HookAdapterDest = '.github\hooks\adapters\copilot.mjs'`
  - `HooksInstallDir = '.github\hooks'`

  `copilot.ps1` currently has none of these keys — it is a bare `@{ SkillsDir; WorkflowsDir; BootFile; BootTemplate; Tier = 1 }` hashtable with no `HookAdapterSrc`, so `setup.ps1`'s dispatcher guard `if ($toolConfig.Tier -eq 1 -and $toolConfig.HookAdapterSrc)` (line 1206) is never entered for Copilot: Tier-1 hook adapter installation is silently skipped for Copilot on Windows/PowerShell today (no crash, but no adapter/enforcement/telemetry scripts copied into `.github/hooks/` either).
- **Dispatcher guard finding (new, found while investigating this requirement — not previously logged):** adding `HookAdapterSrc`/`HookAdapterDest` to `copilot.ps1` is not sufficient by itself. `setup.ps1`'s single guard at line 1206 calls **both** `Install-Tier1Hooks` and `Install-Tier1HookRegistration` unconditionally together. `Install-Tier1HookRegistration` requires `-SettingsRel $toolConfig.SettingsFile`, and Copilot — like on the bash side, where the equivalent step is separately guarded on `[ -n "${TOOL_SETTINGS_FILE:-}" ]` at `setup.sh` line 1107–1108 — has no `SettingsFile` key, because Copilot registers its hook via its own `.github/hooks/planifest.json` shape (written by `Install-CopilotAdapter`, not the generic Claude-Code-style `PreToolUse` JSON `Install-Tier1HookRegistration` writes). Without a matching guard, adding the two keys above would make `setup.ps1` call `Install-Tier1HookRegistration` with `$SettingsRel = $null`, a latent bug that does not exist on the `.sh` side (whose two steps are independently gated). This requirement therefore also covers: adding a `SettingsFile`-presence condition around the `Install-Tier1HookRegistration` call in `setup.ps1` (~line 1206–1220), mirroring `setup.sh`'s two-guard structure, so Copilot gets `Install-Tier1Hooks` (adapter + enforcement + telemetry scripts copied) without incorrectly invoking `Install-Tier1HookRegistration`.
- In `planifest-framework/setup.ps1`'s `Install-CopilotAdapter` function (~line 1055–1075), update both hardcoded `command` strings (`"node planifest-framework/hooks/adapters/copilot.mjs"`, appearing twice) to `"node .github/hooks/adapters/copilot.mjs"`, matching the `.sh` heredoc fix and keeping the registered command in lockstep with the new copied destination.
- Add a regression test under `planifest-framework/tests/regression/` (house style: `mktemp -d` disposable workspace, `cp -r` the framework in, `git init`, run the real script, assert on exit code and resulting files — see `test-0000020-req-008-install-time-marker-write.sh` for the pattern), named `test-0000023-req-003-copilot-setup-self-copy.sh`, covering:
  - `bash planifest-framework/setup.sh copilot` exits 0 in a fresh workspace.
  - `bash planifest-framework/setup.sh all` exits 0 in a fresh workspace.
  - `.github/hooks/adapters/copilot.mjs` exists in the target workspace after install.
  - The original `planifest-framework/hooks/adapters/copilot.mjs` in the target workspace's copy is unmodified by the install (the copy went outward, not in-place).
  - `.github/hooks/planifest.json`'s two `command` fields both read `node .github/hooks/adapters/copilot.mjs`.
  - A static (grep-based) check that `copilot.ps1` declares `HookAdapterSrc`, `HookAdapterDest`, and `HooksInstallDir`, and that `setup.ps1`'s `Install-CopilotAdapter` no longer contains the stale `planifest-framework/hooks/adapters/copilot.mjs` command string — following the same static-check pattern used for `.ps1` parity in part (e) of `test-0000020-req-008-install-time-marker-write.sh`, since no `pwsh` runtime is available in this environment.
- The `.ps1` fix (including the dispatcher guard change) is verified statically only in this environment — no `pwsh` runtime available, consistent with the pre-existing note in `src/setup-hook-integration/component.yml`'s quirks list (Q-006: "Write-SetupFlagsMarker (0000020) verified statically only in this environment, no pwsh available"). This is a deferred live verification, not a missing requirement — it stays open until a Windows/`pwsh`-capable environment is available to run `setup.ps1 copilot` for real.

## Acceptance Criteria
- [x] `setup.sh copilot` exits 0 on a fresh disposable workspace (verified by the new regression test)
- [ ] `setup.sh all` (which includes the copilot target) also exits 0 — **NOT MET**, but not for a req-003 reason: `setup.sh all` still exits 1 because of a separate, pre-existing, out-of-scope bug in `setup/cline.sh` (path collision between `TOOL_SKILLS_DIR` and `TOOL_BOOT_FILE`), unmasked now that copilot's own crash no longer aborts the `all` run first. Isolated assertions in the same test prove req-003's own fix holds inside the `all` run regardless. See `plan/current/scope.md` → "Discovered During P3".
- [x] The adapter file lands at `.github/hooks/adapters/copilot.mjs` in the target workspace, not back in `planifest-framework/`
- [x] `.github/hooks/planifest.json`'s two `command` fields reference the new destination path (`.github/hooks/adapters/copilot.mjs`), consistent with each other and with where the file was actually copied
- [x] `copilot.ps1` declares `HookAdapterSrc`, `HookAdapterDest`, and `HooksInstallDir` — the exact keys `Install-Tier1Hooks`/`Install-Tier1HookRegistration` consume in `setup.ps1`, confirmed by reading `setup.ps1` and `cursor.ps1` rather than guessed
- [x] `setup.ps1`'s dispatcher no longer calls `Install-Tier1HookRegistration` for a tool config that has `HookAdapterSrc` but no `SettingsFile` (i.e. Copilot) — the guard mirrors `setup.sh`'s independent two-condition structure
- [x] `Install-CopilotAdapter` in `setup.ps1` registers `node .github/hooks/adapters/copilot.mjs`, not the stale `planifest-framework/...` path
- [x] New regression test `test-0000023-req-003-copilot-setup-self-copy.sh` is added and passes for the bash path (13/14 assertions; the 1 documented exception above); the `.ps1` path (including the dispatcher guard change) is verified statically only, pending a `pwsh`-capable environment

## Dependencies
- None — self-contained within `planifest-framework/setup/` and `planifest-framework/setup.ps1`.

## Background

Every other Tier-1 tool points `TOOL_HOOK_ADAPTER_DEST` at a project-local path under the target tool's own directory (e.g. `.cursor/hooks/adapters/cursor.mjs`), never back into `planifest-framework/`. Copilot's config is the sole outlier, and on `.sh` that outlier is a hard crash (source and destination resolve to the same absolute path, so `cp` refuses and `set -euo pipefail` aborts the whole script) while on `.ps1` the same incompleteness instead manifests as a silent skip (no `HookAdapterSrc` key means the Tier-1 install block is never entered at all). Fixing both sides to the same `.github/hooks/adapters/copilot.mjs` convention, and updating every hardcoded reference to the old in-place path (the `.sh` heredoc and `.ps1`'s `Install-CopilotAdapter`) to match, closes both the crash and the silent gap with one consistent destination.
