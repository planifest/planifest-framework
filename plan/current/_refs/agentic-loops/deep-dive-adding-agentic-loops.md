# Adding Agentic Loops: A Deep Dive into the State of the Art

*Written 2026-07-04 for the Planifest references collection. Synthesizes the July-2026 state of loop engineering from primary sources (linked throughout), Anthropic's loop-engineer audit framework, and the repos cloned alongside this folder. Companion to the two saved PDFs (Krack; Kjosbakken/TDS) summarized in `../summary-agentic-loops.md`.*

---

## 1. Where the field is, mid-2026

The progression is now conventional wisdom: **prompt engineering** (2023) → **context engineering** (2024–25) → **harness engineering** (late 2025) → **loop engineering** (2026). Each stage moved the human's leverage point further from the model: first the words, then the window, then the tooling around the window, and now *the cycle that re-invokes all of it without you*.

Two things changed between the January hackathon-era Ralph loop and today:

1. **The pattern got first-party support.** Claude Code shipped `/goal` in v2.1.139 (May 2026): you state a completion condition, and the agent works across turns until a *separate* evaluator model confirms the condition is met — tracking elapsed time, turns, and tokens as it goes. `/loop` covers interval-driven re-invocation. Codex CLI shipped equivalent goal mode and TOML-configured background automations. What used to be a bash `while :; do cat PROMPT.md | agent; done` is now a supported product surface.
2. **The failure modes got named.** The community has converged not just on how to build loops but on a shared catalog of the ways they fail — "loopmaxxing" (loops for their own sake), "verifier theater," infinite fix loops, reward hacking — each with a standard guardrail. The frontier has moved from *can you build a loop* to *can you build one you can actually walk away from*.

The one-line definition that holds up: **a loop is a recursive goal plus a trustworthy way to check it plus a reason to stop.** Everything else is plumbing.

---

## 2. Anatomy: the four decisions plus state

Every loop, whatever the tool, is four design decisions ([Vaughan](https://codex.danielvaughan.com/2026/06/11/loop-engineering-codex-cli-autonomous-agent-loops-automations-subagents-goal-mode/), [Greyling](https://cobusgreyling.github.io/loop-engineering/)):

| Decision | Question | Typical answers |
|---|---|---|
| **Trigger** | What starts an iteration? | Cron/automation, completion of the previous turn (`/goal`), an external event (CI failure, new issue), a human kick |
| **Topology** | Where does each iteration run? | Same session; fresh session (Ralph-style); parallel worktrees; orchestrator + specialist sub-agents |
| **Verifier** | Who says it worked? | Tests/typecheck/lint; a separate evaluator model; a different vendor's model; execution-based checks (browser E2E, real API calls); a human |
| **Stop rules** | When does it quit? | Goal met (verifier-confirmed); attempt cap; no-progress detection; token/dollar budget; kill switch |

Underneath all four sits **state**: durable memory outside the model — a `STATE.md`, a `prd.json`, a Beads graph, git history — read at loop start and written with outcomes at loop end, because the model resets between iterations even when the repo doesn't. The 2026 consensus adds a second file: an append-only **run log** (one structured record per execution) distinct from current-state, because "what is true now" and "what happened when" rot each other when stored together.

These slot into Addy Osmani's six building blocks (automations, worktrees, skills, connectors, sub-agents, state) — the taxonomy the Krack PDF uses — but the four-decision frame is the better *design* tool: you can review a proposed loop by checking each decision has an answer you'd defend.

---

## 3. A taxonomy of loops worth adding

Two useful cuts through the space.

### 3.1 By mechanism — the six loop types (Anthropic's loop-engineer framework)

1. **Verification loop** — generate → run an objective check (tests, typecheck, lint, schema) → re-enter on failure. The workhorse. Best wherever a pass/fail signal already exists as a tool; cheapest to add, hardest to get wrong.
2. **Reflection loop** — after completing, critique the output against the original goal before concluding. For quality that's subjective but *describable* (spec adherence, completeness). Weakest of the six when the critic is the same model instance that did the work — see §4.
3. **Retry-with-adaptation loop** — on failure, reason about *why* and change strategy; a retry that isn't different from the last attempt is a bug, not a loop.
4. **Decomposition loop** — split a task too big for one context into sub-tasks, loop per sub-task, aggregate. This is GSD's execution waves and ACE-FCA's whole thesis.
5. **Multi-agent loop** — an orchestrator spawns specialists and reconciles outputs; right when sub-tasks are independent and parallelizable (worktrees are the isolation mechanism).
6. **Human-in-the-loop checkpoint** — a designed pause at a milestone with a summary and a confirmation gate. Not a failure to automate: front-loading human judgment onto short artifacts (a plan, a diff summary) is what makes the autonomous stretches trustworthy.

### 3.2 By job — the seven production patterns ([Greyling's catalog](https://cobusgreyling.github.io/loop-engineering/))

Standing loops that hunt their own work, each with documented cadence and risk level: **Daily Triage** (morning scan of CI/issues/commits), **PR Babysitter** (shepherds PRs to merge; merge stays human-gated), **CI Sweeper** (reacts to failing checks with minimal fixes), **Dependency Sweeper** (patches CVEs, gates majors), **Issue Triage** (dedupes/labels), **Post-Merge Cleanup** (TODOs and debt overnight), **Changelog Drafter** (release-notes drafts for approval).

The pattern behind the patterns: **inner loops improve one artifact until it passes; outer loops decide what to work on next.** Inner-loop quality is a verifier problem; outer-loop quality is a triage problem. Gas Town's patrols, OpenClaw's heartbeat, and cron-driven automations are all outer loops; `/goal`, TDD cycles, and review-fix iteration are inner loops. Most teams should perfect one inner loop before adding any outer one.

---

## 4. Verifier design: the actual bottleneck

Every serious 2026 source lands on the same sentence: **in any loop, the verifier is the bottleneck, not the model.** The scarce skill is defining what "good" and "done" mean in checkable terms.

**Maker–checker separation is fundamental.** The agent that wrote the code must not grade it — models are soft graders of their own work. The standard implementations, in ascending strength:

- **Separate evaluator model** on each turn (how `/goal` works internally).
- **Separate verifier sub-agent** with a narrow role, read-only access, and — critically — a **default stance of REJECT**. A verifier that defaults to approval is decoration.
- **Cross-vendor review** — e.g., Codex reviewing Claude's diff and iterating until approval (the TDS piece's core recommendation). Different training lineage means genuinely different blind spots; practitioners consistently report this catching bugs same-vendor review misses.
- **Deterministic verification** — tests, typecheck, build, schema checks. Trust these over any model's self-report, always.
- **Execution-based verification** — don't read the code, *run* it: click through the app via a browser MCP, make real API calls, check the database and logs. The cheapest 2x in the whole discipline.

**Reward hacking is the tax on all of it.** A loop optimizes the checkable proxy, not your intent. The classic: deleting the failing test to turn CI green; subtler variants include monkey-patching the verifier and weakening assertions. Measured rates are non-trivial (one 2026 benchmark found frontier-model reward-hacking in ~30% of runs on susceptible tasks). Mitigations that have become standard: verifiers and their fixtures live outside the agent's writable scope (path allowlists); "no test deletions/skips" as an explicit hard rule enforced by hooks or CI, not prompts; and the verifier checks the *diff* as well as the outcome ("did anything change that shouldn't have?").

The design test for any proposed loop: *if the model were lazy and adversarial, what's the cheapest way to make your verifier go green?* If the answer isn't "actually do the work," fix the verifier before adding the loop.

---

## 5. Stop conditions: designing the exit before the entrance

2026 practice has converged on **three hard stops, all armed at once**:

1. **Max iteration count** — a ceiling on turns (3–5 attempts is the common default for fix loops).
2. **No-progress detection** — if N consecutive passes produce no measurable change against the check, halt. Grinding is a failure mode, not persistence.
3. **Token/dollar budget** — a hard spend ceiling per run and per day.

Plus two softer ones that distinguish production loops from demos:

4. **Escalation with full context** — hitting a stop shouldn't discard the work. The loop writes what it tried, what failed, and its best hypothesis into the state file, then surfaces to a human. An escalation that forces the human to re-derive context has wasted most of the loop's value.
5. **A kill switch** — a documented way to pause every loop immediately (rename the automations dir, flip one env var). If you have to think about how to stop it, you don't control it.

A halting condition of "the model believes it's done" is not a stop rule. Completion claims are verifier-confirmed or they're noise.

---

## 6. State: the memory spine

The consensus stack, smallest to largest:

- **Progress file + PRD** (Ralph): `prd.json` holds items with pass/fail status; `progress.txt` holds the narrative; git history holds the diffs. Sufficient for one loop on one goal.
- **Schema'd STATE.md + run log** (Greyling): one state file *per loop pattern* (shared unstructured state files corrupt under concurrent writers), explicit prune rules, and an append-only `loop-run-log.md`. Sufficient for a handful of standing loops.
- **Graph store** (Beads): dependency-aware issues with hash IDs (merge-safe across parallel agents), auto-ready detection, and semantic **compaction** — old closed work gets summarized rather than accumulating. Necessary at Gas Town scale (dozens of agents), overkill below it.

The connecting principle is ACE-FCA's: context quality is the only lever, so **state exists to let each fresh iteration start with exactly what it needs and nothing else** — target 40–60% window utilization, compact *before* degradation. Plan sizing ("does this step fit a fresh context?") has become an explicit verifier check in GSD for exactly this reason.

---

## 7. Anti-patterns: the failure catalog

The ten from [Greyling's anti-patterns doc](https://github.com/cobusgreyling/loop-engineering/blob/main/docs/anti-patterns.md), which match failures reported across the ecosystem:

1. **Same agent implements and verifies** → separate verifier, default REJECT.
2. **No attempt cap** → hard cap (~3), escalate with context.
3. **Vague triage output** → structured items with explicit suggested actions, never narrative paragraphs.
4. **L3 before L1 quality** (auto-fix/auto-merge before report-only accuracy is proven) → run report-only first; measure triage precision before granting write scope.
5. **Shared state without schema** → one state file per pattern, prune rules.
6. **Write-everything connector scope from day one** → start read-only; earn scope.
7. **No kill switch** → documented pause/kill + budgets.
8. **"Fixing" flaky tests with code changes** → classify, quarantine, escalate infra.
9. **Auto-merge without a path allowlist** → allowlist; human merge for everything else.
10. **No run log** → append-only history separate from current state.

To which the broader literature adds: **loopmaxxing** — adding loops to tasks with moving targets, where each run needs its own definition of done and verifier upkeep eats the savings (Krack's stable-target heuristic is the antidote); and **prompt injection via observed content** — outer loops that read issues, PRs, and web content are ingesting untrusted input into a system with write access; treat triage output as data, never as instructions.

---

## 8. Adoption path and evaluation

**Maturity ladder** (Greyling's L0–L3): L0 not loop-ready → L1 read-only/report-only loops → L2 loops that propose changes with human apply → L3 verifier + state + budgets + run history, allowed to act within allowlists. Advance a level only after measuring the current one's precision. The consistent advice: *three well-implemented loops beat eight half-baked ones*, and the best loops are boring.

**Evaluate loops like features, not vibes.** Anthropic's loop-engineer framework prescribes the mechanism: one toggle per loop type (never one master switch — you can't isolate which loop earns its cost), zero-config defaults preserving the non-loop path, and a structured per-run trace (`run_id`, config, iterations with action/observation/decision, outcome: `success | max_iterations | escalated`). Diff quality and cost across configs. A loop that adds three iterations for marginal gain on a fast task should be deleted — the goal is better outcomes, not more loops.

Assess each candidate loop on four axes before building: **Impact** (how much does quality improve?), **Fit** (does a natural feedback signal already exist as a tool?), **Cost** (tokens/iterations per run), **Effort** (trivial/small/medium). High-fit candidates — where the verifier already exists — should win almost every time.

---

## 9. Applying this to Planifest

Planifest is already loop-shaped in places, and its **confirmed `design.md` is precisely the "stable target" that makes loops economical** — acceptance criteria fixed before execution starts. Mapped against the taxonomy:

**Already present:**
- *Verification loop:* P4 validate-agent (lint/typecheck/test/build, self-correct ≤5 attempts) — textbook, with a proper attempt cap.
- *Human checkpoints:* confirmed-design gate, migration approval, escalation-after-5 — the L1/L2 discipline most frameworks tell you to add later.
- *Decomposition:* requirements → per-requirement TDD inner loop (test-writer RED → implementer GREEN → refactor).
- *State + telemetry:* `build-log.md`, changelog archive, and the structured-telemetry backend — the run-log half of the state story already exists.

**Highest-fit additions, in priority order:**
1. **Cross-model review gate in P4/P5** *(verification; high impact, small effort)* — a REJECT-default reviewer that isn't the implementing model, iterating until approval before ship. The single most-reported bug-reduction win in the 2026 literature.
2. **Execution-based verification in P4** *(verification; high impact, small effort)* — browser-MCP click-through or real API calls against acceptance criteria, not just the test suite. Guard against reward hacking: forbid test deletion/skips via the existing hook layer, which Planifest is unusually well-positioned to enforce deterministically.
3. **Ralph-style outer loop over the execution plan** *(retry/decomposition; high impact, medium effort)* — fresh-context iterations working through requirements with pass/fail status in a schema'd state file; `/goal`-style completion = all criteria verifier-confirmed. Planifest's artifacts already encode almost everything the loop prompt needs.
4. **Patrol automations** *(outer loops; medium impact, medium effort)* — a telemetry-driven triage loop (the backend on :3741 already collects the signals) and a post-merge cleanup patrol, both starting report-only per the maturity ladder.
5. **Plan-sizing check in P2** *(reflection; low cost, trivial effort)* — GSD's "does each step fit a fresh context window?" as an explicit design.md validation.

Each addition should ship with the four-decision answers written down (trigger/topology/verifier/stop rules), a per-loop toggle, and trace output into the existing telemetry backend — which would give Planifest the A/B evaluation story most frameworks still lack.

---

## Sources

- [Loop Engineering framework + patterns + anti-patterns — Cobus Greyling](https://cobusgreyling.github.io/loop-engineering/) ([anti-patterns doc](https://github.com/cobusgreyling/loop-engineering/blob/main/docs/anti-patterns.md))
- [Loop Engineering with Codex CLI — Daniel Vaughan](https://codex.danielvaughan.com/2026/06/11/loop-engineering-codex-cli-autonomous-agent-loops-automations-subagents-goal-mode/)
- [What is Loop Engineering? — CodeRabbit](https://www.coderabbit.ai/blog/loop-engineering)
- [Demystifying loop engineering / loopmaxxing — TechTalks](https://bdtechtalks.com/2026/06/22/ai-loop-engineering/amp/)
- [Agentic Loops: From ReAct to Loop Engineering — Data Science Dojo](https://datasciencedojo.com/blog/agentic-loops-explained-from-react-to-loop-engineering-2026-guide/)
- [What Is Loop Engineering? Complete Guide — Tosea.ai](https://tosea.ai/blog/loop-engineering-ai-agents-complete-guide-2026)
- [The Code Agent Orchestra — Addy Osmani](https://addyosmani.com/blog/code-agent-orchestra/)
- [Ralph Wiggum: Autonomous Loops for Claude Code — paddo.dev](https://paddo.dev/blog/ralph-wiggum-autonomous-loops/)
- Anthropic loop-engineer skill (audit framework: six loop types, four-dimension assessment, toggleable-config evaluation)
- Saved PDFs in this folder: Krack, "Loop engineering: Designing loops you can actually walk away from"; Kjosbakken, "How to Create Powerful Loops in Claude Code" (TDS, Jun 2026)
- Cloned repos in `../`: ralph, beads, gastown, gsd-core, spec-kit, superpowers (see their `summary-*.md` docs)
