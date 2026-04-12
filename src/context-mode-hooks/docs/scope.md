# Scope — context-mode-hooks

**Component:** context-mode-hooks
**Version:** 0.1.0

---

## In Scope (v1)

- `block-grep.sh` — unconditional `Grep` tool block with redirect to `ctx_execute(language:"shell", code:"grep ...")`
- `block-bash.sh` — pattern-matched `Bash` tool block with hardcoded allowlist (leading token: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`; leading pair: `npm install`, `pip install`)
- `block-webfetch.sh` — unconditional `WebFetch` tool block with redirect to `ctx_fetch_and_index` + `ctx_search`
- Setup integration: `install_context_mode_hooks` in `setup.sh` and `setup.ps1`
- JSON fallback: `jq`-first with `node` fallback for all three hooks
- Test suite: 55 assertions across 3 test files

---

## Out of Scope (v1)

- Hook scripts for `Read`, `Edit`, `Write` tools — intent indistinguishable from correct usage at hook level
- Hook scripts for non-Claude Code AI tools (Cursor, Copilot, Windsurf)
- PowerShell-native equivalents of hook scripts for Windows
- Integration test that installs hooks into a real project and exercises end-to-end

---

## Deferred (future)

| Item | Reason Deferred |
|------|----------------|
| Configurable allowlist per project (`.planifest/context-mode.json`) | Adds disk I/O latency; design complexity not justified for v1. See ADR-002. |
| Output-size estimation for Bash (volume-based blocking) | Requires command execution; out of hook scope. |
| Windows PowerShell hook equivalents | Setup installs `.sh` files; bash required. Deferred to v2. See quirks Q-005. |
| Upstream contribution to `mksglu/context-mode` | Post-pipeline activity. See ADR-004 and roadmap. |
| jq vendor / pure-bash JSON implementation | Significant complexity. jq install guidance added to getting-started.md instead. |

---

## Scope Drift (Drift Check)

No scope drift detected. All three scripts listed in-scope are implemented. No extra scripts exist outside the declared scope. Component boundaries match `src/context-mode-hooks/` directory with valid `component.yml`.
