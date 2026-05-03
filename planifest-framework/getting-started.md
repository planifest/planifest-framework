# Getting Started with Planifest

> Step-by-step instructions for humans setting up a Planifest project.
> For deep pipeline mechanics, see [pipeline-reference.md](pipeline-reference.md).

---

## Prerequisites

- An agentic coding tool: Claude Code, Cursor, Codex, Antigravity, GitHub Copilot, Windsurf, Cline, or OpenCode
- A terminal with Bash (macOS/Linux) or PowerShell (Windows)

---

## New Project

### 1. Add the framework

Copy the `planifest-framework/` folder into your repository root. This is the only thing you need - it contains the skills, templates, standards, and setup scripts.

### 2. Create the project structure

```
mkdir plan plan/changelog src docs
```

These are the core working directories:
- `plan/` - The current change being planned.
  - `plan/current/design.md` - Confirmed design and build plan.
  - `plan/current/feature-brief.md` - The initiating human-authored brief.
  - `plan/current/build-log.md` - Working telemetry file maintained throughout the pipeline run (created at P0, read by P8 Build Assessment).
  - `plan/current/iteration-log.md` - Audit trail of the pipeline run.
  - `plan/archive/` - Historical plans filed here after merge.
  - `plan/changelog/` - A record of all changes ({feature-id}-{YYYY-MM-DD}.md).
- `src/` - Component source code, tests, and component manifests (`component.yml`).
- `docs/` - Living repository documentation (always current). Includes component registry and dependency graph.
- `planifest-overrides/` - Your team's customisations: override library standards, add permanent capability skills, or add project-specific instructions. Never overwritten by setup scripts. See [pipeline-reference.md](pipeline-reference.md#customising-with-planifest-overrides).

See [feature-structure.md](../plan/feature-structure.md) for the full layout.

### 3. Run the setup script

This copies skills into the directory your agentic tool expects.

#### Basic setup

```bash
# macOS / Linux
chmod +x planifest-framework/setup.sh
./planifest-framework/setup.sh claude-code      # or cursor, codex, antigravity, copilot, windsurf, cline, opencode, all
```

```powershell
# Windows (PowerShell)
.\planifest-framework\setup.ps1 claude-code     # or cursor, codex, antigravity, copilot, windsurf, cline, opencode, all
```

Installs:
- Skill folders with YAML frontmatter (auto-discovered by your tool)
- Supporting files (templates, standards, schemas)
- A boot file for your tool (e.g. `CLAUDE.md`, `AGENTS.md`)
- Git guardrails (see below)

The agent uses native tools (`Grep`, `Bash`, `WebFetch`) directly. No context window protection.

#### Option: Context-Mode (recommended)

[context-mode](https://github.com/mksglu/context-mode) routes large output — search results, file analysis, web fetches — into a sandboxed knowledge base. Only summaries enter the context window, so the agent stays fast and focused on large codebases.

Install context-mode first, then pass `--context-mode-mcp` during setup, after the tool selection argument:

```bash
# macOS / Linux
./planifest-framework/setup.sh claude-code --context-mode-mcp
```

```powershell
# Windows (PowerShell)
.\planifest-framework\setup.ps1 claude-code --context-mode-mcp
```

Installs everything above, plus routing rules (`AGENTS.md`) and (for Claude Code) enforcement hooks that physically block native tool use (`Grep`, `Bash` web/grep patterns, `WebFetch`) to prevent the agent from bypassing context-mode.

See [docs/context-mode.md](../docs/context-mode.md) for how it works and prerequisites.

#### Option: Structured Telemetry

Emit structured events from skills and hooks into a local telemetry backend for observability — pipeline phase timings, context-pressure alerts, and skill execution traces.

Requires the [structured-telemetry-mcp](https://github.com/anthropics/structured-telemetry-mcp) server to be running, then pass `--structured-telemetry-mcp` during setup:

```bash
./planifest-framework/setup.sh claude-code --structured-telemetry-mcp
```

```powershell
.\planifest-framework\setup.ps1 claude-code --structured-telemetry-mcp
```

See [tool-setup-reference.md](tool-setup-reference.md) for what each tool expects.

### 3a. Git Guardrails (activated automatically)

The setup script activates Planifest's **Progressive Guardrail System** - a three-tier enforcement model that protects `main` without blocking atomic commits:

| Tier | When | What happens |
|------|------|--------------|
| **1 - Advisory pre-commit** | Every local commit | Prints a warning if code was staged without docs. Commit **succeeds**. |
| **2 - Branch pre-push** | Every `git push` | Checks the *cumulative branch diff*. Push **fails** if `src/` was changed with no updates to `plan/`, `docs/`, or `component.yml` - **unless** all commits use the `fix(fast-path):` prefix, in which case only `component.yml` or `plan/changelog/` is required. |
| **3 - CI/CD pipeline** | Every Pull Request | Same check in GitHub Actions. Recognises the `fix(fast-path):` prefix and applies the same relaxed rule. Blocks the merge button if the rule is violated. |

The hooks live in `planifest-framework/hooks/` and are wired via `git config core.hooksPath` - no `.git/` modifications required.

The CI workflow is copied to `.github/workflows/planifest.yml` on first setup.

### 3b. Orchestrator Sentinel (activated automatically)

When the orchestrator starts Phase 0, it creates a **sentinel file** at `plan/.orchestrator-active`. This is a zero-byte marker — no content, just existence — that tells the enforcement hooks an active pipeline run is in progress.

Two hooks check for it on every turn:

| Hook | What it does |
|------|-------------|
| **gate-write** (PreToolUse) | Blocks any write outside always-permitted paths unless `plan/current/design.md` exists and the target path is a declared component |
| **check-design** (UserPromptSubmit) | If neither the sentinel nor a `feature-brief.md` is present, injects a hard STOP message before the agent can act |

The sentinel is deleted **last** at Phase 7, after the archive is confirmed complete.

You never need to create or delete it manually. If a pipeline run is interrupted and you want to start fresh, delete `plan/.orchestrator-active` and `plan/current/feature-brief.md`, then reload the orchestrator.

### 4. Write your first feature brief

Use the template:
```
cp planifest-framework/templates/feature-brief.template.md plan/current/feature-brief.md
```

Fill it in. The [feature brief guide](templates/feature-brief-guide.md) walks you through each section.

### 4a. Phase indicators

Every agent response begins with a phase prefix so you always know where you are. At the start of P0, the orchestrator asks whether you want to review after each phase or authorise a continuous run.

| Prefix | Phase |
|--------|-------|
| `P0:` | Assess & Coach |
| `P1:` | Spec |
| `P2:` | ADRs |
| `P3:` | Codegen |
| `P4:` | Validate |
| `P5:` | Security |
| `P6:` | Docs |
| `P7:` | Ship |
| `P8:` | Build Assessment |
| `PC:` | Change Pipeline |

See [pipeline-reference.md](pipeline-reference.md) for what each phase does, phase gate behaviour, the P8 build report, and model tier routing.

### 5. Start the orchestrator

Open your agentic tool. The orchestrator skill is now auto-discovered. Tell it:

```
Execute the confirmed design Agentic Iteration Loop.
Feature brief: plan/current/feature-brief.md
```

The orchestrator will assess your brief, coach you through any gaps, produce a confirmed design, then ask whether you want per-phase confirmation or a continuous run before executing the pipeline.

---

## Retrofit an Existing Project

1. Copy `planifest-framework/` into your repo root
2. Run the setup script for your tool
3. Add a `component.yml` manifest to each existing component in `src/` - use the [component manifest template](templates/component.template.yml) and [guide](templates/component-guide.md)
4. Tell the orchestrator to use **retrofit** adoption mode:

```
Execute the confirmed design Agentic Iteration Loop in retrofit mode.
Feature brief: plan/current/feature-brief.md
```

---

## Trivial Fixes and Changes

For small, isolated fixes use the **Fast Path**; for targeted changes to existing features use the **Change Pipeline**. See [pipeline-reference.md](pipeline-reference.md) for criteria and full execution details.

---

## Customising with planifest-overrides

`planifest-overrides/` lets your team override library standards, add project-specific agent instructions, and install permanent capability skills — all committed to the repo and never overwritten by setup scripts. See [pipeline-reference.md](pipeline-reference.md#customising-with-planifest-overrides).

---

## Updating the Framework

After updating any files in `planifest-framework/` (skills, templates, standards):

```bash
./planifest-framework/setup.sh claude-code                                                        # macOS / Linux
./planifest-framework/setup.sh claude-code --context-mode-mcp                                    # include if context-mode is installed
./planifest-framework/setup.sh claude-code --context-mode-mcp --structured-telemetry-mcp         # include if both MCPs are installed
```

```powershell
.\planifest-framework\setup.ps1 claude-code                                                       # Windows (PowerShell)
.\planifest-framework\setup.ps1 claude-code --context-mode-mcp                                    # include if context-mode is installed
.\planifest-framework\setup.ps1 claude-code --context-mode-mcp --structured-telemetry-mcp         # include if both MCPs are installed
```

---

## What to Commit

| Path | Commit? | Why |
|------|:-------:|-----|
| `planifest-framework/` | ✅ | Source of truth - shared with team |
| `planifest-framework/hooks/` | ✅ | Git hooks and CI workflow - applied by setup scripts |
| `.github/workflows/planifest.yml` | ✅ | CI/CD strict gate - must be committed to take effect |
| `plan/` | ✅ | Feature briefs, execution plans, ADRs, scope docs |
| `src/` | ✅ | Component code and manifests |
| `docs/` | ✅ | Repo-wide registry and dependency graph |
| `.claude/`, `.cursor/`, `.agents/`, `.gemini/`, `.github/skills/` | Optional | Generated copies - can be `.gitignore`d and regenerated |
| `CLAUDE.md`, `AGENTS.md` | Optional | Boot files - tool-specific |
| `.claude/telemetry-enabled` | Optional | Telemetry opt-in sentinel |
| `planifest-overrides/` | ✅ | Team customisations — commit to share with the team |
