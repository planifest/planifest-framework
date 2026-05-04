# Pipeline Reference

> Deep reference for Planifest pipeline mechanics. For first-time setup, start with [getting-started.md](getting-started.md).

---

## Phase Indicators

Every agent response begins with a phase prefix. You always know where you are.

| Prefix | Phase | What the agent is doing |
|--------|-------|-------------------------|
| `P0:` | Assess & Coach | Reviewing the brief; asking gap questions; confirming continuous run or per-phase review |
| `P1:` | Spec | Writing requirements, scope, glossary, risk register |
| `P2:` | ADRs | Documenting architecture decisions |
| `P3:` | Codegen | Generating implementation |
| `P4:` | Validate | Running CI checks; self-correcting |
| `P5:` | Security | Security review; STRIDE threat model |
| `P6:` | Docs | Documentation artifacts; drift checks |
| `P7:` | Ship | PR, changelog, archive |
| `P8:` | Build Assessment | Efficiency audit: model routing, parallelism, self-corrections |
| `PC:` | Change Pipeline | Change to an existing feature |

Standard response formats:
- Entering a phase: `Px: Starting — {one-liner}`
- Resuming: `Px: Resuming — {what was in progress, what is next}`
- Completing: `Px: Complete — {one-liner summary}`
- Blocked: `P0: Blocked — {specific gap}`
- Skipped: `Px: Skipped — {reason}`

If you see `Px: Resuming…` at the start of a session, the orchestrator detected existing artifacts in `plan/current/` and is continuing where it left off.

---

## Phase Confirmation Gates

At the end of each phase, the orchestrator **stops and presents a summary** before proceeding. Before the pipeline begins (end of P0), you are asked:

```
Do you want to review and confirm after each phase completes, or authorise a
continuous run for this session?

  [1] Check after each phase
  [2] Continuous run — proceed without phase confirmations
```

Per-phase exceptions — the orchestrator may skip the stop if **both** conditions are true:
- You chose continuous run, AND
- There is genuinely nothing to check (e.g. P5 with zero security findings, P4 with all checks passing first attempt)

**P7 always stops.** Raising a PR is an external action — it is never auto-confirmed, even in continuous run mode.

---

## Phase 8 — Build Assessment

P8 runs automatically after P7 archives the plan. The `planifest-build-assessment-agent` reads `plan/current/build-log.md` (archived alongside the plan artifacts) and produces a structured efficiency report at `plan/archive/{feature-id}-{date}/build-report.md`.

### Build Log

From P0 onwards, the orchestrator maintains `plan/current/build-log.md` — a working file tracking per-phase telemetry. It is created from `planifest-framework/templates/build-log.template.md` at P0 and appended at each phase boundary. If a session is interrupted and resumed, the orchestrator appends rather than overwrites.

The build log records per phase: model tier used, skills loaded, agents spawned, MCP tool calls, parallel task batch count.

### What the P8 audit checks

P8 is adversarial, not a summary. It asks:

- **Model routing**: which phases used the primary tier when cheaper-tier tasks were eligible?
- **Parallelism**: which phases ran tasks sequentially that should have been parallel?
- **Phase gates**: were human confirmation gates honoured, or did the pipeline run autonomously without authorisation?
- **Self-corrections**: how many occurred, and were they avoidable?
- **Build log integrity**: are all phases represented with populated fields?

---

## Model Tier Routing

The orchestrator consults the **Model Tier Decision Table** before spawning every subagent, then passes the resolved model explicitly.

| Task type | Tier |
|-----------|------|
| Codebase discovery (grep, find, ls) | Cheaper |
| Single-file read with no synthesis | Cheaper |
| Formatting / spelling / lint checks | Cheaper |
| Validation (lint, typecheck, test runner) | Cheaper |
| Fetching a single known reference doc | Cheaper |
| Documentation writing (no novel decisions) | Cheaper |
| Web research with synthesis | Primary |
| Code generation | Primary |
| Security review | Primary |
| ADR writing | Primary |
| Spec / requirements writing | Primary |
| Phase 0 coaching | Primary |
| Build assessment (P8) | Cheaper |

**Tier-to-model mapping** (current as of May 2026):

| Tool | Primary | Cheaper |
|------|---------|---------|
| Claude Code | claude-sonnet-4-6 | claude-haiku-4-5 |
| Cursor | gpt-4o | gpt-4o-mini |
| Codex | o1 | o1-mini |
| GitHub Copilot | gpt-4o | gpt-4o-mini |
| Windsurf | claude-sonnet-4-6 | claude-haiku-4-5 |

---

## Trivial Fixes — Fast Path

For isolated, low-risk changes the orchestrator can bypass the full pipeline.

### Criteria (ALL must be met)

1. Does **not** introduce new external dependencies
2. Does **not** alter, add, or remove database schemas or data models
3. Does **not** change security parameters, authentication, or routing logic
4. Confined to: UI styling, copy changes, or isolated pure-function logic bugs

If **any** criterion fails, the orchestrator routes to the Change Pipeline instead.

### Execution

1. Implement the fix directly — no Feature Brief, Execution Plan, or ADR
2. Validate — lint, typecheck, test, build
3. Update `component.yml` — patch version bump, updated `metadata.updatedAt`
4. Log — append an entry to `plan/changelog/{feature-id}-{YYYY-MM-DD}.md`
5. Commit — `fix(fast-path): {description}`

The pre-push hook and CI workflow recognise the `fix(fast-path):` prefix and relax the documentation check: only `component.yml` or a changelog update required (not full `plan/` or `docs/` changes).

---

## Change Pipeline

For modifications to an existing feature — bug fixes, targeted changes to 1–2 components, or new user stories within existing scope:

```
Execute the confirmed design Change Pipeline.
Feature ID: my-feature
Component ID: auth-service
Change request: Add refresh token rotation
```

The `planifest-change-agent` handles it without re-running the full Feature Pipeline. It loads the domain context from the archived plan, implements the minimum necessary change, validates, checks for contract or schema changes, and updates documentation.

---

## Customising with planifest-overrides

`planifest-overrides/` is your team's customisation layer — committed to the repo, never overwritten by setup scripts.

### library-standards/

Override framework library preferences per language. Files here take precedence over `planifest-framework/standards/library-standards/`:

```
planifest-overrides/
└── library-standards/
    └── typescript/
        └── prefer-avoid.md    ← replaces the framework default for TypeScript
```

Agents check `planifest-overrides/library-standards/` first. Structure matches the framework default.

### instructions/

Project-specific instructions appended to the boot file (e.g. `CLAUDE.md`) on every setup run. Idempotent — re-running setup replaces the previous block.

```
planifest-overrides/
└── instructions/
    └── 01-project-context.md
    └── 02-naming-conventions.md
```

Files are sorted alphabetically and appended between HTML comment markers.

### capability-skills/

Permanent agent skills for this project. Each skill is a directory containing a `SKILL.md` with standard frontmatter. Setup copies them into the tool's skill directory alongside the built-in Planifest skills:

```
planifest-overrides/
└── capability-skills/
    └── my-project-skill/
        └── SKILL.md
```

---

*Source of truth: `planifest-framework/`. See [getting-started.md](getting-started.md) for setup steps.*
