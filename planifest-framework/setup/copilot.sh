# GitHub Copilot - tool configuration
# https://docs.github.com/en/copilot
#
# Skills:    .github/skills/{name}/SKILL.md       (auto-discovered)
# Workflows: .github/copilot-workflows/{name}.md   (natural language workflows - avoids GitHub Actions conflict)
# Boot file: .github/copilot-instructions.md

TOOL_SKILLS_DIR=".github/skills"
TOOL_WORKFLOWS_DIR=".github/copilot-workflows"

TOOL_BOOT_FILE=".github/copilot-instructions.md"

TOOL_BOOT_CONTENT="# Planifest — Mandatory Framework Rules

This project uses the Planifest framework. These rules are non-negotiable and apply to every session.

## Hard Limits

1. **No code without a confirmed spec.** You MUST NOT generate application code unless a confirmed Planifest exists at plan/current/planifest.md. If none exists, load the planifest-orchestrator skill and begin Phase 0 (Assess and Coach). Do NOT skip to code generation.
2. **No code without documentation.** Every component MUST have a component.json manifest and docs/ artifacts. Never produce code without its corresponding documentation.
3. **No direct schema modification.** Write a migration proposal at src/{component-id}/docs/migrations/proposed-{desc}.md and STOP for human approval.
4. **Destructive schema operations require human approval.** Drop column, drop table, rename — propose and stop. No exceptions.
5. **Data is owned by one component.** Never write to data owned by another component.
6. **No credentials in context.** If a credential appears anywhere, flag it immediately and do not use it.
7. **Update documentation after any deviation.** If implementation required deviating from the spec, plan, or design decisions, you MUST update the affected artifacts (plan/, docs/, or component.json) to reflect what was actually built. Documentation must always match reality.

## How to Handle Requests

**When the user asks to build, implement, or add something:**
1. Check whether a confirmed plan/current/planifest.md exists
2. If it exists — load the planifest-orchestrator skill and proceed with the appropriate pipeline phase
3. If it does not exist — load the planifest-orchestrator skill and begin Phase 0
4. Do NOT skip ahead to code generation under any circumstances

**When the user asks to modify existing code:**
Load the planifest-orchestrator skill. It will triage the request across three tracks:
- **Fast Path** (/fast-path) — trivial fixes only (styling, copy, isolated pure-function bugs). No spec, no ADR. Commits must use fix(fast-path): prefix.
- **Change Pipeline** (/change-pipeline) — targeted changes to existing components.
- **Initiative Pipeline** (/initiative-pipeline) — new features or new work.

**When the user asks a question or requests non-code help:**
Respond normally. These rules govern code generation, not conversation.

**After human review and acceptance:**
Move the active plan from plan/current/ to plan/_archive/{initiative-id}/. The initiative is not complete until the plan is archived.

## Workflows

- initiative-pipeline: Full spec-to-ship pipeline for new initiatives
- change-pipeline: Modify an existing initiative
- fast-path: Trivial fix without spec overhead (styling, copy, pure-function bugs)
- retrofit: Onboard an existing codebase

## Key Paths

  planifest-framework/README.md    — framework overview and getting started
  plan/                            — initiative specifications
  plan/changelog/                  — change audit logs
  docs/                            — living repository documentation
  src/                             — component code (each with component.json)
  planifest-framework/templates/   — artifact templates
  planifest-framework/standards/   — code quality standards"
