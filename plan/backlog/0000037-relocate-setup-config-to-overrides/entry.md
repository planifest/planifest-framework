---
title: "Backlog Entry: 0000037 - Relocate setup config to planifest-overrides/setup-config/"
summary: "Setup's active flags/backend-url live only in the gitignored, tool-specific .planifest-setup-flags marker (e.g. .claude/.planifest-setup-flags); revisit storing them in planifest-overrides/setup-config/ instead, one file per AI tool, so they're versioned and survive like the rest of overrides."
status: "open"
---
# Backlog Entry: 0000037 - Relocate setup config to planifest-overrides/setup-config/

**Source feature:** 0000023-framework-pipeline-fixes (post-ship follow-up)
**Source phase:** N/A - filed outside an active pipeline run, during ad hoc `planifest-refresh-setup` use
**Date filed:** 2026-08-02

---

## Problem

Running `planifest-refresh-setup` today (to pick up a new `planifest-overrides/instructions/` file) surfaced that the record of which setup flags are active for a given AI tool - `--context-mode-mcp`, `--structured-telemetry-mcp`, `--strict-orchestrator`, `--backend-url`, etc. - lives only in `{tool-dir}/.planifest-setup-flags` (e.g. `.claude/.planifest-setup-flags`). That path, and everything else `setup.sh` regenerates (`CLAUDE.md`, `.claude/settings.json`, `.claude/hooks/*`), is gitignored (`.gitignore` lines for `.claude/`, `CLAUDE.md`, `.planifest-setup-flags`). So the flags actually in effect for this repo are local-only, machine-specific, and invisible to `git log`/review, even though they represent a repo-level decision (e.g. "this repo uses strict-orchestrator mode") that every human/machine working on it should apply consistently.

`planifest-overrides/` already exists precisely to hold repo-specific, human-managed config that survives `planifest-framework/` upgrades (`instructions/`, `capability-skills/`, `library-standards/`) and `setup.sh` already reads from it without ever writing to it (ADR-002, 0000005-framework-governance). The setup-flags marker doesn't fit that pattern today - it's written by `setup.sh` itself, lives inside the gitignored tool directory, and has to be reconstructed by inference (`planifest-refresh-setup` Step 3) whenever the marker is missing or the repo is fresh-cloned.

## Suggested Action

Add `planifest-overrides/setup-config/`, one file per supported AI tool (e.g. `setup-config/claude-code.json`, `setup-config/cursor.json`), holding the same shape as today's `.planifest-setup-flags` (`flags`, `backendUrl`). `setup.sh` reads this file as the source of truth for that tool's flags instead of requiring `--flag` args or falling back to marker-file inference; the gitignored `{tool-dir}/.planifest-setup-flags` can remain as a local completion-status cache (`attemptStatus`, `writtenAt`) rather than the record of intent. `planifest-refresh-setup`'s Step 3 (REQ-002) would then read this committed file at high confidence instead of inferring from hook wiring.

## Why Deferred

Not blocking - today's refresh worked fine with the existing marker-file/inference approach. Changes `setup.sh`'s flag-resolution precedence and `planifest-refresh-setup`'s Step 2/3 logic, plus needs a migration path for repos with an existing local-only `.planifest-setup-flags` and no `setup-config/` file yet. Needs its own design decision (exact schema, precedence if both a committed file and CLI flags are given, whether this extends to `.orchestrator-strict` too) rather than a same-session tack-on.
