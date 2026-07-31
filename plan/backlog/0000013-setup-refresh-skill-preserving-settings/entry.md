---
title: "Backlog Entry: 0000013 - Setup refresh skill (preserve settings, tool-aware)"
summary: "Add a skill that refreshes a Planifest install by re-running the correct tool's setup script with the flags currently in effect, without the human or agent having to reverse-engineer them from hook wiring."
status: "open"
---
# Backlog Entry: 0000013 - Setup refresh skill (preserve settings, tool-aware)

**Source feature:** 0000018-telemetry-emission-consistency (filed ad-hoc via chat, not part of the phased pipeline)
**Source phase:** N/A (filed ad-hoc via chat)
**Date filed:** 2026-07-31

---

## Problem

Refreshing a Planifest install's generated artifacts (`CLAUDE.md`, `.claude/hooks/`, `.claude/skills/`, etc.) after the framework source changes requires manually reconstructing the original `setup.sh` / `setup.ps1` invocation: the correct tool name (`claude-code`, `cursor`, ...) and every flag previously used (`--context-mode-mcp`, `--structured-telemetry-mcp`, `--backend-url`, `--strict-orchestrator`, `--include-full-skill-library`). None of this is recorded directly — it has to be inferred by reading installed hook wiring in `.claude/settings.json` and marker files (`plan/.orchestrator-strict`, `.claude/telemetry-enabled`). This session had to do exactly that reverse-engineering by hand before it could safely refresh.

## Suggested Action

1. Add a skill (e.g. `planifest-refresh-setup`) invoked on request ("refresh the framework setup", "re-run setup with current settings") that:
   - Detects which tool is currently set up in the repo (presence of `.claude/`, `.cursor/`, etc.).
   - Reconstructs the flags actually active by inspecting installed hook wiring and marker files (context-mode hooks present → `--context-mode-mcp`; telemetry hook present → `--structured-telemetry-mcp` plus `--backend-url` parsed from the hook command; `plan/.orchestrator-strict` present → `--strict-orchestrator`; `attribution.txt` files under the skills dir → `--include-full-skill-library`).
   - Deletes only the boot files that `setup.sh`/`setup.ps1` won't overwrite on their own (`CLAUDE.md`, `AGENTS.md`) so templates actually regenerate, without touching `settings.local.json` or other user-owned files.
   - Re-invokes the appropriate setup script for the detected tool with the reconstructed flags.
2. Consider persisting the flags used at install time in a small marker file (e.g. `.claude/.planifest-setup-flags`) so future refreshes read them directly instead of inferring them from hook wiring.

## Why Deferred

DX/tooling improvement identified during an ad-hoc chat session; not blocking any in-flight pipeline feature. Needs design work on reliably detecting "current tool" across all supported targets and on the parity story between `setup.sh` and `setup.ps1` (the `.ps1` variant is already known to drift from the actual flags in use — see `refresh-planifest-framework-dir.ps1`).
