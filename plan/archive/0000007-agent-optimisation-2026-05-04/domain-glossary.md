---
title: "Domain Glossary - 0000007-agent-optimisation"
status: "active"
version: "0.1.0"
---
# Domain Glossary — 0000007-agent-optimisation

| Term | Definition |
|------|------------|
| **Build target** | A declared intent for where build and test operations run. Values: `local` (host machine), `docker` (inside a container), `ci-only` (only in CI pipeline). Declared in the feature-brief stack table. |
| **Host runtime** | A language runtime or tool (e.g. `node`, `dotnet`, `python`, `go`) installed on the developer's local machine. Irrelevant and potentially misleading when Build target is `docker`. |
| **Superfluous content** | Skill file content that adds token cost without unique signal: implicit model knowledge stated explicitly, hook-duplicated instructions, verbatim boilerplate across files, stale references. |
| **Implicit model knowledge** | Information a capable language model already knows and does not need to be told, e.g. "do not suppress linting rules to hide errors" or standard engineering practices. |
| **Hook-duplicated instruction** | An instruction in a skill file that is already enforced by a deterministic hook (gate-write, CLAUDE.md), making the instruction in the skill file redundant. |
| **Boilerplate** | Identical or near-identical content appearing verbatim across multiple skill files with no unique signal per file. |
| **Telemetry envelope** | The JSON wrapper object common to all `emit_event` calls: `schema_version`, `event`, `agent`, `phase`, `tool`, `model`, `mcp_mode`, `session_id`, `timestamp`, `data`. |
| **Emission gate** | The two conditions that must both be met before any telemetry event is emitted: `emit_event` tool present AND `.claude/telemetry-enabled` sentinel file exists. |
| **Setup manifest** | A file written by `setup.sh`/`setup.ps1` listing all directories installed in the current run. Used on re-runs to remove only managed directories. |
| **language-quirks file** | A locale-specific standards file (`language-quirks-{locale}.md`) documenting deliberate deviations from the locale's default language rules (e.g. American technical terms preferred over British equivalents). |
| **Optimise agent** | The `planifest-optimise-agent` skill. Reviews Planifest skill files and presents superfluous content suggestions one at a time for human confirmation. Never modifies files directly. |
| **Confirmed-changes summary** | The output of a completed optimise-agent review session: a numbered list of human-confirmed removal suggestions, formatted as input to a Change Pipeline run. |
