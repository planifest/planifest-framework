---
id: REQ-011
slug: p8-subagent-model-tier
title: Explicit model tier in ship-agent P8 sub-agent call
priority: medium
status: open
---

# REQ-011 — Explicit model tier in ship-agent P8 sub-agent call

## User Story

As a pipeline runner, I want the ship-agent to explicitly pass the cheaper model tier when spawning the build-assessment-agent, so that model routing is deterministic and does not rely on frontmatter inference.

## Acceptance Criteria

- [ ] `planifest-ship-agent/SKILL.md` P8 section includes `model: claude-haiku-4-5` in the Agent invocation template
- [ ] The model parameter appears alongside the existing sub-agent invocation instructions

## Dependencies

- REQ-008 (P9 ship phase — ship-agent P8 section exists)
