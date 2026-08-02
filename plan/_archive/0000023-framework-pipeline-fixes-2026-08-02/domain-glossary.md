---
title: "Domain Glossary - Framework Pipeline Fixes"
summary: "Definitions of domain terms used within this feature."
status: "active"
version: "0.1.0"
---
# Domain Glossary - Framework Pipeline Fixes

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md) (updated by any agent that introduces a new domain term)
**Feature:** 0000023-framework-pipeline-fixes
**Version:** 0.23.0

## Terms

| Term | Definition | Aliases | Used In |
|------|-----------|---------|---------|
| Session marker | One of the three sentinel dotfiles (`plan/.orchestrator-active`, `plan/.orchestrator-ack`, `plan/.run-mode`) that record in-flight pipeline state on disk | Sentinel file | `planifest-orchestrator`, `planifest-ship-agent` |
| Marker commit-lifecycle | The rule that a session marker must be committed the moment it is written, and its deletion must be committed atomically with the archive move at P7 | — | req-002 |
| Continuous run | The P0-confirmed run mode (`continuous_run: true`, recorded in `plan/.run-mode`) under which phase gates P1-P6 proceed without a human confirmation stop, except P9 which always stops | Continuous mode | `planifest-orchestrator`, req-001 |
| Phase Invocation Table | The single consolidated table in `planifest-orchestrator/SKILL.md` (introduced by feature 0000022) listing, per phase P1-P6, the skill to invoke, the gate condition, and the STOP rule | — | req-001 |
| Tier-1 tool | A host tool (Cursor, Windsurf, Copilot, etc.) wired via native hook adapters copied into the target project, as opposed to a lower-enforcement tier relying on prose-only boot instructions | — | req-003 |
| `product_id` | The optional telemetry envelope field identifying the emitting repo — its git root path (`git rev-parse --show-toplevel`), or the raw `cwd` if not inside a git repository | — | req-004 |
| Self-copy bug | A defect where a script's copy source and destination resolve to the identical filesystem path, causing `cp` to refuse and error | — | req-003 |
