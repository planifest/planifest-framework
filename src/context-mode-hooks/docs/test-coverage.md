# Test Coverage — context-mode-hooks

**Component:** context-mode-hooks
**Version:** 0.2.0
**Coverage state as of:** 2026-07-26 (0000017 `.mjs` port)

> **0000017 update (req-004):** all 3 component test files now invoke the `.mjs` hooks via `node` (10 assertions currently registered in the component runner, all passing) and the framework suite adds `test-0000017-req-004-cross-platform-hooks.sh` (25 assertions: file presence, setup.sh/setup.ps1 wiring, missing-runtime messaging, behavioral parity, fail-open). Historical run records below predate the port and refer to the former `.sh` scripts — retained as point-in-time records, not current state.

---

## Summary

| Layer | Assertions | Status |
|-------|-----------|--------|
| Unit (hook script behaviour) | 55 | ✅ 55/55 pass |
| Integration (setup.sh + hooks installed) | 0 | ⚠️ REQ-004 manual smoke test required |
| E2E (agent-level hook interception) | 4 | ✅ 4/4 pass — live session 2026-04-12 |

---

## Test Files

| File | Requirement | Assertions | Notes |
|------|------------|-----------|-------|
| `tests/test-block-grep.sh` | REQ-001 | 10 | All AC covered |
| `tests/test-block-bash.sh` | REQ-002 | 35 | All 8 AC covered + allowlist edge cases |
| `tests/test-block-webfetch.sh` | REQ-003 | 10 | All AC covered |
| (manual) | REQ-004 | — | Setup integration — requires human to run |

Run all tests:
```bash
bash src/context-mode-hooks/tests/run-tests.sh
```

---

## Acceptance Criteria Coverage

| AC | Covered By | Status |
|----|-----------|--------|
| REQ-001 AC-1: Grep → deny | test-block-grep.sh | ✅ |
| REQ-001 AC-2: hookEventName = PreToolUse | test-block-grep.sh | ✅ |
| REQ-001 AC-3: reason names ctx_execute | test-block-grep.sh | ✅ |
| REQ-001 AC-4: reason includes pattern + path | test-block-grep.sh | ✅ |
| REQ-001 AC-5: output is valid JSON | test-block-grep.sh | ✅ |
| REQ-002 AC-1: grep → deny | test-block-bash.sh | ✅ |
| REQ-002 AC-2: rg → deny | test-block-bash.sh | ✅ |
| REQ-002 AC-3: curl → deny | test-block-bash.sh | ✅ |
| REQ-002 AC-4: wget → deny | test-block-bash.sh | ✅ |
| REQ-002 AC-5: git status → allow | test-block-bash.sh | ✅ |
| REQ-002 AC-6: mkdir → allow | test-block-bash.sh | ✅ |
| REQ-002 AC-7: npm install → allow | test-block-bash.sh | ✅ |
| REQ-002 AC-8: git log \| grep → allow | test-block-bash.sh | ✅ |
| REQ-003 AC-1: WebFetch → deny | test-block-webfetch.sh | ✅ |
| REQ-003 AC-2: reason names ctx_fetch_and_index + URL | test-block-webfetch.sh | ✅ |
| REQ-003 AC-3: reason names ctx_search | test-block-webfetch.sh | ✅ |
| REQ-003 AC-4: output is valid JSON | test-block-webfetch.sh | ✅ |
| REQ-004 AC-1–5: setup integration | manual smoke test | ⬜ pending |

---

## NFR Coverage

| NFR | Test | Result |
|-----|------|--------|
| NFR-001: < 50ms latency | WARN (not FAIL) in all 3 test files | ⚠️ WARN on Windows (node fallback: 250-310ms). PASS expected on macOS/Linux with jq. |

---

## E2E Results — Live Session 2026-04-12

Hooks tested live inside an active Claude Code session on the planifest-framework repo.

| Command | Hook | Expected | Result |
|---------|------|----------|--------|
| `Grep(pattern:"TODO", path:"src")` | `block-grep.sh` | Blocked → redirect to `ctx_execute` | ✅ Blocked |
| `Bash: grep TODO src/` | `block-bash.sh` | Blocked → redirect to `ctx_execute` | ✅ Blocked |
| `Bash: curl https://example.com` | `block-bash.sh` | Blocked → redirect to `ctx_fetch_and_index` | ✅ Blocked |
| `Bash: git status` | `block-bash.sh` | Allowed (allowlisted) | ✅ Allowed |

**Environment:** Windows, Git Bash, Node.js fallback (no `jq`), Claude Code.
**WebFetch** tested live — blocked ✅. Note: two hooks fired in sequence — `block-webfetch.sh` (ours) and `pretooluse.mjs` (upstream context-mode MCP hook). See quirks note below.

---

## Gaps

1. **REQ-004** — no automated test. Manual smoke test checklist in `plan/current/pipeline-run.md`.
2. **NFR-001 latency** — WARN on Windows. See quirks Q-002 and pipeline-run.md deviation log.
3. **Node fallback path not isolated** — see tech-debt TD-003.
4. **Duplicate WebFetch hooks** — `block-webfetch.sh` and the upstream `pretooluse.mjs` (context-mode MCP) both fire. Consider whether `block-webfetch.sh` is needed when the full context-mode MCP is installed. See quirks Q-006.
