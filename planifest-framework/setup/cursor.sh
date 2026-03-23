# Cursor - tool configuration
# https://docs.cursor.com
#
# Skills:    .cursor/skills/{name}/SKILL.md       (auto-discovered)
# Workflows: embedded in .cursor/rules/*.mdc      (Cursor uses rules, not a separate workflow dir)
# Boot file: .cursor/rules/planifest.mdc

TOOL_SKILLS_DIR=".cursor/skills"
TOOL_WORKFLOWS_DIR=""

TOOL_BOOT_FILE=".cursor/rules/planifest.mdc"

TOOL_BOOT_CONTENT='---
description: Planifest framework — mandatory rules for all code generation
globs: ["**/*"]
alwaysApply: true
---

# Planifest — Mandatory Framework Rules

This project uses the Planifest framework. These rules are non-negotiable and apply to every session.

## Hard Limits

1. **No code without a confirmed spec.** You MUST NOT generate application code unless a confirmed Planifest exists at plan/current/planifest.md. If none exists, load the planifest-orchestrator skill and begin Phase 0 (Assess and Coach). Do NOT skip to code generation.
2. **No code without documentation.** Every component MUST have a component.json manifest and docs/ artifacts. Never produce code without its corresponding documentation.
3. **No direct schema modification.** Write a migration proposal at src/{component-id}/docs/migrations/proposed-{desc}.md and STOP for human approval.
4. **Destructive schema operations require human approval.** Drop column, drop table, rename — propose and stop. No exceptions.
5. **Data is owned by one component.** Never write to data owned by another component.
6. **No credentials in context.** If a credential appears anywhere, flag it immediately and do not use it.

## How to Handle Requests

**When the user asks to build, implement, or add something:**
1. Check whether a confirmed plan/current/planifest.md exists
2. If it exists — load the planifest-orchestrator skill and proceed with the appropriate pipeline phase
3. If it does not exist — load the planifest-orchestrator skill and begin Phase 0
4. Do NOT skip ahead to code generation under any circumstances

**When the user asks to modify existing code:**
Load the planifest-orchestrator skill and use the Change Pipeline.

**When the user asks a question or requests non-code help:**
Respond normally. These rules govern code generation, not conversation.

## Workflows

- **Initiative Pipeline**: Load the planifest-orchestrator skill and execute the Initiative Pipeline. Provide an initiative brief at plan/current/initiative-brief.md.
- **Change Pipeline**: Load the planifest-orchestrator skill and execute the Change Pipeline. Provide initiative ID, component ID, and change request.
- **Retrofit**: Load the planifest-orchestrator skill with retrofit adoption mode.

## Key Paths

- planifest-framework/README.md    — framework overview and getting started
- plan/                            — initiative specifications
- plan/changelog/                  — change audit logs
- docs/                            — living repository documentation
- src/                             — component code (each with component.json)
- planifest-framework/templates/   — artifact templates
- planifest-framework/standards/   — code quality standards'
