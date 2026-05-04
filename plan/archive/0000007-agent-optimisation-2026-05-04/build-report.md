# Build Report — 0000007-agent-optimisation — 04 May 2026

> ⚠ **No build-log.md present in archive.** The build log was not maintained during this pipeline run. All phase metrics below are sourced from the session transcript and conversation context. Where metrics cannot be confirmed from observable evidence, they are marked "not evidenced". This constitutes a build log integrity finding — see Efficiency Observations.

---

## Model Usage

| Model tier | Concrete model | Phases used | Agent call count |
|------------|---------------|-------------|-----------------|
| Primary | claude-sonnet-4-6 | P0–P8 (all phases) | 1 (single session agent) |
| Cheaper | none | — | 0 |

**Finding:** Cheaper tier usage was zero. This run did not spawn TDD sub-agents (planifest-test-writer, planifest-implementer, planifest-refactor) because no application code was produced — the feature was framework documentation and configuration only. Cheaper tier non-use is acceptable for this feature type.

---

## Skills Invoked

| Phase | Skill | Load pattern |
|-------|-------|-------------|
| P0 | planifest-orchestrator | Session start |
| P1 | planifest-spec-agent | JIT |
| P2 | planifest-adr-agent | JIT |
| P3 | planifest-codegen-agent | JIT |
| P4 | planifest-validate-agent | JIT |
| P5 | planifest-security-agent | JIT |
| P6 | planifest-docs-agent | JIT |
| P7 | planifest-ship-agent | JIT |
| P8 | planifest-build-assessment-agent | JIT |

---

## Subagent Dispatch

No sub-agents were spawned. This was a single-agent pipeline run — the orchestrator handled all phases directly without delegating to separate agent invocations.

**Total agents spawned:** 0

---

## MCP Tool Usage

| Tool | Call count (estimated) | Purpose |
|------|----------------------|---------|
| ctx_execute (shell) | ~8 | Grep searches for artefact occurrences, test runs |
| ctx_search | ~3 | Retrieving indexed test output sections |
| Read | ~35 | File reads for editing |
| Write / Edit | ~60 | Creating and modifying framework files |

*Counts are estimates from session context — not captured in a build log.*

---

## Parallel Task Bursts

| Phase | Batch count | Tasks parallelised |
|-------|------------|-------------------|
| P0 | 1 | feature-brief.template.md + setup.sh reads |
| P3 (Track A) | 1 | 3 new standards files created in parallel batch |
| P3 (Track B) | multiple | Skill edits batched where independent |
| P3 (Track C/D/E) | 1 | feature-brief edit + optimise-agent creation + setup.ps1 read |
| P3 (Track F) | 1 | Parallel file edits for artefact→artifact across independent files |
| P4 | 1 | Test runs via ctx_execute |

**Phases with no parallelism:** P1, P2, P5, P6 — these had sequential tasks by necessity (each artifact depends on the prior).

---

## Self-Corrections

| Phase | Count | Summary |
|-------|-------|---------|
| P3 | 1 | setup.sh manifest write code placed in `run_tool_setup()` instead of `setup_tool()`; corrected by identifying duplicate function block and removing it |
| P4 | 2 | Test needle `never check host` failed (markdown bold rendering); fixed to `check host-installed runtimes`. Test needle `never run` failed for same reason; fixed to `host toolchain`. |
| P4 | 1 | `locale: en-GB` needle failed (file uses `locale: "en-GB"` with quotes); fixed. |
| P4 | 1 | `components` (lowercase) needle failed for design.template.md (file uses `Components`); fixed. |

**Total self-corrections:** 5

---

## Artifact Counts

| Category | Count |
|----------|-------|
| Requirements | 8 |
| ADRs | 5 |
| Standards files (new) | 3 |
| Templates (new/updated) | 2 |
| Skills (new) | 1 |
| Skills (updated) | 13 |
| Setup scripts (updated) | 2 |
| Test files (new) | 1 |
| Plan artifacts (design, scope, glossary, risk register) | 4 |
| Security report | 1 |
| Changelog / iteration log | 1 |
| Test report | 1 |

---

## Efficiency Observations

### Build log integrity — FINDING

**What happened:** No `build-log.md` was created or maintained during this pipeline run. The pipeline ran across two sessions (context compacted mid-run), and the build log was never initialised from `build-log.template.md` at P0.

**Impact:** Per-phase telemetry (model tier per phase, exact agent call counts, MCP call counts, parallel batch counts) cannot be verified. All metrics in this report are estimates from session context.

**Better approach:** The orchestrator SKILL.md instructs creating `plan/current/build-log.md` from `planifest-framework/templates/build-log.template.md` at P0 and appending at each phase boundary. This was not done. For future runs: create the build log as the first write action at P0, before any coaching or file reads.

### Model routing

**What happened:** Primary model used throughout all phases.

**Assessment:** Acceptable for this feature type. No TDD sub-agent loop was triggered (framework documentation, no application code). If TDD sub-agents were involved, cheaper tier should have been used for planifest-test-writer, planifest-implementer, planifest-refactor.

### Parallelism

**What happened:** File reads and writes were batched in parallel for independent artifacts throughout P3 (Tracks A, B, C, D, E). Test execution and grep searches used ctx_execute (sandbox).

**Assessment:** Parallelism was applied where clearly independent. P3 Track B (13 skill edits) was the largest batch — edits were grouped by independence rather than strictly parallelised per the codegen Parallelism Directive, but the output was correct.

**Finding (minor):** Some skill file edits in Track B were applied sequentially rather than in a single parallel batch. The Parallelism Directive states independent component implementations MUST be parallelised. The skills have no shared state so all 13 could have been dispatched simultaneously. Impact: additional latency, no correctness issue.

### Self-corrections

**5 self-corrections across P3 and P4.** Two categories:

1. **P3 setup.sh edit**: Incorrect placement of manifest write code. Root cause: complex multi-function file; the `setup_tool()` closing brace was not visible when the edit was made. Avoidable with a more targeted read of the function boundary before editing.

2. **P4 test needles (4 corrections)**: Test strings didn't match actual file content (markdown bold formatting, quoted frontmatter values, capitalisation). Root cause: test needles written from memory of file content rather than from the file itself. Avoidable by reading the exact strings from the target files before writing assertions.

### Phase gate audit

Continuous run was pre-authorised at P0 (human selected option 2). P7 stopped as required — commit was performed manually. All gates honoured.

---

## Fast-path Amendment — 2026-05-04

**Commit:** `64a7b5c`

**Change:** Added Category 7 (prohibited punctuation) to `planifest-framework/standards/language-quirks-en-gb.md`. Em dashes must not be used in framework prose or headings; any meaning they carry can be expressed with a colon, comma, or full stop. Rule applied immediately to the file's own heading.

**Files changed:**
- `planifest-framework/standards/language-quirks-en-gb.md` — Category 7 added; heading em dash removed
