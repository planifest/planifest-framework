# Feature Brief - Agentic Loop Engineering

**Feature ID:** 0000016-agentic-loop-engineering

> Written by a human (drafted with agent assistance from the research in `references/agentic-loops/deep-dive-adding-agentic-loops.md` and the design discussion of 2026-07-04). This is the input document that kicks off the confirmed design Agentic Iteration Loop.

---

## Business Goal

Planifest's pipeline is human-triggered and mostly single-pass per phase: P4 self-corrects, but P0–P2 artifacts reach the human as first drafts, defects discovered during implementation have no governed path back to the design, and loop mechanics (stop rules, state, escalation) are reimplemented ad hoc wherever they exist. Loop engineering is now the established discipline for making agent pipelines self-correcting without sacrificing trust (see `references/` research). This feature adds engineered loops so that: (1) the human confirmed-design gate reviews critic-hardened artifacts instead of first drafts, (2) implementation-time design defects flow back to the owning phase through an auditable, budgeted protocol instead of being hacked around or silently deviated from, and (3) loop discipline is written once as skills and enforced deterministically by hooks.

---

## Features

| Feature | User Stories | Priority | Phase |
|---------|-------------|----------|-------|
| Loop-runner skill | As a phase agent entering any loop, I load `planifest-loop-runner` for canonical loop mechanics (state file conventions, stop rules, escalation format), so that every loop in the pipeline behaves consistently and improvements propagate everywhere at once | must-have | 1 |
| Design-critic skill (Loop B, report-only) | As the orchestrator at the end of P1/P2, I spawn a fresh-context `planifest-design-critic` subagent with a REJECT-default rubric that critiques the spec and ADR artifacts before the human sees them, so that the confirmed-design gate reviews hardened artifacts instead of first drafts | must-have | 1 |
| Mechanical consistency checks | As the design-critic, I run a deterministic script validating cross-artifact consistency (story↔requirement traceability, component paths declared, ≤3 acceptance criteria per story, risks have mitigations, no orphaned ADR references), so that the cheapest verifier layer is immune to model self-grading | must-have | 1 |
| Loop state + run log conventions | As a looping agent, I read/write a schema'd loop-state file and append to a run log (one structured record per iteration: action, observation, decision continue/done/escalate), so that loops survive context resets and runs can be audited and compared | must-have | 1 |
| Loop telemetry + per-loop toggles | As a pipeline operator, I can toggle each loop independently in project settings and see loop iteration events in the telemetry backend, so that I can A/B a loop's cost against its quality gain before trusting it | must-have | 1 |
| P0 completeness loop (Loop A) | As the orchestrator in P0, I coach against an explicit structured gap checklist and exit P0 only when it passes, escalating `P0: Blocked` if the same gap survives 2 coaching rounds, so that completeness is checkable rather than conversational | should-have | 2 |
| Design-defect report | As a P3/P4 agent hitting a wall caused by an upstream artifact, I file a structured defect report (what is blocked, which criterion/ADR binds, what was attempted, evidence) into `plan/current/`, so that reversal requests are auditable artifacts, not conversational appeals | must-have | 2 |
| Phase-reversal assessor skill | As the orchestrator receiving a defect report, I spawn a fresh-context `planifest-reversal-assessor` with a REJECT-default rubric (real blocker? shallowest owning phase? blast radius? budget remaining? additive vs. altering?), so that the agent claiming "the design is broken" is not the one judging that claim | must-have | 2 |
| Governed reversal execution | As the orchestrator executing a granted reversal, I rev-bump the affected artifacts with a revision-log entry, run the target phase's agent scoped to the defect, compute the invalidation cascade from traceability, and resume forward re-doing only invalidated work, so that a reversal is a scoped delta, not a pipeline restart | must-have | 2 |
| Ratchet hook | As a pipeline operator, I have a deterministic hook that diffs acceptance criteria and scope sections on artifact writes during loops/reversals and blocks silent weakening or descoping (strengthening passes; weakening requires human approval), so that loops cannot pass their verifiers by moving the goalposts | must-have | 2 |
| Reversal human gates | As a human operator, I re-confirm before the pipeline moves forward after a reversal unless I authorised a continuous run; reversals classified as *altering*, any re-exit from P0, budget exhaustion (2 reversals/feature), and large invalidation cascades always require my approval regardless of run mode; in continuous run I am notified of every reversal, so that autonomy never silently changes what I signed off | must-have | 2 |
| Verify-by-execution skill | As the P4 validate-agent (and the pre-ship gate), I load `planifest-verify-by-execution` to verify acceptance criteria by running the software (browser MCP click-through, real API calls, log/DB checks) rather than only reading code and test output, so that "done" reflects observed behaviour | should-have | 3 |
| Cross-model review gate (pre-PR) | As the ship-agent before P9, I obtain approval from a REJECT-default reviewer that is not the implementing model, iterating implement→review→fix until approval or cap, so that the final gate has genuinely different blind spots from the maker | should-have | 3 |

---

## Waves

| Wave | Features Included | Ships When |
|------|-------------------|------------|
| 1 | loop-runner skill; design-critic skill (report-only); consistency-check script; loop state/run-log conventions; telemetry events + per-loop toggles | Loop B runs report-only on ≥2 real features and critique precision is judged worth keeping by the human |
| 2 | P0 completeness loop; defect report template; reversal-assessor skill; governed reversal execution; ratchet hook; reversal human gates | A real reversal executes end-to-end (petition → grant → scoped re-run → ratchet-checked → human gate) on a live feature |
| 3 | verify-by-execution skill; cross-model review gate | Both gates run on a real feature and the P8 build assessment shows their cost and catch-rate |

Deferred beyond this feature: `planifest-loop-designer` meta-skill; standing patrol automations (triage/cleanup loops) — reconsider after Wave 3 evidence.

---

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| planifest-framework | component-pack | existing | Owns the new skills (`planifest-loop-runner`, `planifest-design-critic`, `planifest-reversal-assessor`, `planifest-verify-by-execution`), the consistency-check script, new hook (`ratchet-check`), templates (defect report, loop state, revision-log entry), and orchestrator SKILL.md changes (loop control flow, reversal protocol, human-gate logic) |
| structured-telemetry-mcp | microservice | existing | Gains loop event types (`loop_iteration`, `phase_reversal_petitioned/granted/denied`) following the feature-0000009 event-extension pattern; P8 build assessment consumes them |

### Data Ownership

| Data Store | Owner Component | Shared With |
|------------|----------------|-------------|
| `plan/current/` loop-state, run-log, defect reports, revision log | planifest-framework (orchestrator) | phase agents (read), human (read) |
| Telemetry DB (`~/.planifest/telemetry.db`) | structured-telemetry-mcp | P8 build-assessment agent (query, read-only) |

### Integration Points

| From | To | Method | Contract |
|------|-----|--------|----------|
| Orchestrator / phase agents | critic & assessor skills | fresh-context subagent spawn (Agent tool) | Structured verdict artifact written to `plan/current/`; REJECT default |
| Looping agents | telemetry backend | existing emit hooks (`http://localhost:3741`) | New event types; async, non-blocking, no-op if unset (existing envelope rules) |
| Artifact writes during loops | ratchet hook | PreToolUse hook (Write\|Edit), same family as `gate-write.mjs` | Exit 2 with human-readable reason on weakening; exit 0 otherwise |

---

## Stack

| Concern | Decision |
|---------|----------|
| Language | Markdown (skills, templates), Node.js `.mjs` (hooks, consistency-check script — matching existing hook stack) |
| Runtime | Node ≥20 (existing framework requirement) |
| Testing | Hook unit tests per existing framework test conventions; report-only trial on ≥2 real features as the Wave 1 acceptance eval |
| Build target | local (framework repo; distributed via existing `setup.sh` bundling — no new distribution mechanism) |

---

## Scope Boundaries

### In Scope
- The five loop skills listed above (loop-designer deferred), written to the `anthropics/skills` spec grammar with trigger-focused descriptions.
- Orchestrator control-flow changes: Loop A/B sequencing, reversal protocol, human-gate logic, petition dedup (same defect petitioned once per phase run; re-petition auto-escalates to human).
- Deterministic guardrails as hooks: ratchet check; iteration caps and reversal budget enforced by orchestrator control flow + hook, never by skill text alone.
- Loop state/run-log templates and the invalidation-cascade convention built on existing req↔component traceability.
- Telemetry event types + per-loop toggles in project settings; P8 reporting of loop/reversal stats.

### Out of Scope
- Standing patrol automations (scheduled triage/cleanup loops) — outer loops deferred until inner-loop evidence exists.
- Changes to the confirmed-design gate itself — the human gate's position and authority are unchanged; loops only change what arrives at it.
- Harness-level `/goal`-`/loop` integration — Planifest loops are orchestrator-governed and tool-agnostic (must work on Tier 1–3 tools per REQ-027 precedent).
- Beads/Gas Town-style external state stores — file-based state in `plan/current/` is sufficient at Planifest's current scale.

### Deferred
- `planifest-loop-designer` meta-skill (advises whether a proposed automation deserves a loop; writes its four-decision spec) — after Wave 3.
- Cross-model review automation for P1/P2 artifacts (critic on a different vendor's model) — after Wave 1 proves same-vendor critique value; blocked on per-project model-access configuration.

---

## Constraints and Assumptions

### Constraints
- **Skills advise; hooks enforce.** Any limit that must hold when the model rationalizes under pressure (iteration caps, reversal budget, ratchet) is deterministic. Test for placement: *if the model ignored this text, would anything stop it?* If yes is required, it is a hook.
- **Maker–checker separation.** Critic and assessor always run as fresh-context subagents loaded with only their own skill; never the authoring context re-reading its own output. Verifier default stance is REJECT.
- **Ratchet rule.** Loops may strengthen acceptance criteria or add scope explicitness; any weakening or descoping is blocked pending human approval — enforced by hook diff, not by classification alone.
- **Stop rules armed on every loop:** iteration cap (default 3; P4 keeps its existing 5), no-progress detection (identical gap/finding across 2 consecutive iterations = halt), and escalation must carry full context (what was tried, what failed, best hypothesis) into the state file.
- **Human gates:** re-exit from P0 always requires human approval regardless of run mode; reversal budget is 2 per feature and exhaustion always goes to the human; continuous-run authorization was granted against a specific confirmed design — *altering* changes void it.
- **Rollout discipline (L1→L3):** every new loop ships report-only first; write/act scope is granted only after measured precision on real features.
- Loop state and artifacts remain plain markdown in `plan/current/` (human-readable, git-diffable) — no databases.

### Assumptions
- Existing req↔component↔test traceability is sufficient to compute invalidation cascades without new metadata.
- The telemetry backend's event-envelope pattern (feature 0000009) extends to loop events without schema redesign.
- Report-only critique on 2 features is enough signal to judge Wave 1 promotion; if not, extend the trial rather than promoting on faith.

---

## Scenario Paths

**Happy path:** P0 coaches against the gap checklist and exits clean. P1/P2 artifacts are drafted, pass mechanical checks, survive the critic (or are revised ≤3 iterations until they do), and reach the human as hardened drafts with the critique trail attached. The human confirms; P3/P4 run; no reversal is needed; verify-by-execution and the cross-model gate pass; P9 ships. Loop events land in telemetry; P8 reports iteration counts and costs per loop.

**First-run path:** A project adopts the feature via `setup.sh` re-run. All loop toggles default off (zero-config = pipeline behaves exactly as today). Enabling `design_critic: report-only` requires no other change; the first critique report appears alongside P2 output for human review with no gating effect.

**Error / sad path (three distinct modes):**
1. *Loop thrash:* the critic keeps finding new issues or the same issues re-worded. No-progress detection halts after 2 iterations without measurable artifact convergence; escalation summarizes the disagreement for the human rather than burning tokens.
2. *Reward hacking:* an agent "passes" a loop by weakening an acceptance criterion or deleting a failing check. The ratchet hook blocks the write deterministically with a human-readable reason; the attempt is logged and surfaced in P8.
3. *Petition ping-pong:* a denied reversal is re-petitioned for the same defect. Dedup auto-escalates the second petition to the human — either the agent is stuck or the assessor is wrong, and both are human problems.

**Cross-session continuity:** all loop state (loop-state file, run log, defect reports, revision log, budget counters) lives in `plan/current/` and is git-tracked — an interrupted session resumes mid-loop by reading state, per the existing `Px: Resuming…` convention. Budget counters must survive resume so an interrupt cannot reset the reversal budget.

---

## Non-Functional Requirements

| NFR | Target | Measurement |
|-----|--------|-------------|
| Trust | No loop can weaken criteria/scope without explicit human approval | Ratchet hook unit tests + attempted-weakening events in telemetry |
| Cost visibility | Every loop iteration and reversal is attributable in telemetry | P8 build assessment reports per-loop iteration counts and token cost per feature |
| Zero-regression default | With all toggles off, pipeline behaviour is byte-identical to pre-feature | Toggles-off run on a reference feature produces identical artifacts |
| Auditability | Every reversal reconstructable from artifacts alone (report → verdict → revisions → cascade → gate) | Manual audit of the first live reversal |

---

## Acceptance Criteria

- [ ] `planifest-loop-runner` exists, conforms to the skills spec grammar, and P4's validate-agent uses it without behaviour change (caps preserved)
- [ ] `planifest-design-critic` runs as a fresh-context subagent at end of P2 in report-only mode; mechanical consistency script catches seeded traceability defects in a test fixture
- [ ] Per-loop toggles default off; toggles-off run is behaviourally identical to pre-feature pipeline
- [ ] Loop iteration and reversal events appear in the telemetry backend and in P8's build assessment output
- [ ] Defect report + reversal flow works end-to-end on a seeded defect: petition → assessor verdict (REJECT default verified with an unfounded petition) → scoped re-run → cascade list → human gate
- [ ] Ratchet hook blocks a seeded criteria-weakening write with a clear message, and passes a strengthening write
- [ ] Re-exit from P0 after reversal demands human approval even under continuous-run authorization; reversal budget survives session interrupt/resume
- [ ] All human-gate and notification behaviour documented in `pipeline-reference.md`, with phase-indicator conventions for loops (e.g. `P2: Looping — critic iteration 2/3`)

---

*This brief will be read by the orchestrator skill. Supporting research: `../../../references/agentic-loops/deep-dive-adding-agentic-loops.md` (loop anatomy, verifier design, anti-patterns, maturity ladder) and the repo summaries in `../../../references/`. See [planifest-framework/skills/planifest-orchestrator/SKILL.md](../../planifest-framework/skills/planifest-orchestrator/SKILL.md)*
