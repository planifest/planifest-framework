---
title: "ADR-001: Interrupted P9 Detection Signal"
summary: "An interrupted P9 is detected by the combination of plan/.orchestrator-active present AND plan/current/ empty — not by a dedicated flag file."
status: "accepted"
version: "0.1.0"
---
# ADR-001 - Interrupted P9 Detection Signal

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000015-pipeline-session-cleanup
**Component:** planifest-orchestrator
**Status:** accepted
**Date:** 2026-05-19

---

## Context

P9 cleanup involves two stages: (1) archiving plan/current/ (which empties the directory) and (2) deleting sentinel files (.orchestrator-active, .run-mode, .orchestrator-ack). If a session is interrupted between these two stages, the next session starts with an ambiguous state: .orchestrator-active is present but plan/current/ is empty. The resume detection logic must distinguish this from a fresh start or a normal mid-pipeline resume.

---

## Decision

Use the combination of `.orchestrator-active` present AND `plan/current/` empty (no design.md, no requirements/, no adr/) as the interrupted P9 signal. No dedicated flag file is introduced.

This signal is reliable because:
- A fresh start has no `.orchestrator-active`
- A normal mid-pipeline resume has `.orchestrator-active` AND non-empty `plan/current/`
- Only an interrupted P9 produces `.orchestrator-active` + empty `plan/current/`

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Dedicated `plan/.p9-in-progress` flag file | Unambiguous signal | Adds another file to manage; P9 interruption could also leave this file in a bad state | Rejected — adds complexity without meaningful benefit over the existing signal |
| Check for archive directory existence | Cross-references the archive | Fragile — archive dir could exist from a previous feature with the same ID | Rejected — too fragile |
| Combined signal (this decision) | Uses existing files; no new state | Theoretically falsifiable by manual deletion of plan/current/ | Chosen — false positive is harmless (extra cleanup run) |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-orchestrator | Resume detection logic gains an interrupted P9 branch |

---

## Consequences

**Positive:**
- No new files or state introduced — uses existing signals
- False positive (manual plan/current/ deletion) results in a harmless extra cleanup, not data loss

**Negative:**
- If a human manually empties plan/current/ for unrelated reasons while .orchestrator-active is present, the orchestrator will treat it as interrupted P9 and run cleanup

**Risks:**
- Low: the false-positive scenario is rare and the consequence is benign

---

## Related ADRs

- None

---

## Supersedes

- None

## Superseded By

- None
