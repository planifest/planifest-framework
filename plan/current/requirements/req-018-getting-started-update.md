---
title: "Requirement: REQ-018 - getting-started.md updated with phase indicators section"
summary: "getting-started.md gains a new section explaining the Px prefix convention and how to read phase indicators."
status: "draft"
version: "0.1.0"
---
# Requirement: REQ-018 - getting-started.md phase indicators section

**Skill:** [spec-agent](../../planifest-framework/skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000003-hook-based-enforcement
**Source:** Feature brief Track D scope; DD-011
**Priority:** must-have

---

## Functional Requirements

- `getting-started.md` gains a new section titled "Understanding phase indicators".
- The section explains: each Planifest agent response begins with `Px:` where x is the pipeline phase number (P0–P7); `PC:` is used by the change-agent.
- The section includes a quick reference table: phase number → phase name → agent.
- The section explains what to do when you see `Px: ⚠` (an escalation that requires human input).
- The section is positioned after the existing "Quick Start" section and before advanced topics.

## Acceptance Criteria

- [ ] `getting-started.md` contains a section titled "Understanding phase indicators".
- [ ] Section lists all phase numbers P0–P7 with their names.
- [ ] Section explains the `PC:` change-agent convention.
- [ ] Section explains escalation (`⚠`) messages.

## Dependencies

- REQ-014 (Px convention must be specified before documentation can describe it).
