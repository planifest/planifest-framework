---
title: "Domain Glossary - 0000012-docs-restructure-commit-directives"
summary: "Ubiquitous language for this feature — agents and humans use these terms."
status: "active"
version: "0.1.0"
---
# Domain Glossary - 0000012-docs-restructure-commit-directives

| Term | Definition |
|------|-----------|
| Pipeline | The full sequence of phases (P0–P9) that takes a feature from idea to shipped PR. |
| Phase | A discrete step in the pipeline, identified by a canonical prefix (P0–P9). Each phase has a defined skill, input, output, and gate. |
| P7 — Archive | The phase where the ship-agent writes the changelog, archives `plan/current/`, and commits. Previously called "Ship". |
| P8 — Build Assessment | The phase where the build-assessment-agent analyses the archived build log and produces the build report. Invoked as a sub-agent by the ship-agent. |
| P9 — Ship | The new terminal phase where the ship-agent creates a git tag, asks the human about push/PR preference, and either raises the PR or outputs a PR description for the human. |
| Gate | The checkpoint at the end of each phase where the orchestrator presents output to the human (interactive mode) or proceeds automatically (continuous mode). |
| Build log | `plan/current/build-log.md` — the working telemetry file maintained throughout the pipeline. One phase block per phase. Archived at P7 and read by the build-assessment-agent at P8. |
| Run mode | Either `continuous` (orchestrator proceeds through all phases without stopping) or `interactive` (orchestrator stops at each gate for human confirmation). Persisted to `plan/.run-mode`. |
| Run-mode sentinel | The file `plan/.run-mode`, written at P0, containing either `continuous` or `interactive`. Read on resume to restore run mode without re-asking. |
| Gate acceptance record | A line appended to `plan/current/build-log.md` in interactive mode when the human confirms a phase gate: `Gate accepted: P{N} — {ISO-8601 timestamp}`. |
| Pre-flight | The new first step of P0 that checks branch state, confirms all previous PRs are merged, and offers to create the feature branch. |
| Retroactive tags | Git tags applied to historical merge-to-main commits to mark previous releases (e.g. v0.1 through v0.10). Created by the retroactive-release-tags migration. |
| Phase commit | A git commit made at each phase gate containing all new or modified files under `plan/current/`, using the convention `plan(pN): {artifact summary}`. |
| Three-file architecture | The docs structure introduced in this feature: `getting-started.md` (lean onboarding), `pipeline-reference.md` (full phase reference), `project-operations.md` (ops reference). |
| Hard Limit | A non-negotiable constraint in the orchestrator SKILL.md that must not be violated under any circumstances. Hard Limits are numbered and listed at the top of the skill. |
| Sub-agent | A separate Claude Code agent session spawned by a phase skill to handle a self-contained task. The build-assessment-agent is invoked as a sub-agent by the ship-agent at P8. |
| local-git-only | A repo instruction (in `planifest-overrides/instructions/`) that prohibits the agent from running remote git commands (fetch, pull, push). P9 detects this instruction and defaults to outputting a PR description rather than pushing. |
