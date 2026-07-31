---
title: "Requirement: REQ-008 - Install-time marker write in setup.sh/setup.ps1"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-008 - Install-time marker write in setup.sh/setup.ps1

**Skill:** [spec-agent](../../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000020-setup-refresh-skill
**Source:** US-003
**Priority:** should-have

---

## User Story

As a framework maintainer, I want `setup.sh`/`setup.ps1` to record the flags used at install time to `.claude/.planifest-setup-flags`, so that future refreshes read them directly instead of inferring them from hook wiring.

---

## Functional Requirements
- On a successful `setup.sh` run for a given tool, the script writes (or overwrites) `.claude/.planifest-setup-flags` with the tool name, the full set of flags passed (including `--backend-url` value if `--structured-telemetry-mcp` was used), and a timestamp
- `setup.ps1` performs the same write, in parity with `setup.sh` — same file, same schema, same field set
- The write happens only after the rest of setup completes successfully, so a failed install does not leave a marker claiming a flag set that was never actually applied
- The marker file format is documented (see `src/setup-hook-integration/docs/data-contract.md`) so both scripts and the refresh skill (REQ-002) agree on its schema

## Acceptance Criteria
- [ ] `setup.sh --tool <tool> <flags>` succeeding results in `.claude/.planifest-setup-flags` containing exactly the flags passed, plus tool name and timestamp
- [ ] `setup.ps1` produces byte-for-byte equivalent marker content (modulo timestamp) for the same tool/flag combination
- [ ] A failed/aborted setup run does not write or update the marker file
- [ ] The marker schema matches the data contract referenced by REQ-002's reconstruction logic

## Dependencies
- None (this is the producer side; REQ-002 is the consumer)
