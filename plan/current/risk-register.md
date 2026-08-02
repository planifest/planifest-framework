---
title: "Risk Register - Framework Pipeline Fixes"
summary: "Technical, operational, and security risks with their mitigations."
status: "active"
version: "0.1.0"
---
# Risk Register - Framework Pipeline Fixes

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md) (updated by any agent that identifies a new risk)
**Feature:** 0000023-framework-pipeline-fixes
**Version:** 0.23.0
**Overall Risk Level:** low

## Risks

| ID | Category | Description | Likelihood | Impact | Mitigation | Status |
|----|----------|------------|------------|--------|-----------|--------|
| R-001 | operational | Editing `planifest-orchestrator/SKILL.md`'s gate wording (req-001) while a pipeline is actively running under `continuous_run` in this very session | low | medium | This run's own P1-P6 gate behavior is governed by the build-log P0 exchange recording the human's intended (fixed) behavior, not by a live re-read of the file being edited; the fix takes effect for future sessions once committed | mitigated |
| R-002 | technical | `copilot.ps1` fix (including the dispatcher-guard change) has no live verification — no `pwsh` runtime in this environment | medium | low | Static review, grep-based regression checks, structural parity with the working `.sh` path and other working `.ps1` tool configs (`cursor.ps1`); explicitly logged as deferred verification (see Scope → Deferred) | accepted |
| R-003 | technical | `setup.ps1`'s `Install-Tier1HookRegistration` dispatcher guard fix (found during req-003 investigation, not part of the original backlog entry) could regress hook registration for another Tier-1 `.ps1` tool that *does* have `SettingsFile` set, if the guard condition is written incorrectly | low | medium | Guard mirrors `setup.sh`'s existing, working two-condition structure exactly (Tier==1 check separate from SettingsFile-presence check); regression test statically confirms `copilot.ps1` gains the keys without asserting on other tools' behavior, so a P4 full regression-suite run (all `.sh`/`.ps1` static checks) is the real backstop | open |
| R-004 | security | `getProductId`'s `execFileSync("git", [...])` call in the telemetry hooks introduces a new subprocess invocation in a hook path | low | low | Fixed argument list (`["rev-parse", "--show-toplevel"]`), no user-controlled input passed to the shell, `execFileSync` (not `exec`) avoids shell interpretation entirely; consistent with existing subprocess patterns already in these hook files | mitigated |

## Assumptions Logged as Risks

| ID | Assumption | Impact if Wrong | Status |
|----|-----------|----------------|--------|
| A-001 | `planifest-framework/skills/` is the canonical source; `.claude/skills/` is a synced build artifact, not independently authoritative | Fixes would need to also be applied to `.claude/skills/` directly for this session's own orchestrator behavior to reflect them immediately, and a skill-sync/setup re-run would be needed regardless | open |
| A-002 | No `pwsh` runtime is available anywhere in this environment (not just this session) | The `copilot.ps1` and `setup.ps1` dispatcher-guard fixes (req-003) would need live re-verification once a runtime is confirmed available | open |
