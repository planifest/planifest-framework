---
title: "Requirement: REQ-005 - Re-invoke setup with confirmed flags"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-005 - Re-invoke setup with confirmed flags

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000020-setup-refresh-skill
**Source:** US-002
**Priority:** must-have

---

## User Story

As a human on the loop, once I've confirmed the flags, I want the skill to re-run the correct setup script for me, so that the refresh actually completes without me typing the invocation myself.

---

## Functional Requirements
- After REQ-004's deletion, the skill invokes `setup.sh` (or `setup.ps1` on Windows) with the target tool and the confirmed flag set from REQ-003
- The invocation uses the same flag syntax `setup.sh`/`setup.ps1` already accept (double-hyphen long flags, e.g. `--context-mode-mcp`, `--structured-telemetry-mcp --backend-url <url>`, `--strict-orchestrator`, `--include-full-skill-library`)
- On successful completion, the skill reports success and confirms the regenerated boot files are present

## Acceptance Criteria
- [ ] The invoked command matches exactly what was shown to the human on the loop at the REQ-003 confirmation step
- [ ] `setup.ps1` is invoked on Windows, `setup.sh` elsewhere, using the same flag set either way
- [ ] On success, the skill confirms `CLAUDE.md`/`AGENTS.md` were regenerated and reports the flags now in effect

## Dependencies
- REQ-004 (deletion happens immediately before this step)
- REQ-006 (defines behaviour when this step fails instead of succeeding)
