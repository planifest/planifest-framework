# Claude Code - tool configuration
# https://docs.anthropic.com/en/docs/claude-code
#
# Skills:    .claude/skills/{name}/SKILL.md      (auto-discovered)
# Workflows: .claude/commands/{name}.md           (becomes /name slash command)
# Boot file: CLAUDE.md                            (project root)

TOOL_SKILLS_DIR=".claude/skills"
TOOL_WORKFLOWS_DIR=".claude/commands"

TOOL_BOOT_FILE="CLAUDE.md"

TOOL_BOOT_CONTENT="# Planifest

This project uses the Planifest framework for agentic development.

To start a new initiative:
  Load the orchestrator skill and execute the Initiative Pipeline.
  Or use the /initiative-pipeline command.

To make a change:
  Load the orchestrator skill and execute the Change Pipeline.
  Or use the /change-pipeline command.

To retrofit an existing codebase:
  Use the /retrofit command.

Key paths:
  planifest-framework/README.md    - framework overview and getting started
  plan/                            - initiative specifications
  src/                             - component code
  planifest-framework/templates/   - artifact templates
  planifest-framework/standards/   - code quality standards"
