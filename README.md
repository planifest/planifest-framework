# Planifest

**Because AI agents build from context, not guesses.**

Planifest is an Agile context framework for AI development. It uses Just-in-Time planning to ensure your agents build from a solid Execution Plan rather than hallucinating in the dark.

Code is ephemeral; architecture is permanent. Planifest's flawless paper trail gives you the ultimate choice: seamlessly refactor what you can, or confidently rewrite what you must.

Planifest gives AI agents the structure they need to build software that a senior engineer would approve. It treats the human as the Product Owner and Technical Architect. The agent is the Tech Lead: highly capable, but operating within constraints the human sets.

The framework is LLM-agnostic and tool-agnostic. It works with any model (Claude, GPT, Gemini, etc.) and any agentic coding tool (Claude Code, Cursor, Codex, Antigravity, GitHub Copilot, etc.).

Planifest fully supports the [Agent Skills specification](https://agentskills.io/specification) and is designed for use with any tool that implements it.

---

## The Post-Agile Philosophy: Why Planifest Demands a Plan

Agile methodologies were invented to solve a human bottleneck: typing is slow. Because execution took months, heavy upfront planning was dangerous. The market would change before the code was finished.

**In the AI era, execution takes minutes.** When an agent can generate a 10,000-line feature in the time it takes to get coffee, the cost of execution drops to zero. But the cost of *hallucination* skyrockets. If an agent builds the wrong architecture at lightspeed, you spend days untangling it.

Planifest is built on three core realities of agentic development:

1. **Transparency beats brevity.** When AI writes the code, the code is just the compiled output. The *actual* source code is your prompt and your plan. If your plan is vague, the AI will invent the missing pieces, leaving you with zero transparency into its architectural choices.
2. **Context makes refactoring safe (and rewriting trivial).** AI struggles to safely modify large, undocumented codebases. Planifest makes your code ephemeral and your architecture permanent. With a perfect architectural record, you get the best of both worlds: the precise historical context an agent needs to confidently refactor existing code, and the full specification required to burn a component down and build it better from scratch.
3. **Agents build from context, not guesses.** Before a single line of code is generated, the agent must document its Execution Plan. If there are gaps in the Story Context, the agent stops and asks the human. It does not guess.

---

## How It Works: The Agentic Iteration Loop

Planifest enforces a strict, fast-paced iteration loop to keep the AI aligned with human intent.

1. **Human writes a Feature Brief** — What to build, why, and within what constraints.
2. **Agent interrogates** — The Orchestrator Skill assesses the brief and asks focused questions until the context is complete.
3. **Agent plans** — The agent generates an **Execution Plan** and an **ADR** (Architectural Decision Record).
4. **Agent builds** — The agent executes the plan: code generation → validation → security checks → documentation updates.
5. **Human reviews** — The Pull Request is the universal backstop.

*(Note: Every artifact the agent produces follows a strict template, ensuring consistency across tools, models, and teams.)*

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
├── plan/             ← Feature briefs, execution plans, ADRs, risk registers, scope docs.
│                       Organized by initiative. Everything that describes WHAT to build and WHY.
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

## Key Principles

**Specification before code.** The agent does not write code until the spec is complete. If the spec has gaps, it stops and asks — it does not guess.

**Human decides, agent executes.** The human chooses the architecture, the stack, the data ownership, and the scope. The agent implements within those constraints.

**Decompose big initiatives.** Split into features (small enough for one agent session) and phases (sequential Agentic Iteration Loop runs). This is how Planifest manages context at scale.

**Everything is traced.** Every agent-produced artifact records the skill that produced it, the tool it ran in, and the model that generated it.

**The PR gate is the backstop.** Regardless of tool or model, a human reviews the output before it ships.

---

## The Framework

| Folder | Contents | Count |
|--------|----------|-------|
| [skills/](planifest-framework/skills/) | Orchestrator, spec-agent, adr-agent, codegen-agent, validate-agent, security-agent, change-agent, docs-agent | 8 |
| [templates/](planifest-framework/templates/) | Feature brief, execution plan, ADR, scope, risk register, domain glossary, data contract, component manifest (+guide), iteration log | 10 |
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

**Planifest Docs* contains human documentation — architecture notes, research, and the project roadmap. Agents don't need these; they work from the skills and templates in `planifest-framework/`. There is a [git repository](https://github.com/planifest/planifest-docs) and also a [GitHub Pages website](https://planifest.github.io/planifest-docs/) for these docs.

| Document | Purpose |
|----------|---------|
| [Master Plan](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p001-planifest-master-plan.md) | Architecture overview |
| [Product Concept](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p002-planifest-product-concept.md) | Vision and commercial model |
| [Functional Decisions](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p003-planifest-functional-decisions.md) | Decision log with rationale |
| [Pathway to Agentic Development](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p004-the-pathway-to-agentic-development.md) | Philosophical foundation |
| [Agentic Tool Runbook](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p010-planifest-agentic-tool-runbook.md) | Per-tool setup guides |
| [Pipeline](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p015-planifest-pipeline.md) | Pipeline phase descriptions |
| [Roadmap](https://github.com/planifest/planifest-docs/blob/main/planifest-docs/p014-planifest-roadmap.md) | Deferred items and future features |


[Read more on the website](https://planifest.github.io/planifest-docs/)


---

## License

[Apache License Version 2.0](LICENSE.txt)

### Why we chose the Apache 2.0 License

We want the Planifest community to build with total confidence. While we considered the MIT license for its simplicity, we chose Apache 2.0 because it offers superior long-term protection for our users and contributors:

- **Explicit Patent Rights:** Unlike other permissive licenses, Apache 2.0 grants you an explicit license to any patents covered by the software. This means you can use, modify, and distribute Planifest without worrying about "hidden" patent claims.

- **Contributor Protection:** It ensures that every contribution made to the framework comes with the same patent grants. This prevents "patent trolling" within the ecosystem and keeps the code free for everyone, forever.

- **Community Safety (The "Retaliation" Clause):** The license includes a defense mechanism: if anyone sues a Planifest user over patent infringement related to this software, they automatically lose their own license to use it. This keeps the community collaborative and legally "polite."

- **Commercial Friendly:** It remains a permissive, open-source license. You are free to use Planifest for commercial projects, ship it in proprietary products, and build your business on it with zero royalties.

**TL;DR:** We chose Apache 2.0 so you can focus on building great things, knowing the legal foundation of your framework is rock-solid and community-first.
