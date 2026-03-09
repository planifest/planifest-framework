# Planifest

**A specification framework for agentic development.**

Planifest gives AI agents the structure they need to build software that a senior engineer would approve. It treats the human as the Product Owner and Technical Architect. The agent is the Tech Lead — highly capable, but operating within constraints the human sets.

The framework is LLM-agnostic and tool-agnostic. It works with any model (Claude, GPT, Gemini, etc.) and any agentic coding tool (Claude Code, Cursor, Codex, Antigravity, GitHub Copilot, etc.).

---

## How It Works

1. **Human writes an Initiative Brief** — what to build, why, and within what constraints
2. **Agent coaches** — the orchestrator skill assesses the brief and asks focused questions until the specification is complete
3. **Agent builds** — the pipeline skills execute in sequence: spec → ADR → codegen → validate → security → docs
4. **Human reviews** — the PR gate is the universal backstop

Every artifact the agent produces follows a template. Every file has a defined location. Every output records which skill, tool, and model produced it.

---

## Repository Structure

```
repo/
├── planifest-framework/        ← The framework (drop in, don't modify per-project)
│   ├── skills/       ← Agent instructions (orchestrator + 7 phase skills)
│   ├── templates/    ← File format templates for every artifact
│   ├── schemas/      ← JSON Schema validation definitions
│   ├── standards/    ← Code quality standards
│   └── initiative-structure.md  ← Canonical directory layout
│
├── plan/             ← Specifications (organized by initiative)
│                       Briefs, specs, ADRs, risk, scope, glossary.
│                       Everything that describes WHAT to build and WHY.
│
├── src/              ← Code (organized by component)
│                       Implementation, tests, config, manifests.
│                       Each component has a component.json at its root.
│
└── planifest-docs/        ← Project documentation (for humans, not agents)
                        Architecture notes, research, roadmap.
```

---

## Getting Started

### 1. Set up your agentic tool

Run the setup script for your tool — this copies skills into the directory your tool expects:

**macOS / Linux:**
```bash
./planifest-framework/setup.sh claude-code      # → .claude/skills/
./planifest-framework/setup.sh cursor           # → .cursor/skills/
./planifest-framework/setup.sh codex            # → .agents/skills/
./planifest-framework/setup.sh antigravity      # → .gemini/skills/
./planifest-framework/setup.sh copilot          # → .github/skills/
./planifest-framework/setup.sh all              # → all of the above
```

**Windows (PowerShell):**
```powershell
.\planifest-framework\setup.ps1 claude-code     # → .claude\skills\
.\planifest-framework\setup.ps1 cursor          # → .cursor\skills\
.\planifest-framework\setup.ps1 codex           # → .agents\skills\
.\planifest-framework\setup.ps1 antigravity     # → .gemini\skills\
.\planifest-framework\setup.ps1 copilot         # → .github\skills\
.\planifest-framework\setup.ps1 all             # → all of the above
```

The script adds YAML frontmatter, copies supporting files, and creates boot files. See [tool-setup-reference.md](planifest-framework/tool-setup-reference.md) for details on each tool.

**Re-run this script after updating any framework files.**

### 2. Start an initiative

1. Create `plan/` and `src/` directories (if they don't exist)
2. Write your first Initiative Brief using the [template](planifest-framework/templates/initiative-brief.template.md)
3. Open your agentic tool — the orchestrator skill will be auto-discovered
4. Tell it:

```
Execute the Planifest Initiative Pipeline.
Initiative brief: plan/{initiative-id}/initiative-brief.md
Initiative ID: {initiative-id}
```

The orchestrator will assess your brief, coach you through any gaps, and then build it.

### 3. Retrofit an existing project

1. Copy `planifest-framework/` into your repo
2. Run the setup script for your tool
3. Add a `component.json` to each existing component in `src/`
4. Tell the orchestrator to use **retrofit** adoption mode

### 4. Make changes

```
Execute the Planifest Change Pipeline.
Initiative ID: {initiative-id}
Component ID: {component-id}
Change request: {description}
```
```

---

## Key Principles

**Specification before code.** The agent does not write code until the spec is complete. If the spec has gaps, it stops and asks — it does not guess.

**Human decides, agent executes.** The human chooses the architecture, the stack, the data ownership, and the scope. The agent implements within those constraints.

**Decompose big initiatives.** Split into features (small enough for one agent session) and phases (sequential pipeline runs). This is how Planifest manages context at scale.

**Everything is traced.** Every agent-produced artifact records the skill that produced it, the tool it ran in, and the model that generated it.

**The PR gate is the backstop.** Regardless of tool or model, a human reviews the output before it ships.

---

## The Framework

| Folder | Contents | Count |
|--------|----------|-------|
| [skills/](planifest-framework/skills/) | Orchestrator, spec-agent, adr-agent, codegen-agent, validate-agent, security-agent, change-agent, docs-agent | 8 |
| [templates/](planifest-framework/templates/) | Initiative brief, design spec, ADR, scope, risk register, domain glossary, data contract, component manifest (+guide), pipeline run | 10 |
| [schemas/](planifest-framework/schemas/) | Shared type definitions, domain document envelope | 2 |
| [standards/](planifest-framework/standards/) | Code quality standards | 1 |

---

## Hard Limits

These are non-negotiable, regardless of tool, model, or configuration:

1. **Specification must be complete before codegen begins**
2. **No direct schema modification** — migration proposal required, human approves
3. **Destructive schema operations require human approval** — no exceptions
4. **Data is owned by one component** — never write to another component's data
5. **Code and documentation are written together** — never one without the other
6. **Credentials are never in the agent's context** — capabilities only

---

## Documentation

The `planifest-docs/` folder contains human documentation — architecture notes, research, and the project roadmap. Agents don't need these; they work from the skills and templates in `planifest-framework/`.

| Document | Purpose |
|----------|---------|
| [Master Plan](planifest-docs/p001-planifest-master-plan.md) | Architecture overview |
| [Product Concept](planifest-docs/p002-planifest-product-concept.md) | Vision and commercial model |
| [Functional Decisions](planifest-docs/p003-planifest-functional-decisions.md) | Decision log with rationale |
| [Pathway to Agentic Development](planifest-docs/p004-the-pathway-to-agentic-development.md) | Philosophical foundation |
| [Agentic Tool Runbook](planifest-docs/p010-planifest-agentic-tool-runbook.md) | Per-tool setup guides |
| [Pipeline](planifest-docs/p015-planifest-pipeline.md) | Pipeline phase descriptions |
| [Roadmap](planifest-docs/p014-planifest-roadmap.md) | Deferred items and future features |

---

## License

TBC
