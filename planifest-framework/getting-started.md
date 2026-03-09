# Getting Started with Planifest

> Step-by-step instructions for humans setting up a Planifest project.

---

## Prerequisites

- An agentic coding tool: Claude Code, Cursor, Codex, Antigravity, or GitHub Copilot
- A terminal with Bash (macOS/Linux) or PowerShell (Windows)

---

## New Project

### 1. Add the framework

Copy the `planifest-framework/` folder into your repository root. This is the only thing you need — it contains the skills, templates, standards, and setup scripts.

### 2. Create the project structure

```
mkdir plan src
```

These are the two working directories:
- `plan/` — initiative specifications, design specs, ADRs, scope documents
- `src/` — component code, each component in its own subfolder

See [initiative-structure.md](../plan/initiative-structure.md) for the full layout.

### 3. Run the setup script

This copies skills into the directory your agentic tool expects:

**macOS / Linux:**
```bash
chmod +x planifest-framework/setup.sh
./planifest-framework/setup.sh claude-code      # or cursor, codex, antigravity, copilot, all
```

**Windows (PowerShell):**
```powershell
.\planifest-framework\setup.ps1 claude-code     # or cursor, codex, antigravity, copilot, all
```

The script creates:
- Skill folders with YAML frontmatter (so the tool auto-discovers them)
- Supporting files (templates, standards, schemas) alongside the skills
- A boot file for your tool (e.g., `CLAUDE.md`, `AGENTS.md`)

See [tool-setup-reference.md](tool-setup-reference.md) for what each tool expects.

### 4. Write your first initiative brief

Use the template:
```
cp planifest-framework/templates/initiative-brief.template.md plan/my-initiative/initiative-brief.md
```

Fill it in. The [initiative brief guide](templates/initiative-brief-guide.md) walks you through each section.

### 5. Start the orchestrator

Open your agentic tool. The orchestrator skill is now auto-discovered. Tell it:

```
Execute the Planifest Initiative Pipeline.
Initiative brief: plan/my-initiative/initiative-brief.md
```

The orchestrator will:
1. Assess your brief against the three layers (Product, Architecture, Engineering)
2. Coach you through any gaps — one question at a time
3. Produce the validated Planifest
4. Execute the pipeline: Spec → ADRs → Code → Validate → Security → Docs

---

## Retrofit an Existing Project

1. Copy `planifest-framework/` into your repo root
2. Run the setup script for your tool
3. Add a `component.json` manifest to each existing component in `src/` — use the [component manifest template](templates/component-manifest.template.json) and [guide](templates/component-manifest-guide.md)
4. Tell the orchestrator to use **retrofit** adoption mode:

```
Execute the Planifest Initiative Pipeline in retrofit mode.
Initiative brief: plan/my-initiative/initiative-brief.md
```

The orchestrator will read your codebase, infer the existing architecture, and reconcile the brief against reality.

---

## Making Changes

For modifications to an existing initiative:

```
Execute the Planifest Change Pipeline.
Initiative ID: my-initiative
Component ID: auth-service
Change request: Add refresh token rotation
```

The change-agent handles it — no need to re-run the full pipeline.

---

## Updating the Framework

After updating any files in `planifest-framework/` (skills, templates, standards):

```bash
# Re-run setup to sync changes to your tool's directory
./planifest-framework/setup.sh claude-code       # or your tool
```

The setup script overwrites the generated copies. The source of truth is always `planifest-framework/`.

---

## What to Commit

| Path | Commit? | Why |
|------|:-------:|-----|
| `planifest-framework/` | ✅ | Source of truth — shared with team |
| `plan/` | ✅ | Initiative specs, ADRs, scope docs |
| `src/` | ✅ | Component code |
| `.claude/`, `.cursor/`, `.agents/`, `.gemini/`, `.github/skills/` | Optional | Generated copies — can be `.gitignore`d and regenerated |
| `CLAUDE.md`, `AGENTS.md` | Optional | Boot files — tool-specific |

If your team all uses the same tool, commit the generated files. If different team members use different tools, `.gitignore` them and let each person run the setup script.
