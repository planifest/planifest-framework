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
description: Planifest framework for agentic development
globs: ["**/*"]
---

This project uses the Planifest framework. Load the orchestrator skill for any initiative or change.

## Workflows

- **Initiative Pipeline**: Load the orchestrator skill. Provide an initiative brief at plan/initiative-brief.md
- **Change Pipeline**: Load the orchestrator skill. Provide initiative ID, component ID, and change request.
- **Retrofit**: Load the orchestrator skill with retrofit adoption mode.

## Key paths

- planifest-framework/README.md    - framework overview and getting started
- plan/                            - current initiative specifications
  plan/changelog/                  - change audit logs
  docs/                            - living repository documentation
- src/                             - component code
- planifest-framework/templates/   - artifact templates
- planifest-framework/standards/   - code quality standards'
