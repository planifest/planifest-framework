# Planifest

Planifest is a specification-first framework for agentic coding tools. It requires an agent to produce a complete, reviewable execution plan — validated against templates and schemas — before it generates code.

It treats the human as product owner and architect, and the agent as the implementer working within constraints the human sets.

The framework is LLM-agnostic and tool-agnostic. It works with any model (Claude, GPT, Gemini, etc.) and any agentic coding tool (Claude Code, Cursor, Codex, Antigravity, GitHub Copilot, etc.), and supports the [Agent Skills specification](https://agentskills.io/specification).

---

## Rationale

Agile practice discourages heavy upfront planning because, when implementation takes weeks or months, detailed plans go stale before they're delivered. Agentic development changes that calculation: implementation is cheap and fast, so the dominant risk shifts from *stale plans* to *plausible-but-wrong output* built on unstated assumptions.

Planifest responds to that shift in three ways:

1. **The plan is the reviewable artifact.** When an agent writes the code, the prompt and plan largely determine the output. Planifest makes the plan explicit and reviewable, so architectural choices are visible before code exists.
2. **Context is recorded per component.** Each component keeps a manifest, and each feature keeps its execution plans and ADRs. This gives an agent (or a human) the historical context to modify a component — or the specification to rebuild it.
3. **Gaps trigger questions, not guesses.** If the feature brief has gaps, the agent is instructed to stop and ask rather than fill them with assumptions.

Whether this trade-off pays off depends on the work — see [Limitations](#limitations-and-non-goals).

---

## How it works: the iteration loop

1. **Human writes a feature brief** — what to build, why, and within what constraints.
2. **Agent interrogates** — the orchestrator skill assesses the brief and asks questions until the context is complete.
3. **Agent plans** — it generates an execution plan and an ADR (Architectural Decision Record).
4. **Agent builds** — code generation → validation → security checks → documentation updates.
5. **Human reviews** — the pull request is the backstop.

Every artifact the agent produces follows a template, so output is consistent across tools, models, and teams.

---

## Repository structure

```
repo/
├── planifest-framework/   ← The framework (drop in, don't modify per-project)
│   ├── skills/            ← Agent instructions (orchestrator + 7 phase skills)
│   ├── templates/         ← File format templates for every artifact
│   ├── schemas/           ← JSON Schema validation definitions
│   ├── standards/         ← Code quality standards
│   └── feature-structure.md  ← Canonical directory layout
│
├── plan/                  ← Feature briefs, execution plans, ADRs, risk registers,
│                            scope docs. Organised by feature. Everything that
│                            describes WHAT to build and WHY.
│
├── src/                   ← Code (organised by component). Implementation, tests,
│                            config, manifests. Each component has a component.yml.
│
└── planifest-docs/        ← Project documentation (for humans, not agents).
                             Architecture notes, research, roadmap.
```

---

## Getting started

See **[getting-started.md](planifest-framework/getting-started.md)** for step-by-step setup instructions.

**Quick start:**

```bash
# macOS/Linux
./planifest-framework/setup.sh <tool>

# Windows
.\planifest-framework\setup.ps1 <tool>
```

Where `<tool>` is `claude-code`, `cursor`, `codex`, `antigravity`, `copilot`, or `all`.

The setup script copies skills into the directory your tool auto-discovers, adds YAML frontmatter, and creates a boot file. See [tool-setup-reference.md](planifest-framework/tool-setup-reference.md) for details on each tool.

---

## Key principles

**Specification before code.** The agent does not write code until the spec is complete. If the spec has gaps, it stops and asks.

**Human decides, agent executes.** The human chooses the architecture, the stack, the data ownership, and the scope. The agent implements within those constraints.

**Decompose big initiatives.** Split into features (small enough for one agent session) and phases (sequential iteration loop runs). This is how Planifest manages context at scale.

**Everything is traced.** Every agent-produced artifact records the skill that produced it, the tool it ran in, and the model that generated it.

**The PR gate is the backstop.** Regardless of tool or model, a human reviews the output before it ships.

---

## The framework

| Folder | Contents | Count |
|--------|----------|-------|
| [skills/](planifest-framework/skills/) | Orchestrator, spec-agent, adr-agent, codegen-agent, validate-agent, security-agent, change-agent, docs-agent | 8 |
| [templates/](planifest-framework/templates/) | Feature brief, execution plan, ADR, scope, risk register, domain glossary, data contract, component manifest, iteration log, change summary, cost model, operational model, recommendations, security report, SLO definitions — each with a guide where applicable | 24 |
| [schemas/](planifest-framework/schemas/) | Shared type definitions, domain document envelope | 2 |
| [standards/](planifest-framework/standards/) | Code quality, API design, database, deployment, infrastructure, monorepo, observability, testing, backend & frontend stack evaluations | 10 |
| [setup/](planifest-framework/setup/) | Per-tool boot file templates (antigravity, claude-code, cline, codex, copilot, cursor, windsurf — `.sh` and `.ps1` for each) | 14 |
| [hooks/](planifest-framework/hooks/) | Git hooks (pre-commit, pre-push) and CI workflow | 3 |
| [workflows/](planifest-framework/workflows/) | Agent workflow definitions: fast-path, feature-pipeline, change-pipeline, retrofit | 4 |

---

## Hard limits

These apply regardless of tool, model, or configuration:

1. **Requirements must be complete before codegen begins**
2. **No direct schema modification** — migration proposal required, human approves
3. **Destructive schema operations require human approval**
4. **Data is owned by one component** — never write to another component's data
5. **Code and documentation are written together** — never one without the other
6. **Credentials are never in the agent's context** — capabilities only

---

## Limitations and non-goals

Planifest is a deliberate trade-off: it exchanges upfront ceremony for traceability and reviewability. That trade-off is not always worth making.

- **Overhead is real.** For small changes, prototypes, or exploratory work, the full pipeline is disproportionate. The fast-path workflow reduces this, but doesn't eliminate it.
- **It depends on review discipline.** The PR gate is only a backstop if humans actually read the plans and the diffs. Planifest structures the review; it can't perform it.
- **Plans don't prevent all bad output.** A complete specification reduces assumption-driven errors; it doesn't guarantee correct code. Validation and security skills catch classes of problems, not all of them.
- **No comparative benchmarks yet.** We have not published measurements comparing outcomes with and without the framework. Claims about quality improvement are, at this stage, based on design rationale and our own use.
- **It's not a project management method.** Planifest structures agent sessions, not teams. It sits alongside whatever delivery process you already use.

---

## Status

Planifest is under active development. Template and skill formats may change between versions; check the [roadmap](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p014-planifest-roadmap.md) for planned changes and deferred items.

## Contributing

Issues and pull requests are welcome. Agent skills, templates, and per-tool setup files are the areas most likely to benefit from outside contributions — particularly support for additional agentic tools.

---

## Documentation

`planifest-docs` contains human documentation — architecture notes, research, and the project roadmap. Agents don't need these; they work from the skills and templates in `planifest-framework/`. Available as a [git repository](https://github.com/planifest/planifest-docs) and a [GitHub Pages site](https://planifest.github.io/planifest-docs/).

| Document | Purpose |
|----------|---------|
| [Master Plan](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p001-planifest-master-plan.md) | Architecture overview |
| [Product Concept](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p002-planifest-product-concept.md) | Vision and commercial model |
| [Functional Decisions](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p003-planifest-functional-decisions.md) | Decision log with rationale |
| [Pathway to Agentic Development](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p004-the-pathway-to-agentic-development.md) | Background and rationale |
| [Agentic Tool Runbook](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p010-planifest-agentic-tool-runbook.md) | Per-tool setup guides |
| [Pipeline](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p015-planifest-pipeline.md) | Pipeline phase descriptions |
| [Roadmap](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p014-planifest-roadmap.md) | Deferred items and future features |

---

## Licence

[Apache License 2.0](LICENSE.txt) — chosen over MIT primarily for its explicit patent grant.
