# Design Specification - Guide

> How the spec-agent produces a design specification, and how to read one.

*Related: [Spec Agent Skill](../skills/spec-agent-SKILL.md) | [Initiative Brief Guide](initiative-brief-guide.md)*

---

## Purpose

The Design Specification translates the Initiative Brief into **specific, testable requirements**. It is the contract between what the human asked for and what the codegen-agent will build. Every requirement traces back to a user story or acceptance criterion - if it doesn't trace, it shouldn't exist.

---

## Who Writes It

The **spec-agent** produces this document during Phase 1 of the pipeline. It reads the confirmed Planifest and the original Initiative Brief as input. It does not invent requirements - it derives them.

---

## When It's Produced

- **After** the orchestrator confirms the Planifest (end of Phase 0)
- **Before** ADRs are generated (Phase 2 reads this as input)
- **One per initiative**, or one per phase if the initiative is phased (`design-spec-phase-2.md`)

---

## Section-by-Section Guidance

### Functional Requirements

Each requirement must be:
- **Specific** - one behaviour, not a category
- **Testable** - you can write a test case from the requirement alone
- **Traceable** - sourced from a user story or acceptance criterion in the brief

| ❌ Bad | ✅ Good |
|--------|---------|
| "The system should handle authentication" | "FR-001: The system shall accept a POST to /api/v1/auth/login with email and password, returning a JWT access token (15min TTL) and refresh token (7d TTL)" |
| "Users can manage their profile" | "FR-003: The system shall accept a PATCH to /api/v1/users/:id with partial profile fields, returning the updated user object" |

### Non-Functional Requirements

Same rule - measurable targets only. These are derived from the NFR section of the Initiative Brief, not invented.

### API Summary

A quick-reference table. The full contract is in `openapi-spec.yaml` - this table is for humans scanning the spec.

### Data Model Summary

Entities, their owner components, and relationships. This feeds into the data contract and the ADRs.

### Open Questions

Material gaps the spec-agent couldn't resolve from the brief. These are **not** filled by assumption - they're reported to the orchestrator, which surfaces them to the human.

---

## Common Mistakes

1. **Inventing requirements.** The spec derives from the brief. If the brief didn't ask for email notifications, the spec doesn't add them.
2. **Vague requirements.** "The system should be secure" is not a requirement. What authentication? What authorization? What data classification?
3. **Missing traceability.** Every FR and NFR must have a Source column pointing to the brief. If it can't be traced, it shouldn't be there.
4. **Mixing concerns.** Functional requirements describe WHAT. Architecture decisions (HOW) belong in ADRs.

---

## How It Connects

```
Initiative Brief -> Design Spec -> ADRs -> Code
                -> OpenAPI Spec ↗        ↗
                -> Data Model ──-> Data Contract
```

The design spec is the central artifact. ADRs explain HOW to implement the requirements. The codegen-agent reads both.

---

## File Location

`plan/{initiative-id}/design-spec.md`

If phased: `plan/{initiative-id}/design-spec-phase-{n}.md`

---

*Template: [design-spec.template.md](design-spec.template.md)*
