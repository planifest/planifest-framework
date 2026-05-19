---
title: "Requirement: REQ-016 - P6 Gate B: Docs Update Recommendation"
summary: "Agent assesses and recommends whether the change requires a docs update; human confirms."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-016 - P6 Gate B: Docs Update Recommendation

**Skill:** planifest-docs-agent
**Feature:** 0000014-improve-adoption-mode-selection
**Source:** US-002
**Priority:** must-have

---

## User Story

As a framework user, I receive a suggested version number after confirming adoption mode, so that I don't have to derive it manually.

---

## Functional Requirements
- After the docs/ existence check (REQ-015), the docs-agent assesses whether the change in this pipeline run requires a docs update
- The agent makes a recommendation: "This change modifies [components/contracts/APIs] — I recommend updating [specific docs artifacts]. Shall I proceed?" or "This change is internal only — I recommend no docs update is needed. Confirm?"
- The recommendation is based on: whether public-facing components changed, whether API contracts changed, whether component manifests changed
- Human confirms or overrides the recommendation — one question, one answer (REQ-012)
- If human confirms no update needed, the docs-agent records the decision in the build log and skips documentation generation
- If human confirms update needed, the docs-agent proceeds with normal P6 execution

## Acceptance Criteria
- [ ] Docs-agent assesses and recommends before generating any documentation
- [ ] Recommendation cites specific artifacts or components that triggered it
- [ ] Human confirmation is required — docs-agent does not assume either way
- [ ] "No update" decision is recorded in the build log with the human's confirmation
- [ ] One question per turn (REQ-012)

## Dependencies
- REQ-015 (P6 Gate A must pass first)
- REQ-012 (one-question rule)
