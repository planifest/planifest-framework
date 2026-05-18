---
id: REQ-012
slug: resume-detection-run-mode-step
title: Add plan/.run-mode read step to Resume Detection checklist
priority: medium
status: open
---

# REQ-012 — Add plan/.run-mode read step to Resume Detection checklist

## User Story

As an orchestrator resuming a session, I want the Resume Detection checklist to explicitly include reading `plan/.run-mode`, so that run mode is always restored on resume without re-asking the human.

## Acceptance Criteria

- [ ] `planifest-orchestrator/SKILL.md` Resume Detection ordered checklist includes a step to read `plan/.run-mode` if present
- [ ] The step states: any value other than `continuous` defaults to `interactive`
- [ ] The step is positioned after pause.md detection (so it only applies when an active pipeline is detected)

## Dependencies

- REQ-006 (run-mode sentinel — `plan/.run-mode` written at P0)
