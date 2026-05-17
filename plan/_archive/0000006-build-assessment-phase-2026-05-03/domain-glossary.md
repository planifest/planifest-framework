# Domain Glossary — 0000006-build-assessment-phase

| Term | Definition |
|------|-----------|
| **Build log** | The working file `plan/current/build-log.md` maintained by the orchestrator throughout a pipeline run. Records per-phase telemetry: model tier, agents, MCP calls, parallelism. |
| **Build Assessment (P8)** | The eighth and final phase of the Planifest pipeline. Reads the build log, produces a structured efficiency report, and files it to the archive. |
| **Model tier** | A capability classification for subagent model selection — not a model name. Two tiers: *primary* (complex synthesis, codegen, security) and *cheaper* (search, single-file reads, formatting). Resolved to a concrete model name for the active tool at dispatch time. |
| **Primary tier** | The model tier for tasks requiring synthesis, multi-file reasoning, code generation, or security analysis. Maps to the most capable model available on the active tool. |
| **Cheaper tier** | The model tier for tasks requiring search, grep, single-file reads, or formatting checks. Maps to the least expensive capable model on the active tool (e.g. Haiku on Claude Code). |
| **Parallelism directive** | An explicit instruction in a skill file, using the word "MUST", that requires the agent to dispatch independent tasks in a single message with multiple tool calls. |
| **Phase boundary** | The transition point between two pipeline phases. The orchestrator appends a build log entry at each phase boundary. |
| **Efficiency observation** | A finding in the P8 build report noting a missed optimisation opportunity — e.g. tasks that could have been parallelised, or phases where the primary tier was used unnecessarily. |
| **Tier resolution** | The act of mapping a tier name to a concrete model ID for the active tool before spawning a subagent. |
