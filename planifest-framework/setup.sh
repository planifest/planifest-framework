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
# Planifest — Repository Structure

> The canonical layout for a Planifest-managed repository. Three top-level folders, three concerns.

---

## The Three Folders

```
repo/
├── planifest-framework/        ← The framework (skills, templates, schemas, standards)
│                                 Drop this in. Don't modify it per-project.
│
├── plan/                       ← The specifications (organized by initiative)
│                                 Plans, briefs, specs, ADRs, risk, scope, glossary.
│                                 Everything that describes WHAT to build and WHY.
│
└── src/                        ← The code (organized by component)
                                  Implementation, tests, config, manifests.
                                  Everything that IS the built thing.
```

---

## `planifest-framework/` — The Framework

This folder is the Planifest framework itself. It is the same across every project. You do not modify it per-initiative — you update it when the framework evolves.

```
planifest/
├── skills/           ← Agent instructions (orchestrator + phase skills)
├── templates/        ← File format templates for every artifact
├── schemas/          ← JSON Schema validation definitions
├── standards/        ← Code quality standards
└── spec/             ← This file — the canonical structure definition
```

---

## `plan/` — The Plan/Specifications

Organized by initiative. Each initiative gets a subfolder. This is where humans write briefs and agents write specs. No code lives here.

```
plan/
└── {initiative-id}/
    ├── initiative-brief.md          ← Human input (start here)
    ├── planifest.md                 ← Validated plan (orchestrator output)
    ├── pipeline-run.md              ← Audit trail (per run)
    ├── pipeline-run-phase-2.md      ← Phase 2 audit (if phased)
    │
    ├── design-spec.md               ← Functional & non-functional requirements
    ├── design-spec-phase-2.md       ← Phase 2 spec (if phased)
    ├── openapi-spec.yaml            ← API contract
    ├── scope.md                     ← In / Out / Deferred
    ├── risk-register.md             ← Risk items with likelihood & impact
    ├── domain-glossary.md           ← Ubiquitous language
    ├── security-report.md           ← Security review findings
    ├── quirks.md                    ← Quirks and workarounds
    ├── recommendations.md           ← Improvement suggestions
    │
    └── adr/
        ├── ADR-001-{title}.md       ← Architecture decision records
        ├── ADR-002-{title}.md
        └── ...
```

### Path Rules — plan/

1. **Initiative ID** is kebab-case, human-chosen, and stable.
2. **No nesting** — specs, ADRs, and supporting docs are flat within the initiative folder. One level of subfolders only (adr/).
3. **No code** — nothing executable lives in `plan/`. If it runs, it belongs in `src/`.
4. **Phased initiatives** append the phase number: `design-spec-phase-2.md`, `pipeline-run-phase-2.md`. The `planifest.md` is updated per phase, not duplicated.
5. **ADRs** are numbered sequentially. Never renumber. Superseded ADRs stay with `status: superseded`.

---

## `src/` — The Code

Organized by component. Each component is a subfolder at the top level of `src/`. The component manifest lives with the code, not with the plan.

```
src/
└── {component-id}/
    ├── component.json               ← Component manifest (from template)
    ├── package.json                  ← (or equivalent for the stack)
    │
    ├── src/                          ← Implementation (structure varies by stack)
    │   └── ...
    │
    ├── tests/                        ← Tests
    │   └── ...
    │
    └── docs/
        ├── data-contract.md          ← Schema ownership & invariants
        └── migrations/
            └── proposed-{desc}.md    ← Migration proposals
```

### Path Rules — src/

1. **Component ID** is kebab-case, matches the `id` in `component.json`.
2. **component.json is mandatory** — every component has one. Read it before any work; update it after every build.
3. **Component-specific docs** live with the component at `src/{component-id}/docs/`. These describe the component's data contract, migrations, and technical specifics.
4. **Initiative-level docs** live in `plan/`. The component's `component.json` references the initiative via the `initiative` field.
5. **Existing components** that predate Planifest are retrofitted by adding a `component.json` at their root.

---

## How the Three Folders Connect

```
plan/{initiative-id}/planifest.md
    └── lists component IDs → src/{component-id}/component.json
                                    └── references initiative → plan/{initiative-id}/

plan/{initiative-id}/design-spec.md
    └── functional requirements → implemented in → src/{component-id}/src/

plan/{initiative-id}/adr/ADR-001-*.md
    └── decisions → followed by → src/{component-id}/src/

plan/{initiative-id}/openapi-spec.yaml
    └── API contract → implemented in → src/{component-id}/src/
```

The relationship is bidirectional:
- `planifest.md` lists all component IDs
- Each `component.json` references its initiative ID
- The plan describes WHAT; the code IS the WHAT

---

## Retrofit — Adding Planifest to an Existing Repo

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
echo "════════════════════════════════════════"

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
