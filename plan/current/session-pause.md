---
date: 2026-05-09
phase: P0 — Assess & Coach (new feature, requirements gathering)
status: paused by human
---

# Session Pause — New Feature: Framework Rail-Tightening

## Context

- 0000008 is implemented but not formally shipped (P7 not run)
- Two pending migrations: `0001-date-format`, `0002-british-english` (human to decide run or skip)
- New feature planning began — no feature-brief or design written yet

## Requirements Gathered So Far

**REQ-1** — Fix `.skips` path ambiguity in orchestrator source (`planifest-framework/skills/planifest-orchestrator/SKILL.md`): qualify all three bare `.skips` references to `plan/current/.skips` to match the ship-agent spec.

**REQ-2** — Auto-trigger orchestrator at session start when in a planifest folder. `UserPromptSubmit` hook for hook-capable tools (Claude Code, Cursor etc.); CLAUDE.md instruction as fallback for tools without hook support.

**REQ-3a** — Orchestrator instructs each phase agent to decompose difficult tasks into subagents, searching `planifest-framework/skills/` (and overrides) to find the most appropriate skill for each subtask before delegating. Appropriate model tier selected per subagent based on task complexity.

**REQ-3b** — From P0 onwards, the orchestrator evaluates active work against the skill library and produces a skill-to-requirement (or skill-to-task) mapping. First pass during P0 discovery; re-evaluated at each phase gate. Human confirms additions or changes before each phase proceeds.

**REQ-4** — A curated library of open source Claude Code `SKILL.md`-format skills in a separate directory. `--include-full-skill-library` setup flag controls whether they are copied to the tool skill directory. Each skill includes attribution and a link to its source GitHub repo. Web search for highly reviewed open source skills to populate the initial library.

**REQ-5** — On explicit human command, the orchestrator writes `plan/current/pause.md` capturing current phase, active task, last completed artefact, and in-progress state. Resume detection reads this file and restores from the exact pause point.

## Next Steps on Resume

- Ask: any more requirements?
- Once complete: decomposition check, then write feature brief
- Decide: ship 0000008 before or after new feature plan?
- Decide: run pending migrations now or skip?
