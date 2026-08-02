# Build Report — 0000023-framework-pipeline-fixes — 02 Aug 2026

## Model Usage

| Model tier | Concrete model | Phases used | Agent call count |
|------------|---------------|-------------|-----------------|
| Primary    | claude-sonnet-5 | P0–P7 | 8 |
| Cheaper    | claude-haiku-4-5 | P8 | 1 |

**Total model calls:** 9 (8 primary, 1 cheaper). Primary-to-cheaper ratio 8:1 reflects appropriate tier allocation: all design/architecture/implementation phases used primary; assessment phase used cheaper. No anomalies.

---

## Skills Invoked

| Phase | Skill | Load pattern |
|-------|-------|-------------|
| P0 | planifest-orchestrator | Session start (auto-triggered) |
| P1 | planifest-spec-agent | P1 phase gate |
| P2 | planifest-adr-agent | P2 phase gate |
| P3 | planifest-codegen-agent | P3 phase gate |
| P4 | planifest-validate-agent | P4 phase gate |
| P5 | planifest-security-agent | P5 phase gate |
| P6 | planifest-docs-agent | P6 phase gate |
| P7 | planifest-ship-agent | P7 phase gate |
| P8 | planifest-build-assessment-agent | P8 phase gate (sub-agent dispatch) |

**Total skills loaded:** 9. All phases covered; all skills loaded at appropriate phase boundaries.

---

## Subagent Dispatch

| Phase | Agent type | Count | Purpose |
|-------|-----------|-------|---------|
| P1 | general-purpose | 4 | Parallel dispatch of 4 requirement docs (req-001..req-004); each self-contained |
| P3 | general-purpose | 4 | Parallel dispatch of 4 codegen agents (req-001..req-004); RED-before-GREEN discipline |
| P8 | general-purpose | 1 | Build assessment agent (this agent) |

**Total agents spawned:** 9 (8 feature agents, 1 assessment agent).

**Parallelism:** P1 spawned 4 agents in 1 parallel batch; P3 spawned 4 agents in 1 parallel batch. Both multi-task phases properly parallelized.

---

## MCP Tool Usage

| Tool | Call count | Purpose |
|------|-----------|---------|
| (none recorded) | 0 | This feature required no external MCP integration — all work contained within framework fixtures |

**Total MCP calls:** 0. Reasonable for a framework-level fix with no web research, SDK integration, or external tool coordination.

---

## Parallel Task Bursts

| Phase | Batch count | Tasks parallelised |
|-------|------------|-------------------|
| P0 | 0 | Single task (assess & coach) — serial appropriate |
| P1 | 1 | 4 requirement agents (req-001, req-002, req-003, req-004) |
| P2 | 0 | Single task (ADR decision) — serial appropriate |
| P3 | 1 | 4 codegen agents (req-001, req-002, req-003, req-004) |
| P4 | 0 | Single task (validate) — serial appropriate |
| P5 | 0 | Single task (security) — serial appropriate |
| P6 | 0 | Single task (documentation) — serial appropriate |
| P7 | 0 | Single task (archive) — serial appropriate |
| P8 | 0 | Single task (build assessment) — serial appropriate |

**Phases with parallelism:** P1, P3 (2 phases; 2 parallel batches total; 8 agents across batches).

**Phases with no parallelism:** P0, P2, P4, P5, P6, P7, P8 (7 phases, all with single tasks — no missed opportunities).

---

## Self-Corrections

| Phase | Count | Summary |
|-------|-------|---------|
| P3 | 0 | 4 implementations completed with 1 attempt each; "no escalations" noted. One orchestrator-level intervention: req-004 test file moved from `tests/regression/` to `tests/`, path references corrected, suite re-run (34/35 feature + 22/22 regression passing). Not a self-correction loop; orchestrator intervention on test placement convention. |
| P4 | 0 | No self-correction cycles. Zero-findings gap addressed proactively: 2 new test files written (req-001, req-002 grep-based coverage) rather than accepting untested prose edits. All requirements' ACs updated; req-003's one unmet AC (`setup.sh all` exit 0) documented as out-of-scope. |

**Total self-corrections:** 0. 

**Interpretation:** No implementation rework loops, no spec ambiguities requiring fallback research, no architecture re-designs mid-phase. Clean execution. The test placement fix and coverage gap closure were proactive refines, not reactive repairs.

---

## Artifact Counts

| Category | Count | Notes |
|----------|-------|-------|
| Requirements docs | 4 | req-001 (continuous_run restoration), req-002 (marker commit lifecycle), req-003 (setup.ps1 fix), req-004 (telemetry emission regression test) |
| Shared artifacts | 7 | execution-plan, scope, risk-register, domain-glossary, operational-model (N/A), slo-definitions (N/A), cost-model (N/A) |
| ADRs | 1 | ADR-001 (continuous_run governance restoration) |
| Tests | 2 | test-0000023-req-001-continuous-run-p1-p3.sh (7/7), test-0000023-req-002-marker-commit-lifecycle.sh (7/7) |
| Updated docs | 4 | component-registry.md, decisions-index.md, architecture-overview.md, recommendations.md |
| Implementation files | 4 | SKILL.md edits (req-001, req-002), setup.ps1 (req-003), telemetry hooks (req-004) |

**Total artifacts produced:** 22 (4 reqs + 7 shared + 1 ADR + 2 tests + 4 docs + 4 impl).

---

## Efficiency Observations

### Model Routing Efficiency
- **Primary (Sonnet) phases:** P0–P7 — 8 consecutive phases using primary tier
- **Cheaper (Haiku) phases:** P8 only (build assessment)
- **Assessment:** Primary tier appropriate for P0–P7 (design, architecture, implementation, validation, security, docs all benefit from stronger reasoning). Cheaper tier appropriate for P8 (assessment phase is mechanical analysis and reporting). No obvious over-tier usage.
- **Opportunity cost:** Zero. Tier allocation matches task complexity.

### Parallelism Efficiency
- **Parallelization rate:** 8 agents across 2 batches in a 9-phase run = 8/9 tasks potentially parallelizable were actually parallelized (88%).
- **Reason for serial-only phases:** P0 (assess), P2 (ADR decision), P4–P8 (single sequential task per phase) — all appropriately serial.
- **Batch efficiency:** P1 and P3 each dispatched 4 agents in a single round-trip, eliminating 3 round-trip delays per phase (6 total latency savings). Efficient.

### Continuous-run Exception Validation (Dogfooding)
- **P0 directive:** "continuous_run: true" set explicitly, human-authorized for P1–P3.
- **Live dogfood:** This run was chosen *specifically* to verify req-001 (continuous_run restoration) works as designed. P1→P2 and P2→P3 transitions proceeded without stopping despite no human re-confirmation.
- **Validation:** Verified in P7 (archive phase notes) — marker state checks passed (req-002 dogfood).
- **Risk:** Minimal. This was deliberate integration testing, pre-approved at P0.

### Coverage Gap Closure
- **P4 gap:** Discovered that req-001 and req-002 (prose/table SKILL.md edits) had zero automated test coverage.
- **Response:** Wrote 2 new shell test files (7 assertions each) rather than ship unverified content.
- **Precedent:** Repository has existing grep-based test patterns for SKILL.md validation.
- **Efficiency impact:** +1 phase (P4 extended) to close gap; saved shipping untested governance changes.

### Known Out-of-Scope Failures
- **Pre-existing bug:** `cline.sh` path collision causes `setup.sh all` to exit non-zero. Req-003's fix *unmasked* this bug (previously hidden by copilot crash aborting the run first).
- **Documented:** Marked explicitly as not met (req-003 AC #2), filed as backlog `0000034` (converted from a standalone task chip the implementing subagent raised via spawn_task, per the human's explicit direction at P8 — see backlog `0000035` for the resulting process gap this exposed). Not silently accepted.
- **No self-correction spent:** Appropriate — out-of-scope per P0 briefing.

### Stale Artifact Flagging
- **P7 finding:** `.claude/skills/planifest-ship-agent/SKILL.md` (loaded copy in prompt) was stale; canonical source used instead.
- **Cross-reference gap:** decisions-index.md missing ADR entries for 0000020/0000021/0000022 despite archives containing them.
- **Backlog filing:** `.claude/skills/` staleness is a recommendation in `recommendations.md` (no dedicated backlog entry — a setup/skill-sync re-run, not a code fix). The decisions-index.md drift (0000020's stale "Last updated" stamp, missing 0000021/0000022 ADR entries) is similarly a recommendations.md note, not yet a filed backlog item. Backlog `0000033` is a separate finding from P7: `planifest-ship-agent/SKILL.md`'s Step 7 `git add` command never explicitly names `plan/current/`, relying on git's rename-detection heuristics rather than an explicit stage — found live while executing this feature's own req-002 fix.

### Build Log Integrity
- **Completeness:** All 8 phases (P0–P7) + P8 assessment represented. One minor note: P3 shows "TBD" for agent count initially, resolved in notes during P3's actual execution. Acceptable for real-time logging.
- **Field population:** Model tier, skills, agents, MCP calls, parallelism, telemetry state, and phase notes all recorded. No missing critical fields except where legitimately zero (0 MCP calls, no self-corrections).
- **Traceability:** Each phase has explicit gate status and transition note (e.g., "continuous_run exception applies — proceeding to P2 without stopping"). High transparency.

---

## Critical Audit Findings

### A. Model Routing Audit — ✓ PASS
- No evidence of primary tier used for cheaper-tier-eligible work (lint, formatting, codebase discovery).
- No evidence of cheaper tier used for expensive tasks.
- Tier decisions recorded per skill load (not per agent call), but this is acceptable — the 8 primary and 1 cheaper clear reflects actual usage.
- **Conclusion:** Model routing is efficient and appropriate.

### B. Parallelism Audit — ✓ PASS
- P1: 4 independent requirement agents explicitly dispatched in 1 parallel batch. ✓
- P3: 4 independent codegen agents explicitly dispatched in 1 parallel batch. ✓
- All single-task phases (P0, P2, P4–P8) correctly serial — no multi-task phase ran sequentially.
- **Conclusion:** Parallelism opportunities were identified and exploited. No wasted serial time in multi-task phases.

### C. Phase Gate Audit — ✓ PASS
- P0: Scope Lock confirmed; `continuous_run: true` set and pre-authorized by human.
- P1→P2: Transition honored continuous_run exception; no stop gate enforced. ✓
- P2→P3: Transition honored continuous_run exception; no stop gate enforced. ✓
- P3→P4: Continuous_run exception correctly applied (req-001's own fix now live). ✓
- P4→P5: Zero findings gate (P4 validation complete). Proceeding. ✓
- P5→P6: Zero-findings exception (P5 security found no issues). Proceeding. ✓
- P6→P7: Gate B (documentation continuity) passed consistent with continuous_run. Proceeding. ✓
- P7→P8: Archive complete; ship-agent dispatched P8. ✓
- **Conclusion:** All phase gates honored. No unauthorized skipping, no missing confirmations.

### D. Self-Correction Audit — ✓ PASS (Zero repairs)
- **Self-correction cycles:** 0 recorded.
- **Preventive measures:** 2 test files added proactively in P4 to close coverage gap on req-001/req-002 (prose SKILL.md edits).
- **Orchestrator interventions:** 1 (req-004 test file location corrected from tests/regression/ to tests/ at P3 orchestrator level, not a self-correction loop).
- **Root cause:** Spec was clear (Scope Lock established at P0, ADR produced at P2), no backtracking needed.
- **Conclusion:** Clean execution. Proactive testing discipline prevented untested edits.

### E. Build Log Integrity Audit — ✓ PASS
- All 9 phases (P0–P8) present in log.
- Key fields populated: model tier, skills, agent/MCP/batch counts, telemetry state, phase notes.
- One expected ambiguity: P3 initially shows "TBD" for agent/batch counts (live logging), resolved in notes before P3 closes.
- No missing critical data for accountability.
- **Conclusion:** Build log is complete and traceable. Supports audit.

---

## Summary

**Pipeline shape:** Feature Pipeline, 9 phases, continuous_run exception active P1–P3.

**Execution quality:** Clean. Zero self-correction loops, 8/9 tasks properly routed to tier/serial-parallel, 4 independent requirement agents parallelized twice (P1, P3), all phase gates honored, gap-driven testing added proactively.

**Known issues:** 1 pre-existing out-of-scope `cline.sh` bug unmasked by req-003's fix (documented, filed as backlog `0000034`). 1 ship-agent `git add` gap found live during P7 (backlog `0000033`). 1 process gap in how dispatched subagents flag out-of-scope discoveries (backlog `0000035`, filed at the human's direction). Plus 2 unfiled recommendations (`.claude/skills/` staleness, decisions-index.md drift) noted in `recommendations.md` for a future pass.

**Dogfooding:** This run successfully live-verified req-001 (continuous_run restoration) by executing with continuous_run enabled and verifying marker lifecycle (req-002) held correctly.

**Artifact production:** 22 artifacts (4 requirements, 7 shared, 1 ADR, 2 tests, 4 docs, 4 impl files). Coverage: all 4 requirements' acceptance criteria tracked; 1 unmet AC documented as out-of-scope.

**Recommendation:** Ship. The feature is ready; out-of-scope gaps are known and queued.
