---
title: "Execution Plan - 0000015-pipeline-session-cleanup"
---
# Execution Plan - 0000015-pipeline-session-cleanup

## Overview

Six targeted edits to `planifest-framework/skills/`. No runtime code. No TDD loop. All changes are markdown skill files.

## Components Affected

| Component | Files | Changes |
|-----------|-------|---------|
| planifest-orchestrator | `SKILL.md` | REQ-001 (build log), REQ-003 (stale check), REQ-005 (version wording), REQ-006 (interrupted P9 resume) |
| planifest-ship-agent | `SKILL.md` | REQ-002 (clear run-mode), REQ-004 (new session recommendation) |

## Implementation Order

1. Read current state of both SKILL.md files
2. Batch 1 (parallel): REQ-001 + REQ-003 + REQ-005 + REQ-006 → orchestrator SKILL.md
3. Batch 2: REQ-002 + REQ-004 → ship-agent SKILL.md
4. Update `planifest-framework/component.yml` version

## Non-Functional Requirements

- No latency, availability, or scalability targets — docs-only
- All edits must be consistent with existing 0000014 changes already in the skill files
- Each edit is idempotent — reading the file before editing is mandatory

## API / Data Summary

No APIs. No data stores. `plan/.run-mode` is the only file whose lifecycle changes.
