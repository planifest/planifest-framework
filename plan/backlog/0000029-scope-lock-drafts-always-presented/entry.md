---
title: "Backlog Entry: 0000029 - Scope Lock answers always drafted and presented"
summary: "Invert the ADR-003 offer-first flow: the scope-lock agent should always draft each Scope Lock answer and present it to the human, who then accepts, edits, or discards it, instead of the human being asked whether they want a suggestion first."
status: "open"
---
# Backlog Entry: 0000029 - Scope Lock answers always drafted and presented

**Source feature:** 0000022-orchestrator-redundancy-removal
**Source phase:** P0 (Scope Lock Challenge)
**Date filed:** 2026-08-02

---

## Problem

The current Scope Lock Challenge protocol (orchestrator SKILL.md, "Suggested-answer option", per 0000016 ADR-003) asks each scenario-path question with only an offer attached: "Want me to suggest an answer first? yes/no". A draft is produced only if the human explicitly requests one, adding a round trip per question (up to eight exchanges for four answers) with no governance benefit: the human's explicit per-item accept/edit/reject remains the only thing that counts either way. During 0000022's P0 the human on the loop directed that the draft should simply always be there when the question is asked. The relevant rules live in `planifest-framework/skills/planifest-orchestrator/SKILL.md` (Scope Lock Challenge section) and `planifest-framework/skills/planifest-scope-lock-agent/SKILL.md` (never-pre-draft rule).

## Suggested Action

Change the protocol so the orchestrator dispatches the scope-lock agent for each scenario-path question as it is reached, and presents the question together with the labelled draft in the same turn; the human then accepts, edits, or discards. Keep everything else: fresh-context subagent per question, draft labelling, contradiction flags surfaced unresolved, explicit per-item affirmative recorded to the build log, no implicit confirmation. Supersede or amend the never-pre-draft clause of ADR-003 with a new ADR recording the inversion.

## Why Deferred

Out of scope for 0000022, which removes redundant orchestrator content without behavioural change; this is a deliberate protocol change needing its own ADR against 0000016 ADR-003.
