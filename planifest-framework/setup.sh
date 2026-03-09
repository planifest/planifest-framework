#!/usr/bin/env bash
set -euo pipefail

# Planifest Setup — Configures skills for your agentic coding tool.
#
# Usage:  ./planifest-framework/setup.sh <tool>
#
# Tools:  claude-code | cursor | codex | antigravity | copilot | all
#
# Each tool's specific config lives in setup/<tool>.sh
# This script handles shared logic only.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"
WORKFLOWS_SRC="$SCRIPT_DIR/workflows"
SETUP_DIR="$SCRIPT_DIR/setup"

VALID_TOOLS="claude-code cursor codex antigravity copilot"

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

# --- Shared functions ---

copy_skill() {
  local skill_key="$1"
  local target_dir="$2"
  local src_file="$SKILLS_SRC/${skill_key}-SKILL.md"
  local dest_dir="$target_dir/$skill_key"
  local dest_file="$dest_dir/SKILL.md"

  mkdir -p "$dest_dir"

  {
    echo "---"
    echo "name: ${SKILL_NAMES[$skill_key]}"
    echo "description: ${SKILL_DESCS[$skill_key]}"
    echo "---"
    echo ""
    cat "$src_file"
  } > "$dest_file"

  echo "  + $skill_key/SKILL.md"
}

copy_support() {
  local target_dir="$1"
  local dir_name="$2"
  local src="$SCRIPT_DIR/$dir_name"
  local dest="$target_dir/_planifest-$dir_name"

  if [ -d "$src" ]; then
    mkdir -p "$dest"
    cp -r "$src"/* "$dest/"
    echo "  + _planifest-$dir_name/"
  fi
}

write_boot_file() {
  local path="$1"
  local content="$2"

  mkdir -p "$(dirname "$path")"
  if [ ! -f "$path" ]; then
    echo "$content" > "$path"
    echo "  + $(basename "$path") (created)"
  else
    echo "  - $(basename "$path") (already exists, skipped)"
  fi
}

copy_workflow() {
  local workflow_file="$1"
  local target_dir="$2"
  local name
  name="$(basename "$workflow_file" .md)"
  local dest_file="$target_dir/${name}.md"

  mkdir -p "$target_dir"
  cp "$workflow_file" "$dest_file"
  echo "  + workflows/${name}.md"
}

setup_tool() {
  local tool="$1"
  local tool_config="$SETUP_DIR/${tool}.sh"

  if [ ! -f "$tool_config" ]; then
    echo "Error: no config file at setup/${tool}.sh"
    exit 1
  fi

  # Load tool-specific config
  source "$tool_config"

  local skills_dir="$PROJECT_ROOT/$TOOL_SKILLS_DIR"

  echo ""
  echo "  Setting up $tool"
  echo "  Skills directory: $TOOL_SKILLS_DIR/"

  # Copy skills
  for skill_key in "${!SKILL_NAMES[@]}"; do
    copy_skill "$skill_key" "$skills_dir"
  done

  # Copy supporting files
  copy_support "$skills_dir" "templates"
  copy_support "$skills_dir" "standards"
  copy_support "$skills_dir" "schemas"

  # Copy workflows (if tool defines a workflow dir)
  if [ -n "${TOOL_WORKFLOWS_DIR:-}" ] && [ -d "$WORKFLOWS_SRC" ]; then
    local workflows_dir="$PROJECT_ROOT/$TOOL_WORKFLOWS_DIR"
    for wf in "$WORKFLOWS_SRC"/*.md; do
      [ -f "$wf" ] && copy_workflow "$wf" "$workflows_dir"
    done
  fi

  # Create boot file (if tool defines one)
  if [ -n "$TOOL_BOOT_FILE" ]; then
    write_boot_file "$PROJECT_ROOT/$TOOL_BOOT_FILE" "$TOOL_BOOT_CONTENT"
  fi

  echo "  Done."
}

# --- Main ---

TOOL="${1:-}"

if [ -z "$TOOL" ]; then
  echo ""
  echo "Planifest Setup"
  echo ""
  echo "Usage: ./planifest-framework/setup.sh <tool>"
  echo ""
  echo "Tools:"
  for t in $VALID_TOOLS; do
    echo "  $t"
  done
  echo "  all"
  echo ""
  echo "Run from the repository root."
  echo "Each tool's config: planifest-framework/setup/<tool>.sh"
  exit 0
fi

echo "Planifest Setup"
echo "════════════════════════════════════════"

if [ "$TOOL" = "all" ]; then
  for t in $VALID_TOOLS; do
    setup_tool "$t"
  done
elif echo "$VALID_TOOLS" | grep -qw "$TOOL"; then
  setup_tool "$TOOL"
else
  echo "Unknown tool: $TOOL"
  echo "Valid tools: $VALID_TOOLS, all"
  exit 1
fi

echo ""
echo "Setup complete."
echo "  Source of truth: planifest-framework/"
echo "  Re-run after updating framework files."
