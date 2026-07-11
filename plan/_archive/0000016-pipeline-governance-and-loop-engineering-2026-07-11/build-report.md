# Build Report — 0000016-pipeline-governance-and-loop-engineering — 11 Jul 2026

## Model Usage

| Model tier | Concrete model | Phases used | Agent call count |
|------------|----------------|-------------|-----------------|
| Primary    | claude-fable-5 | P0, P1, P2, P3, P4, P5, P6, P7 | 7 (P1–P7 phase agents) |
| Cheaper    | claude-haiku-4-5 | P8 | 1 (build-assessment sub-agent) |

## Skills Invoked

| Phase | Skill | Load pattern |
|-------|-------|------------|
| P0    | planifest-orchestrator | Session start |
| P1    | planifest-spec-agent | JIT |
| P2    | planifest-adr-agent | JIT |
| P3    | planifest-codegen-agent | JIT |
| P4    | planifest-validate-agent | JIT |
| P4    | planifest-verify-by-execution | JIT (method demonstrated; toggle off per ADR-003) |
| P5    | planifest-security-agent | JIT |
| P6    | planifest-docs-agent | JIT |
| P7    | planifest-ship-agent | JIT |
| P8    | planifest-build-assessment-agent | JIT (sub-agent) |

## Subagent Dispatch

| Phase | Agent type | Count | Purpose |
|-------|-----------|-------|---------|
| P7    | build-assessment | 1 | Spawn cheaper-tier Phase 8 sub-agent to assess build log |

**Total agents spawned:** 2 (P7: ship-agent spawns P8 build-assessment; both accounted for in Phase Log)

## MCP Tool Usage

| Tool | Call count | Purpose |
|------|-----------|---------|
| ctx_batch_execute | ~7 | P0, P1, P3, P4, P6: parallel discovery and check batches |
| ctx_execute | ~2 | P4: check execution; verification report generation |
| emit_event | ~3 | Telemetry (failed per R-009 — backend envelope validation rejected) |

**Backend telemetry limitation:** `emit_event` failed on all 3 attempts (phase_start/phase_end/security_finding) with "(root): must be object" validation error. Phase-gate telemetry for this run is unavailable; all structural audit data captured in build-log.md instead.

## Parallel Task Bursts

| Phase | Batch count | Tasks parallelised |
|-------|------------|-------------------|
| P0    | 0          | (single orchestrator load phase — sequential by design) |
| P1    | 3          | Requirement file batches (REQ-001–008, REQ-009–021) + spec artifact batch |
| P2    | 1          | 8 independent ADRs in single batch |
| P3    | 4          | Templates batch → scripts/hooks/tests batch → new skills batch → SKILL.md edits batch |
| P4    | 1          | Syntax checks (node --check, bash -n, full harness) batched |
| P5    | 1          | STRIDE analysis + secrets/deps scans batched |
| P6    | 2          | Living-doc reads batch → recommendations+iteration-log writes batch |
| P7    | 1          | Template reads for archive preparation |
| P8    | 0          | (single sub-agent sub-phase — sequential by definition) |

**Phases with parallelism:** P1–P7 (all phases with >1 task)

**Phases with no parallelism:** None (all multi-task phases evidenced parallelism; P0 and P8 are single-task/design phases)

## Self-Corrections

| Phase | Count | Summary |
|-------|-------|---------|
| P1–P8 | 0 | Zero self-correction cycles across entire pipeline |

**Total self-corrections:** 0

**Quality signal:** No rework, no assumption escalations, no spec ambiguity loops. Indicates spec clarity and codegen fidelity.

## Artefact Counts

| Category | Count |
|----------|-------|
| Requirement files | 21 (REQ-001–021: Wave 0 + Wave 1) |
| ADRs | 8 (ADR-001–008, including Q-001–003 resolutions) |
| Spec artifacts | 7 (execution-plan, scope, risk register, domain glossary, backlogs, verification notes, P0 brief) |
| New skills | 4 (loop-runner, loop-toggles, ratchet-check, consistency-check) |
| Template updates | 6 |
| Executable artifacts | 3 (.mjs: ratchet-check, consistency-check, product-version) |
| Test suites | 1 (97/97 green, TDD RED→GREEN applied) |
| SKILL.md edits | 4 (orchestrator, ship, validate, spec) |
| Documentation updates | 3 living docs (component-registry, decisions-index, architecture-overview) |
| Recommendations | 6 (filed to recommendations.md) |

## Efficiency Observations

### Model Routing

**Finding: Primary tier (claude-fable-5) was used exclusively for P1–P7; cheaper tier deployed only at P8.**

- **Phases using primary tier:** P1 (spec), P2 (ADRs), P3 (codegen), P4 (validate), P5 (security), P6 (docs), P7 (archive) — 7 phase agents.
- **Phases using cheaper tier:** P8 (build-assessment) — 1 sub-agent.
- **Justification check:** P1 spec generation with 21 requirement files and complex Wave 0/Wave 1 stratification justifies primary. P3 codegen handling 16 shared-file edits across framework markdown + 3 executables with TDD applies justifies primary. However, P2 (8 independent ADRs), P5 (STRIDE + security scans on known-small diff), and P6 (living doc reads + recommendations generation) are documentation and analysis tasks that are cheaper-tier eligible. P6 in particular — reading component registries, writing recommendations against existing decision records — is a curation task, not a generative one.
- **Assessment:** Missed opportunity to route P2 and/or P6 to cheaper tier. P2 ADR generation from execution plan is structured and template-driven; P6 living doc curation is pattern-matching against existing artifacts. No evidence that primary-tier reasoning was required for either. P3 parallelism note justified prioritising primary, but P2 and P6 could have reduced spend by 2–3 cheaper-agent calls without impacting quality.
- **Severity:** Low (primary tier still the safe default for framework authoring; no critical failures resulted). But a future feature-pipeline pass should measure P2 and P6 quality-per-cost and establish cheaper-tier applicability for those phases.

### Parallelism

**Finding: Parallelism was well-executed across all phases. No parallelism gaps detected.**

- **P1:** 3 batches recorded (requirement file cohorts + spec artifact batch). Good.
- **P2:** 1 batch for 8 ADRs. Good (ADRs are independent; parallelism evidenced).
- **P3:** 4 batches planned (templates → hooks+tests → skills → SKILL.md edits). Good. Build log notes that subagent-per-requirement was rejected in favour of inline parallelism to avoid collision on shared framework files — a correct trade-off decision documented in the log.
- **P4:** 1 batch for syntax checks (node --check, bash -n, full harness). Good (checks are independent I/O tasks).
- **P5:** 1 batch for STRIDE + scans. Good (security checks are independent).
- **P6:** 2 batches (living-doc reads, then recommendations+iteration-log writes). Good (reads and writes are independent within each batch).
- **P7:** 1 batch for template reads. Good.
- **Assessment:** No sequential anti-patterns detected. All phases with multiple tasks show parallelism evidence. P3's decision to run inline parallel batches rather than spawn 21 subagents was explicitly justified (avoid shared-file collision); this is sound engineering, not a parallelism gap.
- **Verdict:** Parallelism enforcement working as designed. No findings.

### MCP Usage

**Finding: Context-mode used effectively; no context-flood risk detected.**

- **P0:** ctx_batch_execute + ctx_search for discovery (orchestrator scope assessment).
- **P1:** ctx_execute for requirement discovery; ~4 MCP calls recorded.
- **P3:** ctx_batch_execute for code generation discovery (inline parallel delivery).
- **P4:** ctx_execute for check batches; ~3 MCP calls recorded.
- **P6:** ctx_batch_execute for drift checks (living doc validation).
- **Assessment:** Context-mode used to prevent raw discovery output (git diffs, file inventories, spec reads) from entering conversation memory. Large codebases (templates, hooks, skills, tests) processed via sandboxed commands, not raw Read() calls. Telemetry (`emit_event`) failed at backend (R-009), but structural data (MCP call counts, phase transitions) manually logged to build-log.md by orchestrator, no accountability gap.
- **Verdict:** MCP usage sound. No wasteful context consumption detected.

### Self-Corrections

**Finding: Zero self-corrections across entire pipeline.**

- **P1–P8:** No mention of rework, assumption escalations, or spec ambiguity loops in any phase log.
- **P4 evidence:** Explicitly recorded "0 self-correction cycles" in validate phase.
- **Assessment:** This is a high-quality signal. Zero rework indicates that the execution plan (P1) was sufficiently precise, codegen (P3) did not make unsupported assumptions, and test coverage (P4) was sufficient to catch issues on first pass. No evidence that spec clarity could have been higher; the outcome suggests spec-and-codegen alignment was excellent.
- **Verdict:** No self-correction gaps. Efficiency excellent.

### Phase Gate Compliance

**Finding: All phase gates honored. Continuous run mode pre-authorized at P0.**

- **P0:** Design confirmed by human 2026-07-11 ("build this in continuous mode"); run mode = continuous approved.
- **P1–P7:** Each phase gate recorded as "Gate accepted: P{n} — continuous run".
- **P7:** Human confirmation recorded ("Ship it and store any gaps discovered as backlog changes").
- **P8:** Running now (this report).
- **Assessment:** No autonomous phase skips detected. Continuous-run mode was explicitly pre-authorized at P0, removing the need for interactive gates at P1–P7. All recorded gates show "continuous run" accepted, confirming mode respected throughout. No process violations.
- **Verdict:** Gate compliance sound.

### Build Log Integrity

**Finding: All phases P0–P8 represented with good data coverage. Telemetry envelopes failed (R-009), but structural audit data complete.**

- **Data present per phase:** Model tier, skills loaded, agents spawned, MCP calls, parallel batches, notes.
- **Sparse fields:** P0 MCP calls recorded as "several (context-mode search/batch-execute during discovery)" without granular counts. P1–P4 MCP calls recorded as "~4", "~3" (approximate). Not exact, but sufficient for audit.
- **Missing backend events:** `emit_event` failed (R-009) — no phase_start/phase_end/security_finding events in backend telemetry. However, orchestrator manually recorded all milestones in build-log.md, so no accountability gap.
- **Assessment:** Build log is the source of truth for this run (backend telemetry inaccessible). Orchestrator properly substituted manual logging. Sufficient for audit and future optimization analysis.
- **Verdict:** Integrity sound despite telemetry failure. No process violation.

### Backlog Mechanism (First Live Use)

**Finding: New `plan/backlog/` governance mechanism deployed and functional.**

- **First entry:** `0000001-flaky-test-suite-sigpipe` (latent SIGPIPE bug in test harnesses, discovered during P3, deferred to backlog per ADR).
- **Evidence:** Build log notes creation of backlog entry at P3 ("filed to plan/backlog/0000001-flaky-test-suite-sigpipe"). Entry picked up for human review at next P0.
- **Assessment:** Mechanism works as designed. Deferred issues can be captured and reviewed without loop-back (the old pattern that was rejected). Shows governance improvement.
- **Verdict:** Feature delivery includes working governance infrastructure. Positive signal.

### Risk Handling (R-009 Telemetry Failure)

**Finding: Telemetry failure (R-009) was pre-identified and mitigated.**

- **Failure mode:** `emit_event` rejected all 3 event payloads with "(root): must be object" validation error.
- **Impact:** No backend events recorded for this run (phase gates, security findings, etc.).
- **Mitigation:** Orchestrator manually logged all phase boundaries and key decisions to build-log.md (this file). Phase gates still recorded, audit trail preserved, no data loss.
- **Pre-identification:** Risk R-009 recorded in build log at P1 ("non-blocking per standards; logged as risk R-009 for investigation"). Acknowledged and handled per Planifest standards.
- **Assessment:** Risk was not escalated (correctly — backend telemetry is informational, not critical). Fallback logging ensures accountability. Investigation deferred to a future session (no blocker).
- **Verdict:** Risk management sound. No findings.

### Feature Scope and Completeness

**Finding: Feature delivered as specified. Scope refinements during P0 documented and confirmed.**

- **P0 scope refinements:** 
  - Backlog mechanism added (new Wave 0).
  - Design-critic hardening loop dropped as unproven.
  - Governed-reversal ratchet protocol restored after human correction.
  - Cross-model review gate repositioned to P6 end (before archive).
- **Confirmations:** All scope refinements confirmed by human at P0 gate.
- **Delivery:** 21 requirements (Wave 0+1) + 8 ADRs + 4 skills + 6 templates + all supporting artifacts.
- **Living docs:** Component registry updated (was missing entirely — drift found and fixed), decisions-index +8 ADRs, architecture-overview updated with ratchet enforcement diagram.
- **Assessment:** Scope tracked and confirmed. No gold-plating, no hidden requirements. Drift in living docs caught and corrected at P6.
- **Verdict:** Delivery complete and aligned with approved scope.

---

## Summary

This pipeline ran with high efficiency across all audit dimensions:

1. **Model routing:** Primary tier appropriate for phases P1–P3; cheaper tier could improve cost-per-quality for P2 and P6 in future runs (2–3 fewer primary-agent calls feasible). Opportunity identified for optimization, not a blocker.
2. **Parallelism:** Excellent across all phases. P3's decision to run inline batches rather than subagents was well-justified (avoid shared-file collision).
3. **MCP usage:** Context-mode prevented context flood. Large discovery tasks sandboxed, raw bytes kept out of conversation.
4. **Self-corrections:** Zero rework across all phases. Spec-to-codegen alignment excellent.
5. **Phase gates:** All honored. Continuous run mode pre-authorized and respected throughout.
6. **Governance:** Backlog mechanism deployed and functional (first live use). Risk R-009 (telemetry failure) pre-identified and mitigated with fallback logging.
7. **Completeness:** Feature delivered as specified. Living doc drift (missing component-registry entry) found and corrected at P6.

**Risk profile:** Low. No critical or high-severity findings. Two medium residual risks documented in component.yml (ratchet marker forgery audit-detected, not prevented; backlog prompt-injection defended at instruction level). Both have compensating controls.

**Recommendation for next feature:** Measure P2 (ADRs) and P6 (living docs) quality and cost under cheaper tier; establish baseline for routing future framework features more cost-effectively.
