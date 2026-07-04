# Feature Brief - Pipeline Governance and Loop Engineering

**Feature ID:** 0000016-pipeline-governance-and-loop-engineering

> Drafted by the orchestrator from a multi-source discussion: a portable-fix review of `martinjmayer/bug-bounty-hunter` PR #4, a pre-existing human-authored brief for agentic loop engineering (see `plan/current/_refs/agentic-loops/`), and a new backlog mechanism designed in dialogue. Supersedes the reference brief at `plan/current/_refs/agentic-loops/agentic-loop-engineering/feature-brief.md`, which is retained as background only.

---

## Business Goal

Three related gaps in the framework's own governance, addressed together because they touch the same skill files (ship-agent, orchestrator) and the same underlying theme — giving the pipeline a governed way to act on things it discovers about itself, at every seam, without disturbing state that has already shipped.

1. **No durable place for deferred work.** When a phase discovers something worth doing but out of scope for the active feature, there is currently no formal home for it — it gets scope-crept in, silently dropped, or forces a same-run correction. A `plan/backlog/` mechanism gives it a durable, human-reviewed home that surfaces automatically at the next feature's P0.
2. **No product-level version model.** The framework versions single components (`component.yml`) but has no way to represent one release version aggregated across multiple components, so multi-component consumer projects have no defined tagging story.
3. **P0–P6 has no governed way to correct itself.** P4's validate-agent self-corrects mechanically (lint/test/build), but a P3/P4 agent that hits a wall because an *upstream* design decision (P1 spec, P2 ADR) was wrong has no path back except an ad hoc, human-noticed "Mid-Pipeline Requirement Change." Nothing before P7 has been archived or shipped, so — unlike the P7–P9 case — reopening an earlier phase here carries none of the "disturbing already-locked-in state" risk. It's a legitimate, boundable loop: a structured defect report, a skeptical (REJECT-default) reversal-assessor judging whether it's real, a budgeted/rev-logged reversal, and a ratchet hook stopping anyone from "passing" a loop by quietly weakening acceptance criteria instead of doing the work.
4. **The pipeline can't act on execution-time evidence.** Nothing verifies that shipped behaviour actually matches acceptance criteria by *running* the software, and nothing gives the pre-ship gate a second, differently-blind reviewer. Per the loop-engineering research reviewed in `plan/current/_refs/agentic-loops/deep-dive-adding-agentic-loops.md`, these are the highest-evidenced, lowest-effort additions of all — a checkable verifier already exists (the running software, or a second model's judgment).
5. **Commits are too coarse today.** Hard Limit 7 requires a commit at each phase gate, but for a phase with multiple internal steps (e.g. P3's per-requirement TDD cycles) that can still mean hours of work sitting uncommitted. Tightening commit granularity to "after every meaningful artifact write" and pushing the feature branch after every phase-gate commit (when authorized) makes progress recoverable and visible throughout, not just at existing checkpoints.

**What stays explicitly out of scope:** looping back into state that has already been archived/committed at P7 (the bug-bounty-hunter PR's editable-P7–P9-lifecycle redesign) — that's a different, higher-risk seam and was deliberately rejected in favour of the backlog mechanism above. Everything else in this brief operates strictly within P0–P6 (design/build correction) or as a gate immediately before P7 (review), never after.

---

## Features

| Feature | User Stories | Priority | Wave |
|---------|-------------|----------|------|
| Backlog folder | As any phase agent, I can file a discovered-but-out-of-scope item to `plan/backlog/{id}-{slug}/` instead of scope-creeping the active feature or looping back into shipped state, so that non-blocking findings aren't lost or forced into an immediate fix | must-have | 0 |
| Backlog pickup at P0 | As the orchestrator starting a new feature, I scan `plan/backlog/`, present each entry to the human one at a time, and ask whether to pull it into scope for this initiative, so that deferred work gets revisited instead of forgotten | must-have | 0 |
| Product version manifest | As a multi-component project, I have a `product.yml` at the project root with `id`, `name`, `version`, `versionPolicy` (`max-component-version` \| `explicit` \| `external`), `feature`, and a `components` list with per-component versions, so that a single release version can be derived and tagged across components | must-have | 0 |
| Ship-agent product-version tagging | As the ship-agent at P9, I read the release version from `product.yml` when it exists (falling back to the single `component.yml` in the self-hosted framework-only case), create it with the default `versionPolicy` if missing, and validate it before tagging, so that tagging works generically for both single- and multi-component projects | must-have | 0 |
| Orchestrator product-version detection | As the orchestrator at P0, I read `product.yml` (when present) alongside `docs/about.md` to suggest the next version, so that version suggestions are correct for multi-component projects | must-have | 0 |
| Fine-grained phase commits | As a human reviewing pipeline progress, I want the orchestrator and phase agents to commit locally after every meaningful artifact write within a phase (e.g., after each requirement's TDD cycle in P3, each ADR in P2, each requirement doc in P1) — not batched until the single existing phase-gate commit — so that in-progress work is never more than one artifact away from being recoverable | must-have | 0 |
| Feature-branch remote push cadence | As a human tracking pipeline progress remotely, I want the orchestrator to push the feature branch after every phase-gate commit when push is authorized for the session, so that progress is visible and backed up without waiting for P9 | must-have | 0 |
| Terminology fix: Phase → Wave | As a framework maintainer, I rename the feature-decomposition grouping concept from "Phase" to "Wave" in `feature-brief.template.md` and the orchestrator's Decomposition section, so that it no longer collides with the P0–P9 pipeline-phase terminology | should-have | 0 |
| Loop-runner skill | As a phase agent entering any loop, I load `planifest-loop-runner` for canonical loop mechanics (state file conventions, stop rules, escalation format), so that every loop in the pipeline behaves consistently and improvements propagate everywhere at once | must-have | 1 |
| Loop state + run log conventions | As a looping agent, I read/write a schema'd loop-state file and append to a run log (one structured record per iteration: action, observation, decision continue/done/escalate), so that loops survive context resets and runs can be audited and compared | must-have | 1 |
| Loop telemetry + per-loop toggles | As a pipeline operator, I can toggle each loop independently in project settings and see loop iteration events in the telemetry backend, so that I can judge a loop's cost against its quality gain before trusting it | must-have | 1 |
| P0 completeness loop | As the orchestrator in P0, I coach against an explicit structured gap checklist and exit P0 only when it passes, escalating `P0: Blocked` if the same gap survives 2 coaching rounds, so that completeness is checkable rather than conversational | must-have | 1 |
| Design-critic skill (report-only) | As the orchestrator at the end of P1/P2, I spawn a fresh-context `planifest-design-critic` subagent with a REJECT-default rubric that critiques the spec and ADR artifacts before the human sees them, so that the confirmed-design gate reviews hardened artifacts instead of first drafts | must-have | 1 |
| Mechanical consistency checks | As the design-critic, I run a deterministic script validating cross-artifact consistency (story↔requirement traceability, component paths declared, ≤3 acceptance criteria per story, risks have mitigations, no orphaned ADR references), so that the cheapest verifier layer is immune to model self-grading | must-have | 1 |
| Design-defect report | As a P3/P4 agent hitting a wall caused by an upstream artifact, I file a structured defect report (what is blocked, which criterion/ADR binds, what was attempted, evidence) into `plan/current/`, so that reversal requests are auditable artifacts, not conversational appeals | must-have | 1 |
| Phase-reversal assessor skill | As the orchestrator receiving a defect report, I spawn a fresh-context `planifest-reversal-assessor` with a REJECT-default rubric (real blocker? shallowest owning phase? blast radius? budget remaining? additive vs. altering?), so that the agent claiming "the design is broken" is not the one judging that claim | must-have | 1 |
| Governed reversal execution | As the orchestrator executing a granted reversal, I rev-bump the affected artifacts with a revision-log entry, run the target phase's agent scoped to the defect, compute the invalidation cascade from traceability, and resume forward re-doing only invalidated work — entirely within P0–P6, before anything is archived — so that a reversal is a scoped delta, not a pipeline restart | must-have | 1 |
| Ratchet hook | As a pipeline operator, I have a deterministic hook that diffs acceptance criteria and scope sections on artifact writes during loops/reversals and blocks silent weakening or descoping (strengthening passes; weakening requires human approval), so that loops cannot pass their verifiers by moving the goalposts | must-have | 1 |
| Reversal human gates | As a human operator, I re-confirm before the pipeline moves forward after a reversal unless I authorised a continuous run; reversals classified as *altering*, any re-exit from P0, budget exhaustion (2 reversals/feature), and large invalidation cascades always require my approval regardless of run mode; in continuous run I am notified of every reversal, so that autonomy never silently changes what I signed off | must-have | 1 |
| Verify-by-execution skill | As the P4 validate-agent, I load `planifest-verify-by-execution` to verify acceptance criteria by running the software (browser MCP click-through, real API calls, log/DB checks) rather than only reading code and test output, so that "done" reflects observed behaviour | must-have | 1 |
| Cross-model review gate (pre-archive) | As the orchestrator at the end of P6, before P7 archive begins, I obtain approval from a REJECT-default reviewer that is not the implementing model, iterating implement→review→fix until approval or cap — while implementation is still fully live and editable, never after archive — so that the final gate has genuinely different blind spots from the maker | must-have | 1 |

---

## Waves

| Wave | Features Included | Ships When |
|------|-------------------|------------|
| 0 | Backlog folder + pickup protocol; `product.yml` + `versionPolicy`; ship-agent and orchestrator version-detection updates; Phase→Wave terminology fix | All land, existing single-component tagging behaviour is unchanged (self-hosted framework case), and a seeded multi-component fixture tags correctly under each `versionPolicy` value |
| 1 | loop-runner skill; loop state/run-log conventions; telemetry events + per-loop toggles; P0 completeness loop; design-critic skill (report-only) + consistency-check script; defect report; reversal-assessor skill; governed reversal execution; ratchet hook; reversal human gates; verify-by-execution skill; cross-model review gate (pre-archive) | All loop toggles default off (zero-config = pipeline behaves exactly as today); design-critic runs report-only on ≥2 real features and its critique precision is judged worth keeping; a real reversal executes end-to-end (petition → grant → scoped re-run → ratchet-checked → human gate) on a live feature; verify-by-execution and the cross-model gate both run on a real feature and P8 build assessment reports their cost/catch-rate |

Deferred beyond this feature: `planifest-loop-designer` meta-skill; cross-vendor (different-model-family) critique automation for P1/P2 artifacts; standing patrol automations (scheduled triage/cleanup loops) — reconsider after Wave 1 evidence.

---

## Target Architecture

### Components

| Component | Type | New or Existing | Responsibility |
|-----------|------|-----------------|---------------|
| planifest-framework | component-pack | existing | Owns the new `plan/backlog/` convention and orchestrator pickup logic; the `product.template.yml` template; ship-agent and orchestrator version-detection changes; the Phase→Wave terminology fix; the new skills (`planifest-loop-runner`, `planifest-design-critic`, `planifest-reversal-assessor`, `planifest-verify-by-execution`), the consistency-check script, the new `ratchet-check` hook, templates (defect report, loop state, revision-log entry), and orchestrator SKILL.md changes (loop control flow, reversal protocol, human-gate logic) |
| structured-telemetry-mcp | microservice | existing | Gains loop event types (`loop_iteration`, `phase_reversal_petitioned/granted/denied`) following the feature-0000009 event-extension pattern; P8 build assessment consumes them |

### Data Ownership

| Data Store | Owner Component | Shared With |
|------------|----------------|-------------|
| `plan/backlog/` entries | planifest-framework (orchestrator) | all phase agents (write); human (read at P0 pickup) |
| `product.yml` | planifest-framework (ship-agent writes/updates) | orchestrator (reads for version detection) |
| `plan/current/` loop-state, run-log, defect reports, revision log | planifest-framework (orchestrator) | phase agents (read), human (read) |
| Telemetry DB | structured-telemetry-mcp | P8 build-assessment agent (query, read-only) |

### Integration Points

| From | To | Method | Contract |
|------|-----|--------|----------|
| Any phase agent | `plan/backlog/` | direct file write | One folder per entry: problem, source feature/phase, date filed |
| Orchestrator P0 | `plan/backlog/` | scan + present + confirm | Selected entries folded into the new feature's brief/requirements and removed from backlog |
| Ship-agent P9 | `product.yml` | read/create/validate | Falls back to single `component.yml` when the project has exactly one component |
| Orchestrator / phase agents | critic & assessor skills | fresh-context subagent spawn (Agent tool) | Structured verdict artifact written to `plan/current/`; REJECT default |
| Looping agents | telemetry backend | existing emit hooks | New event types; async, non-blocking, no-op if unset |
| Artifact writes during loops | ratchet hook | PreToolUse hook (Write\|Edit), same family as `gate-write.mjs` | Exit 2 with human-readable reason on weakening; exit 0 otherwise |

---

## Stack

| Concern | Decision |
|---------|----------|
| Language | Markdown (skills, templates), Node.js `.mjs` (hooks, consistency-check script — matching existing hook stack) |
| Runtime | Node ≥20 (existing framework requirement) |
| Testing | Shell-based framework tests per existing conventions (`planifest-framework/tests/`); report-only trial on ≥2 real features as the design-critic acceptance eval |
| Build target | local (framework repo; distributed via existing `setup.sh` bundling) |

---

## Scope Boundaries

### In Scope
- `plan/backlog/` folder convention + orchestrator P0 pickup protocol
- `product.template.yml`, `versionPolicy` values (`max-component-version`, `explicit`, `external`), ship-agent and orchestrator updates to read/create/respect it
- Phase → Wave terminology correction in `feature-brief.template.md` and the orchestrator's Decomposition section
- The five loop skills (`planifest-loop-runner`, `planifest-design-critic`, `planifest-reversal-assessor`, `planifest-verify-by-execution`, plus the consistency-check script) — `planifest-loop-designer` deferred
- P0 completeness loop; governed phase-reversal protocol (defect report → assessor → scoped re-run) operating within P0–P6
- Ratchet hook; iteration caps and reversal budget enforced by orchestrator control flow + hook, never by skill text alone
- Cross-model review gate positioned at the end of P6, before P7 archive begins
- Loop state/run-log templates; telemetry event types + per-loop toggles in project settings; P8 reporting of loop/reversal stats

### Out of Scope
- Any mechanism that keeps `plan/current/` or its sentinels editable *after* P7 archive (the bug-bounty-hunter PR's editable-P7–P9-lifecycle redesign) — explicitly rejected; archived/committed state stays locked
- Changes to the confirmed-design gate itself — the human gate's position and authority are unchanged; loops only change what arrives at it
- The 7 bug-bounty-hunter-specific E2E regression tests from PR #4 (project-specific, no equivalent harness in this repo)
- Standing patrol automations (scheduled triage/cleanup loops)
- Harness-level `/goal`-`/loop` integration — these loops are orchestrator-governed and tool-agnostic

### Deferred
- `planifest-loop-designer` meta-skill (advises whether a proposed automation deserves a loop) — after Wave 1 evidence
- Cross-vendor (different model family) critique automation for P1/P2 artifacts — after Wave 1 proves same-vendor critique value; blocked on per-project model-access configuration

---

## Non-Functional Requirements

| NFR | Target | Measurement |
|-----|--------|-------------|
| Trust | No loop can weaken criteria/scope without explicit human approval | Ratchet hook unit tests + attempted-weakening events in telemetry |
| Zero-regression default | With all toggles off, pipeline behaviour is byte-identical to pre-feature | Toggles-off run on a reference feature produces identical artifacts |
| Single-component compatibility | Ship-agent tagging behaviour for this repo (single-component, self-hosted) is unchanged | Existing framework tests for Step 8 tagging still pass unmodified |
| Cost visibility | Every loop iteration and reversal is attributable in telemetry | P8 build assessment reports per-loop iteration counts and token cost |
| Auditability | Every reversal reconstructable from artifacts alone (report → verdict → revisions → cascade → gate) | Manual audit of the first live reversal |

---

## Constraints and Assumptions

### Constraints
- **Skills advise; hooks enforce.** Any limit that must hold when the model rationalizes under pressure (iteration caps, reversal budget, ratchet) is deterministic. Test: *if the model ignored this text, would anything stop it?* If yes is required, it is a hook.
- **Maker–checker separation.** Critic, assessor, and the cross-model reviewer always run as fresh-context subagents loaded with only their own skill; never the authoring context re-reading its own output. Verifier default stance is REJECT.
- **Ratchet rule.** Loops may strengthen acceptance criteria or add scope explicitness; any weakening or descoping is blocked pending human approval — enforced by hook diff, not by classification alone.
- **Stop rules armed on every loop:** iteration cap (default 3; P4 keeps its existing 5), no-progress detection (identical gap/finding across 2 consecutive iterations = halt), escalation carries full context into the state file.
- **Human gates:** re-exit from P0 always requires human approval regardless of run mode; reversal budget is 2 per feature and exhaustion always goes to the human; continuous-run authorization was granted against a specific confirmed design — *altering* changes void it.
- **Rollout discipline:** every new loop ships report-only first; write/act scope is granted only after measured precision on real features.
- **P7 remains the lock line.** All loop/reversal machinery in this feature operates strictly within P0–P6, or as a gate immediately before P7. None of it touches archived/committed state.
- Loop state and artifacts remain plain markdown/YAML in `plan/` (human-readable, git-diffable) — no databases.

### Assumptions
- Existing req↔component↔test traceability is sufficient to compute invalidation cascades without new metadata.
- The telemetry backend's existing event-envelope pattern (feature 0000009) extends to loop events without schema redesign.
- Report-only critique on 2 features is enough signal to judge Wave 1 promotion; if not, extend the trial rather than promoting on faith.
- This framework repo's own `component.yml`-only tagging path remains valid (single-component fallback) since it has no `src/` and is not itself a multi-component consumer project.

---

## Scenario Paths

**Happy path:** A phase agent discovers a non-blocking improvement, files it to `plan/backlog/`, and the current feature ships unaffected; at the next feature's P0 the human decides whether to pull it in. Separately: P0 coaches against the gap checklist and exits clean; P1/P2 artifacts are drafted, pass mechanical checks, survive the critic (or are revised ≤3 iterations until they do); P3/P4 hits no design defect requiring reversal (or, if one occurs, petition → assessor grant → scoped re-run → ratchet-checked → human gate all complete cleanly); verify-by-execution and the cross-model gate pass before P7 archive; a multi-component project's ship-agent reads `product.yml` and tags correctly per `versionPolicy`.

**First-run path:** A project has no `plan/backlog/` and no `product.yml` yet — the P0 scan finds nothing to present (not an error) and the ship-agent creates `product.yml` on first use with the default `versionPolicy: max-component-version`. All loop toggles default off; enabling `design_critic: report-only` requires no other change.

**Error / sad path (four distinct modes):**
1. *Loop thrash:* the critic keeps finding new issues or the same issues re-worded. No-progress detection halts after 2 iterations without measurable convergence; escalation summarizes the disagreement for the human.
2. *Reward hacking:* an agent "passes" a loop by weakening an acceptance criterion or deleting a failing check. The ratchet hook blocks the write deterministically with a human-readable reason; the attempt is logged and surfaced in P8.
3. *Petition ping-pong:* a denied reversal is re-petitioned for the same defect. Dedup auto-escalates the second petition to the human.
4. *Malformed backlog entry:* a phase agent files a `plan/backlog/` entry with no clear source feature/phase attribution — flagged for human cleanup at the next pickup rather than silently ignored. A `product.yml` with an invalid version string is rejected the same way `component.yml` already is, prompting the human for a manual value.

**Cross-session continuity:** All loop state (loop-state file, run log, defect reports, revision log, budget counters) lives in `plan/current/` and is git-tracked — an interrupted session resumes mid-loop by reading state, per the existing `Px: Resuming…` convention. Budget counters must survive resume so an interrupt cannot reset the reversal budget. `plan/backlog/` entries and `product.yml` are git-tracked and persist across sessions and features independently of any single pipeline run's in-flight state.

---

## Acceptance Criteria

- [ ] `plan/backlog/{id}-{slug}/` convention exists with a lightweight entry template; any phase can file one
- [ ] Orchestrator P0 scans `plan/backlog/`, presents entries one at a time, and folds confirmed selections into the new feature's brief/requirements
- [ ] `product.template.yml` exists; ship-agent reads/creates/validates `product.yml` per `versionPolicy`, falling back to single-`component.yml` behaviour when only one component exists
- [ ] Orchestrator P0 version-detection reads `product.yml` when present
- [ ] "Phase" renamed to "Wave" for feature-decomposition grouping in `feature-brief.template.md` and the orchestrator's Decomposition section, without touching P0–P9 phase-prefix conventions
- [ ] `planifest-loop-runner` exists, conforms to the skills spec grammar, and P4's validate-agent uses it without behaviour change (caps preserved)
- [ ] `planifest-design-critic` runs as a fresh-context subagent at end of P2 in report-only mode; consistency script catches seeded traceability defects in a test fixture
- [ ] Per-loop toggles default off; toggles-off run is behaviourally identical to pre-feature pipeline
- [ ] Loop iteration and reversal events appear in the telemetry backend and in P8's build assessment output
- [ ] Defect report + reversal flow works end-to-end on a seeded defect: petition → assessor verdict (REJECT default verified with an unfounded petition) → scoped re-run → cascade list → human gate
- [ ] Ratchet hook blocks a seeded criteria-weakening write with a clear message, and passes a strengthening write
- [ ] Re-exit from P0 after reversal demands human approval even under continuous-run authorization; reversal budget survives session interrupt/resume
- [ ] Cross-model review gate runs before P7 archive (never after) with a REJECT-default reviewer distinct from the implementing model
- [ ] `planifest-verify-by-execution` verifies at least one acceptance criterion by running the software, not just reading test output

---

*This brief will be read by the orchestrator skill. Background research: `plan/current/_refs/agentic-loops/`. See [planifest-framework/skills/planifest-orchestrator/SKILL.md](../../planifest-framework/skills/planifest-orchestrator/SKILL.md)*
