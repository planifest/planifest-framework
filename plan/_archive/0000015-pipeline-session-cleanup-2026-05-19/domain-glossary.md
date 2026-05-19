---
title: "Domain Glossary - 0000015-pipeline-session-cleanup"
---
# Domain Glossary - 0000015-pipeline-session-cleanup

| Term | Definition |
|------|-----------|
| Run mode | The session preference (`continuous` or `interactive`) set at P0 and persisted to `plan/.run-mode`. Governs whether the orchestrator stops at phase gates for human confirmation. |
| Stale run-mode | A `plan/.run-mode` file left over from a previous pipeline run that was not cleaned up at P9. |
| Phase block | A structured log entry in `plan/current/build-log.md` written at the start of each pipeline phase, recording model tier, skills loaded, agent count, MCP calls, and notes. |
| Clean P0 | A Phase 0 start with no leftover state from a prior run — no stale sentinel, no stale run-mode, no stale `plan/current/` artifacts. |
| Interrupted P9 | A state where P9 archiving completed (plan/current/ is empty) but sentinel cleanup did not run — detectable by the presence of `.orchestrator-active` with an empty `plan/current/`. |
| Session cleanup | The set of file deletions performed at P9 that reset pipeline state for the next feature: `.orchestrator-active`, `.orchestrator-ack`, `.run-mode`, `plan/.feature-id`. |
