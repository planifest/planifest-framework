---
title: "Scope - 0000015-pipeline-session-cleanup"
---
# Scope - 0000015-pipeline-session-cleanup

## In Scope
- Build log phase blocks at every phase boundary (REQ-001) — orchestrator SKILL.md
- Delete `plan/.run-mode` at P9 cleanup (REQ-002) — ship-agent SKILL.md
- Stale run-mode check at P0 pre-flight (REQ-003) — orchestrator SKILL.md
- New-session recommendation after P9 final confirm (REQ-004) — ship-agent / orchestrator SKILL.md
- Version suggestion wording improvement (REQ-005) — orchestrator SKILL.md
- Interrupted P9 detection and cleanup on resume (REQ-006) — orchestrator SKILL.md

## Out of Scope
- Changes to any phase skill other than orchestrator and ship-agent
- Runtime code, tests, or infrastructure
- Changes to hook scripts or setup scripts
- Automated enforcement of "new session" — recommendation only, not a block

## Deferred
- None
