---
title: "Risk Register - 0000012-docs-restructure-commit-directives"
summary: "Technical, operational, and security risks with mitigations."
status: "active"
version: "0.1.0"
---
# Risk Register - 0000012-docs-restructure-commit-directives

| ID | Category | Risk | Likelihood | Impact | Mitigation |
|----|----------|------|------------|--------|------------|
| R-001 | Technical | planifest-orchestrator/SKILL.md edits introduce a regression in the phase gate flow — e.g. a new Hard Limit is positioned so it blocks phases that were previously unaffected | medium | medium | Targeted edits only; read the full gate section before writing; review each phase section after editing |
| R-002 | Technical | planifest-ship-agent/SKILL.md restructure (P7/P8/P9 split) breaks the existing P7 archive sequence if section boundaries are unclear to the agent | medium | medium | Write each phase section with explicit P-prefix headers; test with a dry-run read after writing |
| R-003 | Technical | P9 git tag created with malformed version (e.g. from a corrupted component.yml) causes a git error that halts the pipeline | low | low | Input validation on version field (REQ-008 Input Validation); fallback to human-supplied version |
| R-004 | Technical | Retroactive tag migration runs `git tag` on an incorrect commit SHA due to ambiguous `git log --merges` output | medium | medium | Migration requires explicit human confirmation of each commit→version mapping before tagging |
| R-005 | Operational | build-assessment-agent invoked as sub-agent by ship-agent does not receive the correct archived build-log path, producing an empty report | low | medium | REQ-008 specifies the ship-agent passes the archive path explicitly; P8 acceptance criteria require the report to exist |
| R-006 | Operational | Run-mode sentinel file `plan/.run-mode` is absent (e.g. legacy pipeline run without REQ-006) — resume reads a missing file and defaults unexpectedly | low | low | REQ-006 specifies default to `interactive` on read error; low risk because the consequence is an extra human confirmation, not a failure |
| R-007 | Operational | Pre-flight (REQ-009) runs on a resume where the branch is already correct — causes unnecessary prompts | low | low | REQ-009 specifies pre-flight is skipped when `plan/current/pause.md` is detected (resume path) |
| R-008 | Compliance | Assumption A-001: SKILL.md edits take effect without setup.sh re-run. If false, agents on other machines may run stale skills | medium | medium | Document in migration notes and project-operations.md: re-run setup.sh after framework updates |
