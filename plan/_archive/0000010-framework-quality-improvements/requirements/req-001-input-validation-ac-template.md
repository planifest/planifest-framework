---
title: "Requirement: REQ-001 - input-validation-ac-template"
summary: "Add an input validation acceptance-criteria section to requirement.template.md for requirements that read filesystem or external content into displayed or injected output."
status: "active"
version: "0.1.0"
---
# Requirement: REQ-001 - input-validation-ac-template

**Skill:** planifest-spec-agent
**Feature:** 0000010-framework-quality-improvements
**Source:** P8 build report recommendation: S-001 root cause was a spec gap — REQ-008 lacked input validation ACs for featureId read from filesystem.
**Priority:** must-have

> Written by the spec-agent. This file contains the requirements for a single feature so that agents can build it without loading the entire project scope.

---

## Functional Requirements

- `planifest-framework/templates/requirement.template.md` MUST include a new optional section `## Input Validation` that appears after `## Acceptance Criteria`
- The section MUST be marked as conditional: it is only required when the requirement involves reading content from the filesystem, environment variables, hook stdin, or any other untrusted external source that is subsequently interpolated into model context, hook banners, log output, or displayed text
- The section MUST contain a pre-filled AC pattern with placeholders: allowed character set, maximum length, behaviour on validation failure (default value or hard exit), and whether the raw value is ever logged
- The template comment MUST instruct the spec-agent: "Include this section whenever the requirement reads untrusted content and uses it in output visible to the model or user"

## Acceptance Criteria

- [ ] `planifest-framework/templates/requirement.template.md` contains a `## Input Validation` section after `## Acceptance Criteria`
- [ ] The section is wrapped in a comment indicating it is conditional (only required for filesystem/external-input requirements)
- [ ] The section contains at least these AC placeholders: allowed character pattern, max length, failure behaviour, logging policy
- [ ] An example filled-in `## Input Validation` block is present in the template as a comment, showing the pattern as applied to a featureId-style input
- [ ] The existing `## Functional Requirements` and `## Acceptance Criteria` sections are unchanged

## Dependencies

- None — standalone template change
