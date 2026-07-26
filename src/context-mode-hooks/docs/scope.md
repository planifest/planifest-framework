# Scope — context-mode-hooks

**Component:** context-mode-hooks
**Version:** 0.2.0

---

## In Scope

- `block-grep.mjs` — unconditional `Grep` tool block with redirect to `ctx_execute(language:"shell", code:"grep ...")`
- `block-bash.mjs` — pattern-matched `Bash` tool block with hardcoded allowlist (leading token: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`; leading pair: `npm install`, `pip install`)
- `block-webfetch.mjs` — unconditional `WebFetch` tool block with redirect to `ctx_fetch_and_index` + `ctx_search`
- Setup integration: `install_context_mode_hooks` in `setup.sh` and `setup.ps1`, wiring `node <script>` commands with a fail-open missing-runtime message (0000017 req-004)
- Test suite: 3 component test files plus `test-0000017-req-004-cross-platform-hooks.sh` in the framework suite

---

## Out of Scope (v1)

- Hook scripts for `Read`, `Edit`, `Write` tools — intent indistinguishable from correct usage at hook level
- Hook scripts for non-Claude Code AI tools (Cursor, Copilot, Windsurf)
- Integration test that installs hooks into a real project and exercises end-to-end

---

## Deferred (future)

| Item | Reason Deferred |
|------|----------------|
| Configurable allowlist per project (`.planifest/context-mode.json`) | Adds disk I/O latency; design complexity not justified for v1. See ADR-002. |
| Output-size estimation for Bash (volume-based blocking) | Requires command execution; out of hook scope. |
| Upstream contribution to `mksglu/context-mode` | Post-pipeline activity. See ADR-004 and roadmap. |

> Two former deferred items were closed by the 0000017 `.mjs` port (req-004, ADR-002): "Windows PowerShell hook equivalents" (moot — `node <script>` runs identically on every platform, quirk Q-005 resolved) and "jq vendor / pure-bash JSON implementation" (moot — `jq` is no longer used at all, quirk Q-002 resolved).

---

## Scope Drift (Drift Check)

No scope drift detected (re-verified 0000017 P6). All three `.mjs` scripts listed in-scope are implemented; the former `.sh` scripts are removed. No extra scripts exist outside the declared scope. Component boundaries match `src/context-mode-hooks/` directory with valid `component.yml`.
