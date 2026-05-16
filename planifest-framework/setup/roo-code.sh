# Roo Code - tool configuration
# https://roosoft.com
#
# Roo Code is a VS Code extension (fork of Cline) that uses .roo/ for configuration.
#
# Skills:    .roo/skills/{name}/SKILL.md           (loaded via .roorules context)
# Workflows: (none - Roo Code uses .roorules for persistent instructions)
# Boot file: .roorules                              (project root - always-on rules file)

TOOL_SKILLS_DIR=".roo/skills"
TOOL_WORKFLOWS_DIR=""

TOOL_BOOT_FILE=".roorules"

TOOL_BOOT_TEMPLATE="planifest-framework/templates/standard-boot.md"

# Enforcement tier — no deterministic hook support in public API; instructions-only (ADR-001, REQ-012)
PLANIFEST_TIER=3
