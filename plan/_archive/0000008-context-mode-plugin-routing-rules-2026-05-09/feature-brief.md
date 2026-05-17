---
title: "Feature Brief - context-mode plugin routing rules removal"
summary: "Remove the context-mode-agents.md routing rules template now that the plugin provides routing rules via its system prompt."
status: "approved"
version: "0.1.0"
---
# Feature Brief - context-mode plugin routing rules removal

**Feature ID:** 0000008-context-mode-plugin-routing-rules

---

## Business Goal

The context-mode marketplace plugin now injects routing rules automatically via its system prompt when installed. The framework was previously copying a `context-mode-agents.md` template to provide these rules. This duplication creates maintenance burden and will cause drift. Removing the template and all references makes the plugin the single source of truth for routing rules.

---

## Features

| Feature | User Stories | Priority | Phase |
|---------|-------------|----------|-------|
| Remove context-mode-agents.md templates | As a maintainer, I no longer maintain two copies of routing rules | must-have | 1 |
| Update setup scripts | As a user running setup, the `--context-mode-mcp` flag no longer writes AGENTS.md routing rules | must-have | 1 |
| Update all documentation | As a user reading docs, docs accurately describe what the plugin and setup each provide | must-have | 1 |

---

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| planifest-framework | framework | existing | Setup scripts, templates, docs |

### Data Ownership

N/A — no data stores involved.

### Integration Points

| From | To | Method | Contract |
|------|-----|--------|----------|
| context-mode plugin | agent | system prompt | Routing rules injected at session start |
| setup.sh / setup.ps1 | project | file copy | Enforcement hooks only (no longer routing rules) |

---

## Stack

N/A — shell scripts and markdown.

---

## Scope Boundaries

### In Scope
- Delete all `context-mode-agents.md` files (5 total: framework template + 4 skill copies)
- Remove AGENTS.md routing rules copy step from `setup.sh` and `setup.ps1`
- Update `--context-mode-mcp` help text in both setup scripts
- Update `docs/context-mode.md` — remove "Routing rules" install step, update Supported tools table
- Update `planifest-framework/tool-setup-reference.md` — flag description, Creates section, Context-Mode Integration section
- Update `planifest-framework/getting-started.md` — Option: Context-Mode description
- Update `standard-boot.md` in framework template + 4 skill copies — remove AGENTS.md reference
- Update `CLAUDE.md` — same standard-boot.md change

### Out of Scope
- Plan/archive history docs (accurate at time of writing, no value in retroactively editing)
- `AGENTS.md` file itself (used by Codex as boot file — not a routing rules file)
- Any changes to the enforcement hooks themselves

### Deferred
- None

---

## Acceptance Criteria

- [ ] No `context-mode-agents.md` files exist in the repo
- [ ] `setup.sh` and `setup.ps1` do not copy any routing rules file when `--context-mode-mcp` is passed
- [ ] `--context-mode-mcp` help text describes enforcement hooks only
- [ ] `docs/context-mode.md` describes the plugin as source of routing rules
- [ ] `tool-setup-reference.md` removes Routing Rules subsection
- [ ] All `standard-boot.md` copies and `CLAUDE.md` no longer reference `AGENTS.md` for routing rules
