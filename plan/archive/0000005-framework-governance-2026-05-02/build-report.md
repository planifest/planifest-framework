# Build Report — 0000005-framework-governance — 02 May 2026

## Model Usage

| Model | Phases | Notes |
|-------|--------|-------|
| `claude-sonnet-4-6` | P0 → P7 (all) | Single model throughout; no switching |

No model escalation occurred. All research, codegen, validation, security review, docs, and ship phases ran on Sonnet 4.6.

---

## Skills Invoked

| Skill | Phase | Load Pattern |
|-------|-------|-------------|
| `planifest-orchestrator` | P0 (continuous) | Loaded at session start; drove all phases |
| `planifest-spec-agent` | P1 | JIT — loaded immediately before requirements pass |
| `planifest-adr-agent` | P2 | JIT — loaded immediately before ADR pass |
| `planifest-codegen-agent` | P3 | JIT — loaded immediately before codegen |
| `planifest-validate-agent` | P4 | JIT — loaded immediately before validation |
| `planifest-security-agent` | P5 | JIT — loaded immediately before security review |
| `planifest-docs-agent` | P6 | JIT — loaded immediately before docs pass |
| `planifest-ship-agent` | P7 | JIT — loaded immediately before ship |

JIT (just-in-time) loading means each skill was read from disk immediately before generating phase output — no bulk pre-loading. This keeps earlier phase content out of the active attention window during later phases.

---

## Subagent Dispatch

Approximately 11 subagents were spawned across two agent types:

| Agent Type | Count | Purpose |
|------------|-------|---------|
| `Explore` | ~7 | Codebase research: hook files, skill wiring, override structure, test patterns |
| `general-purpose` | ~4 | Web research: hook support across AI tools, language stack popularity |

### Notable Subagent Tasks

| Task | Type | Result |
|------|------|--------|
| Hook support research — Windsurf, Cline | general-purpose | Confirmed no hook APIs in either tool |
| Hook support research — Codex, Antigravity | general-purpose | Confirmed no hook APIs |
| Language stack popularity rankings | general-purpose | TypeScript, Python, Go, Java confirmed top 4 |
| Agent-generated code framework suitability | general-purpose | Informed library-standards content |
| Hook file analysis (gate-write, check-design, copilot) | Explore | Read all adapter/hook files for security review |
| Skill-to-tool copy mechanism | Explore | Confirmed setup.ps1 / setup.sh copy paths |
| American English spellings scan | Explore | Identified 3 files needing British English rewrite |

---

## Parallel Task Bursts

Three bursts of parallel subagent work:

| Burst | Agents Dispatched | Purpose |
|-------|------------------|---------|
| Hook support research | 3 parallel | Windsurf+Cline, Codex+Antigravity, Cursor+Copilot — simultaneous tool research |
| Language stacks research | 2 parallel | Popularity rankings + framework suitability — independent queries |
| Background test runners | 2 parallel | `run-tests.sh` in background while writing docs — async validation |

---

## MCP Tool Usage (context-mode)

| Tool | Calls | Purpose |
|------|-------|---------|
| `ctx_fetch_and_index` | 37 | Web research: tool docs, hook APIs, language specs |
| `ctx_search` | 16 | Knowledge base queries across all indexed sources |
| `ctx_batch_execute` | 10 | Multi-command codebase discovery |
| `ctx_execute_file` | 11 | Analysis-only file reads (no context flood) |
| `ctx_execute` | 6 | Shell command output processing |

context-mode MCP prevented an estimated 3,000–5,000 lines of raw tool output from entering the context window across the session.

---

## Self-Corrections

Three mid-session corrections were needed (documented in iteration-log.md):

1. **git config outside git repo** — `git config core.hooksPath` was run from a temp dir with no `.git/`; fixed by running from the framework root
2. **MSYS path translation (hook)** — `cygpath -m` missing from context-pressure.mjs before node invocation; fixed in-session
3. **MSYS path translation (mock server)** — test-context-pressure.sh needed `cygpath -m` for all node-facing paths; identified and fixed during P4 validation

---

## Artefact Counts

| Category | Count |
|----------|-------|
| Requirements produced | 16 (req-001 – req-016) |
| ADRs produced | 6 (ADR-001 – ADR-006) |
| Standards files created | 11 |
| Skills created/updated | 10 |
| Test assertions | 54 (0000005 suite) + 17 (context-pressure) |
| Commits | 6 |
