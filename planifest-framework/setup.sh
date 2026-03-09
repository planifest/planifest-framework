#!/usr/bin/env bash
set -euo pipefail

# Planifest Setup — Configures skills for your agentic coding tool.
#
# Usage:  ./planifest-framework/setup.sh <tool>
#
# Tools:  claude-code | cursor | codex | antigravity | copilot | all

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"

# --- Skill metadata ---

declare -A SKILL_NAMES=(
  [orchestrator]="planifest-orchestrator"
  [spec-agent]="planifest-spec-agent"
  [adr-agent]="planifest-adr-agent"
  [codegen-agent]="planifest-codegen-agent"
  [validate-agent]="planifest-validate-agent"
  [security-agent]="planifest-security-agent"
  [change-agent]="planifest-change-agent"
  [docs-agent]="planifest-docs-agent"
)

declare -A SKILL_DESCS=(
  [orchestrator]="Guides a human from an initial idea to a complete specification, then executes the Planifest pipeline to build it. Use this for new initiatives or full pipeline runs."
  [spec-agent]="Produces specification artifacts (design spec, OpenAPI spec, scope, risk register, domain glossary) for an initiative. Invoked by the orchestrator during Phase 1."
  [adr-agent]="Produces Architecture Decision Records for each significant decision in the specification. Invoked by the orchestrator during Phase 2."
  [codegen-agent]="Generates the full implementation from the specification artifacts — application code, tests, infrastructure, configuration. Invoked during Phase 3."
  [validate-agent]="Runs CI checks (lint, typecheck, test, build) and self-corrects up to 5 times. Invoked during Phase 4."
  [security-agent]="Performs a security review of the implementation, producing a security report with specific findings. Invoked during Phase 5."
  [change-agent]="Handles modifications to existing initiatives — loads domain context, implements the minimum change, validates, and updates documentation."
  [docs-agent]="Produces complete per-component documentation, system-wide registry, dependency graph, and pipeline-run audit trail. Invoked during Phase 6."
)

# --- Tool definitions ---

declare -A TOOL_SKILLS_DIR=(
  [claude-code]=".claude/skills"
  [cursor]=".cursor/skills"
  [codex]=".agents/skills"
  [antigravity]=".gemini/skills"
  [copilot]=".github/skills"
)

# --- Functions ---

copy_skill() {
  local skill_key="$1"
  local target_dir="$2"
  local src_file="$SKILLS_SRC/${skill_key}-SKILL.md"
  local dest_dir="$target_dir/$skill_key"
  local dest_file="$dest_dir/SKILL.md"

  mkdir -p "$dest_dir"

  # Add YAML frontmatter + original content
  {
    echo "---"
    echo "name: ${SKILL_NAMES[$skill_key]}"
    echo "description: ${SKILL_DESCS[$skill_key]}"
    echo "---"
    echo ""
    cat "$src_file"
  } > "$dest_file"

  echo "  ✓ $skill_key/SKILL.md"
}

copy_support() {
  local target_dir="$1"
  local dir_name="$2"
  local src="$SCRIPT_DIR/$dir_name"
  local dest="$target_dir/_planifest-$dir_name"

  if [ -d "$src" ]; then
    mkdir -p "$dest"
    cp -r "$src"/* "$dest/"
    echo "  ✓ _planifest-$dir_name/"
  fi
}

write_boot_file() {
  local path="$1"
  local content="$2"

  mkdir -p "$(dirname "$path")"
  if [ ! -f "$path" ]; then
    echo "$content" > "$path"
    echo "  ✓ $(basename "$path") (created)"
  else
    echo "  ⊘ $(basename "$path") (already exists, skipped)"
  fi
}

setup_tool() {
  local tool="$1"
  local skills_dir="$PROJECT_ROOT/${TOOL_SKILLS_DIR[$tool]}"

  echo ""
  echo "▸ Setting up $tool"
  echo "  Skills directory: ${TOOL_SKILLS_DIR[$tool]}/"

  # Copy skills
  for skill_key in "${!SKILL_NAMES[@]}"; do
    copy_skill "$skill_key" "$skills_dir"
  done

  # Copy supporting files
  copy_support "$skills_dir" "templates"
  copy_support "$skills_dir" "standards"
  copy_support "$skills_dir" "schemas"

  # Create boot files
  case "$tool" in
    claude-code)
      write_boot_file "$PROJECT_ROOT/CLAUDE.md" "# Planifest

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
      ;;
    cursor)
      write_boot_file "$PROJECT_ROOT/.cursor/rules/planifest.mdc" "---
description: Planifest framework for agentic development
globs: [\"**/*\"]
---

This project uses the Planifest framework. Load the orchestrator skill for any initiative or change."
      ;;
    codex)
      write_boot_file "$PROJECT_ROOT/AGENTS.md" "# Planifest

This project uses the Planifest framework for agentic development.
Load the orchestrator skill for any initiative or change."
      ;;
    copilot)
      write_boot_file "$PROJECT_ROOT/.github/copilot-instructions.md" "# Planifest

This project uses the Planifest framework. Load the orchestrator skill for any initiative or change."
      ;;
  esac

  echo "  Done."
}

# --- Main ---

TOOL="${1:-}"

if [ -z "$TOOL" ]; then
  echo ""
  echo "Planifest Setup — Configure skills for your agentic coding tool."
  echo ""
  echo "Usage: ./planifest-framework/setup.sh <tool>"
  echo ""
  echo "Tools:"
  echo "  claude-code    → .claude/skills/ + CLAUDE.md"
  echo "  cursor         → .cursor/skills/ + .cursor/rules/planifest.mdc"
  echo "  codex          → .agents/skills/ + AGENTS.md"
  echo "  antigravity    → .gemini/skills/"
  echo "  copilot        → .github/skills/ + copilot-instructions.md"
  echo "  all            → all of the above"
  echo ""
  echo "Run from the repository root."
  exit 0
fi

echo "Planifest Setup"
echo "════════════════════════════════════════"

if [ "$TOOL" = "all" ]; then
  for t in "${!TOOL_SKILLS_DIR[@]}"; do
    setup_tool "$t"
  done
elif [ -n "${TOOL_SKILLS_DIR[$TOOL]+x}" ]; then
  setup_tool "$TOOL"
else
  echo "Unknown tool: $TOOL"
  echo "Valid tools: ${!TOOL_SKILLS_DIR[*]}, all"
  exit 1
fi

echo ""
echo "✓ Setup complete."
echo "  Source of truth: planifest-framework/"
echo "  Re-run after updating framework files."
