---
title: "Requirement: req-001 - build-target-field"
status: "active"
version: "0.1.0"
---
# Requirement: req-001 — Build target field in feature-brief template

**Feature:** 0000007-agent-optimisation
**Source:** User story — "As a developer, I declare `Build target: docker` in my stack so agents never check host runtimes when building in Docker"
**Priority:** must-have

---

## Functional Requirements

- The Stack table in `planifest-framework/templates/feature-brief.template.md` MUST include a `Build target` row with allowed values `local | docker | ci-only`
- The row MUST appear alongside other compute/infrastructure stack rows
- The placeholder value MUST indicate the three options clearly

## Acceptance Criteria

- [ ] `feature-brief.template.md` stack table contains a `Build target` row
- [ ] Allowed values documented as `local | docker | ci-only`
- [ ] Row is in the correct position (near compute/IaC rows in the stack table)

## Dependencies

- None — this is a template-only change
