---
title: "ADR-002 - Telemetry guidance centralised in standards file"
status: "accepted"
date: "04 May 2026"
feature: "0000007-agent-optimisation"
---
# ADR-002 — Telemetry guidance centralised in telemetry-standards.md

## Context

The telemetry envelope structure, emission gate conditions, and phase_start/phase_end ownership note were duplicated verbatim across 9 skill files. Any change to the envelope (e.g. adding a new field) required editing 9 files. There was a real risk of drift between files if one was updated and others were not.

## Decision

Extract the shared telemetry content (envelope, gate conditions, phase_start/phase_end note) to `planifest-framework/standards/telemetry-standards.md`. Each skill file replaces the three blocks with a single pointer line. Per-skill event definitions remain in each skill.

## Alternatives Considered

| Option | Pros | Cons | Rejected because |
|--------|------|------|-----------------|
| Keep verbatim in each skill | Self-contained skills | 9-file update cost; drift risk | Maintenance cost outweighs self-containment benefit |
| Centralise everything (including event definitions) | Maximum DRY | Agents must load a second file to see what events to emit for their phase; loses locality of event spec | Per-skill events are phase-specific and should stay with the skill |
| Centralise envelope + gate only (chosen) | Single source of truth for shared content; event definitions stay local | Agents must follow a pointer to the standards file | Pointer is one line; benefit clearly outweighs cost |

## Affected Components

- `planifest-framework/standards/telemetry-standards.md` — new file, single source of truth
- `planifest-orchestrator/SKILL.md`, `planifest-spec-agent/SKILL.md`, `planifest-adr-agent/SKILL.md`, `planifest-codegen-agent/SKILL.md`, `planifest-validate-agent/SKILL.md`, `planifest-security-agent/SKILL.md`, `planifest-docs-agent/SKILL.md`, `planifest-ship-agent/SKILL.md`, `planifest-change-agent/SKILL.md` — pointer line replaces three blocks

## Consequences

**Positive:**
- Envelope changes require editing one file, not nine
- Consistent emission behaviour guaranteed across all skills
- Reduced token cost per skill load

**Negative:**
- Agents must follow a pointer to read the full envelope when needed
- `telemetry-standards.md` must be added to `bundle_standards` for all 9 skills to ensure it is always available

**Risks:**
- If `bundle_standards` is not updated, agents may not find the standards file — mitigated by including it in the acceptance criteria

## Related ADRs

- None
