# Claude Code — tool configuration
# https://docs.anthropic.com/en/docs/claude-code

TOOL_SKILLS_DIR=".claude/skills"

TOOL_BOOT_FILE="CLAUDE.md"

TOOL_BOOT_CONTENT="# Planifest

This project uses the Planifest framework for agentic development.

To start a new initiative:
  Load the orchestrator skill and execute the Initiative Pipeline.

To make a change:
  Load the orchestrator skill and execute the Change Pipeline.

Key paths:
  planifest-framework/README.md    — framework overview and getting started
  plan/                            — initiative specifications
  src/                             — component code
  planifest-framework/templates/   — artifact templates
  planifest-framework/standards/   — code quality standards"
