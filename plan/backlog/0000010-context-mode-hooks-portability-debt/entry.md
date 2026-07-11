---
title: "Backlog Entry: 0000010 - context-mode-hooks portability tech debt"
summary: "jq is a hard runtime dependency with no pure-bash fallback, and Windows requires a bash-compatible environment for hook execution — both tracked as quirks, neither addressed."
status: "open"
---
# Backlog Entry: 0000010 - context-mode-hooks portability tech debt

**Source feature:** 0000016-pipeline-governance-and-loop-engineering
**Source phase:** post-ship assessment
**Date filed:** 2026-07-11

---

## Problem

`src/context-mode-hooks/component.yml` quirks list two portability gaps that have sat unaddressed since the component's original feature: (1) `jq` is a required runtime dependency for the hook scripts with no pure-bash fallback (quirk Q-002 in that component's own notes), and (2) Windows requires a bash-compatible environment (e.g. Git Bash/WSL) for hook execution — native PowerShell-only Windows environments cannot run the context-mode hooks at all (Q-005). Neither is a regression from 0000016, but both surfaced again during this repo assessment as standing debt with no scheduled remediation.

## Suggested Action

Assess real-world impact first (how many target environments lack `jq` or a bash-compatible shell on Windows) before committing effort. If material: add a pure-bash JSON-field-extraction fallback for the narrow subset of `jq` usage these hooks need, and/or document the Git Bash/WSL requirement prominently in setup instructions for Windows users rather than leaving it as a component.yml quirk only.

## Why Deferred

Unquantified impact — needs a scoping pass on actual deployment environments before deciding whether this is worth engineering effort or just clearer documentation.
