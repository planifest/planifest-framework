#!/usr/bin/env bash
set -euo pipefail

# Planifest Setup - Configures skills for your agentic coding tool.
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

initialize_repo() {
  echo ""
  echo "  Initializing Repository Structure"

  local gitignore_src="$SCRIPT_DIR/.gitignore"
  local gitignore_dest="$PROJECT_ROOT/.gitignore"
  
  if [ -f "$gitignore_src" ]; then
    if [ ! -f "$gitignore_dest" ]; then
      cp "$gitignore_src" "$gitignore_dest"
      echo "  + .gitignore (copied)"
    else
      echo "  - .gitignore (already exists at root, skipped)"
    fi
  else
    echo "  ! Warning: .gitignore not found in framework directory ($gitignore_src)"
  fi

  local src_dir="$PROJECT_ROOT/src"
  if [ ! -d "$src_dir" ]; then
    mkdir -p "$src_dir"
    echo "  + src/ (created)"
  fi
  
  if [ ! -f "$src_dir/README.md" ]; then
    cat << 'EOF' > "$src_dir/README.md"
# src/

Components live here. Each component is a subfolder with a `component.json` manifest.

See [planifest/spec/initiative-structure.md](../planifest/spec/initiative-structure.md) for the canonical layout.
EOF
    echo "  + src/README.md (created)"
  fi

  local plan_dir="$PROJECT_ROOT/plan"
  if [ ! -d "$plan_dir" ]; then
    mkdir -p "$plan_dir"
    echo "  + plan/ (created)"
  fi

  if [ ! -f "$plan_dir/README.md" ]; then
    cat << 'EOF' > "$plan_dir/README.md"
# plan/

Initiative specifications live here. Each initiative gets a subfolder.

See [plan/initiative-structure.md](initiative-structure.md) for the canonical layout.
EOF
    echo "  + plan/README.md (created)"
  fi

  if [ ! -f "$plan_dir/initiative-structure.md" ]; then
    cat << 'EOF' > "$plan_dir/initiative-structure.md"
# Planifest â€” Repository Structure

> The canonical layout for a Planifest-managed repository. Three top-level folders, three concerns.

---

## The Three Folders

```
repo/
â”œâ”€â”€ planifest-framework/        â† The framework (skills, templates, schemas, standards)
â”‚                                 Drop this in. Don't modify it per-project.
â”‚
â”œâ”€â”€ plan/                       â† The specifications (organized by initiative)
â”‚                                 Plans, briefs, specs, ADRs, risk, scope, glossary.
â”‚                                 Everything that describes WHAT to build and WHY.
â”‚
â””â”€â”€ src/                        â† The code (organized by component)
                                  Implementation, tests, config, manifests.
                                  Everything that IS the built thing.
```

---

## `planifest-framework/` â€” The Framework

This folder is the Planifest framework itself. It is the same across every project. You do not modify it per-initiative â€” you update it when the framework evolves.

```
planifest/
â”œâ”€â”€ skills/           â† Agent instructions (orchestrator + phase skills)
â”œâ”€â”€ templates/        â† File format templates for every artifact
â”œâ”€â”€ schemas/          â† JSON Schema validation definitions
â”œâ”€â”€ standards/        â† Code quality standards
â””â”€â”€ spec/             â† This file â€” the canonical structure definition
```

---

## `plan/` â€” The Plan/Specifications

Organized by initiative. Each initiative gets a subfolder. This is where humans write briefs and agents write specs. No code lives here.

```
plan/
â””â”€â”€ {initiative-id}/
    â”œâ”€â”€ initiative-brief.md          â† Human input (start here)
    â”œâ”€â”€ planifest.md                 â† Validated plan (orchestrator output)
    â”œâ”€â”€ pipeline-run.md              â† Audit trail (per run)
    â”œâ”€â”€ pipeline-run-phase-2.md      â† Phase 2 audit (if phased)
    â”‚
    â”œâ”€â”€ design-spec.md               â† Functional & non-functional requirements
    â”œâ”€â”€ design-spec-phase-2.md       â† Phase 2 spec (if phased)
    â”œâ”€â”€ openapi-spec.yaml            â† API contract
    â”œâ”€â”€ scope.md                     â† In / Out / Deferred
    â”œâ”€â”€ risk-register.md             â† Risk items with likelihood & impact
    â”œâ”€â”€ domain-glossary.md           â† Ubiquitous language
    â”œâ”€â”€ security-report.md           â† Security review findings
    â”œâ”€â”€ quirks.md                    â† Quirks and workarounds
    â”œâ”€â”€ recommendations.md           â† Improvement suggestions
    â”‚
    â””â”€â”€ adr/
        â”œâ”€â”€ ADR-001-{title}.md       â† Architecture decision records
        â”œâ”€â”€ ADR-002-{title}.md
        â””â”€â”€ ...
```

### Path Rules â€” plan/

1. **Initiative ID** is kebab-case, human-chosen, and stable.
2. **No nesting** â€” specs, ADRs, and supporting docs are flat within the initiative folder. One level of subfolders only (adr/).
3. **No code** â€” nothing executable lives in `plan/`. If it runs, it belongs in `src/`.
4. **Phased initiatives** append the phase number: `design-spec-phase-2.md`, `pipeline-run-phase-2.md`. The `planifest.md` is updated per phase, not duplicated.
5. **ADRs** are numbered sequentially. Never renumber. Superseded ADRs stay with `status: superseded`.

---

## `src/` â€” The Code

Organized by component. Each component is a subfolder at the top level of `src/`. The component manifest lives with the code, not with the plan.

```
src/
â””â”€â”€ {component-id}/
    â”œâ”€â”€ component.json               â† Component manifest (from template)
    â”œâ”€â”€ package.json                  â† (or equivalent for the stack)
    â”‚
    â”œâ”€â”€ src/                          â† Implementation (structure varies by stack)
    â”‚   â””â”€â”€ ...
    â”‚
    â”œâ”€â”€ tests/                        â† Tests
    â”‚   â””â”€â”€ ...
    â”‚
    â””â”€â”€ docs/
        â”œâ”€â”€ data-contract.md          â† Schema ownership & invariants
        â””â”€â”€ migrations/
            â””â”€â”€ proposed-{desc}.md    â† Migration proposals
```

### Path Rules â€” src/

1. **Component ID** is kebab-case, matches the `id` in `component.json`.
2. **component.json is mandatory** â€” every component has one. Read it before any work; update it after every build.
3. **Component-specific docs** live with the component at `src/{component-id}/docs/`. These describe the component's data contract, migrations, and technical specifics.
4. **Initiative-level docs** live in `plan/`. The component's `component.json` references the initiative via the `initiative` field.
5. **Existing components** that predate Planifest are retrofitted by adding a `component.json` at their root.

---

## How the Three Folders Connect

```
plan/planifest.md
    â””â”€â”€ lists component IDs â†’ src/{component-id}/component.json
                                    â””â”€â”€ references initiative â†’ plan/

plan/design-spec.md
    â””â”€â”€ functional requirements â†’ implemented in â†’ src/{component-id}/src/

plan/adr/ADR-001-*.md
    â””â”€â”€ decisions â†’ followed by â†’ src/{component-id}/src/

plan/openapi-spec.yaml
    â””â”€â”€ API contract â†’ implemented in â†’ src/{component-id}/src/
```

The relationship is bidirectional:
- `planifest.md` lists all component IDs
- Each `component.json` references its initiative ID
- The plan describes WHAT; the code IS the WHAT

---

## Retrofit â€” Adding Planifest to an Existing Repo

If the repo already has code:

1. Drop `planifest/` into the repo root
2. Create `plan/` for the first initiative
3. Move existing components under `src/` (or leave them if they're already there)
4. Add a `component.json` to each existing component
5. The orchestrator's retrofit mode will read the codebase and infer the existing architecture

---

*Templates for each file are in [planifest/templates/](../templates/). Skills reference these paths.*
EOF
    echo "  + plan/initiative-structure.md (created)"
  fi
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
echo "â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•"

initialize_repo

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
