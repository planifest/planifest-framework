---
title: "Requirement: req-004 - cross-platform-hook-ports"
summary: "Detailed requirements for this specific functional feature."
status: "active"
version: "0.1.0"
---
# Requirement: req-004 - cross-platform-hook-ports

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000017-ratchet-forgery-detection-and-telemetry-schema-spec
**Source:** US-004
**Priority:** must-have

---

## User Story

As a Windows user without Git Bash or WSL, enforcement hooks work identically to every other platform, so that I get the same protection regardless of what shell tooling I happen to have installed.

---

## Functional Requirements
- Port `block-bash.sh`, `block-grep.sh`, `block-webfetch.sh` to `.mjs`, extracting the existing inline node-fallback logic as the sole implementation
- Remove the `jq` dependency and the Unix-shell (Git Bash/WSL) requirement entirely — behavior identical whether or not the user happens to have WSL/Git Bash installed
- Update `setup.sh`/`setup.ps1` wiring to install and register the `.mjs` hooks
- Remove quirks Q-002 (`jq` dependency) and Q-005 (Windows requires bash-compatible environment) from `src/context-mode-hooks/component.yml` as resolved
- If the Node runtime itself is missing: surface a clear fail message at setup time (before anything is wired up) AND at runtime (explaining enforcement didn't fire because the runtime was missing)
- The tool call itself still proceeds either way (fails open, per existing framework convention) — fail-open governs whether the call is blocked, not whether the human is told what happened

## Acceptance Criteria
- [ ] All 3 hooks execute identically on macOS/Linux/Windows, with or without WSL/Git Bash present
- [ ] `jq` is no longer a runtime dependency anywhere in the hook execution path
- [ ] `setup.sh` and `setup.ps1` both wire up the `.mjs` hooks correctly
- [ ] Q-002 and Q-005 are removed from `src/context-mode-hooks/component.yml`
- [ ] A missing Node runtime produces a clear message at setup time and at runtime; the tool call still proceeds (fail-open)

## Dependencies
- `src/context-mode-hooks/component.yml` update (this pipeline run, req-004's own scope)
- `setup.sh` itself remaining bash-only is explicitly out of scope (one-time install step)
