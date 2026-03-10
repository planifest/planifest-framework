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

# --- Shared functions ---

copy_skills() {
  local target_dir="$1"

  for skill_dir in "$SKILLS_SRC"/*; do
    if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
      local skill_name
      skill_name="$(basename "$skill_dir")"
      local dest_dir="$target_dir/$skill_name"
      
      mkdir -p "$dest_dir"
      cp "$skill_dir/SKILL.md" "$dest_dir/SKILL.md"
      echo "  + $skill_name/SKILL.md"
      
      for opt_dir in scripts assets references; do
        if [ -d "$skill_dir/$opt_dir" ]; then
          cp -r "$skill_dir/$opt_dir" "$dest_dir/"
        fi
      done
      
      # Bundle shared resources directly into the skill
      if [ -d "$SCRIPT_DIR/templates" ]; then
        mkdir -p "$dest_dir/assets/templates"
        cp -r "$SCRIPT_DIR/templates"/* "$dest_dir/assets/templates/"
      fi
      if [ -d "$SCRIPT_DIR/schemas" ]; then
        mkdir -p "$dest_dir/assets/schemas"
        cp -r "$SCRIPT_DIR/schemas"/* "$dest_dir/assets/schemas/"
      fi
      if [ -d "$SCRIPT_DIR/standards" ]; then
        mkdir -p "$dest_dir/references"
        cp -r "$SCRIPT_DIR/standards"/* "$dest_dir/references/"
      fi
    fi
  done
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

  # Copy skills (now automatically bundles supporting files)
  copy_skills "$skills_dir"

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
