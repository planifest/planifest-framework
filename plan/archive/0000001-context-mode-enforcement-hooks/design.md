# Design - 0000001-context-mode-enforcement-hooks

## Feature
- Problem: Context-mode routing rules are advisory — agents ignore them. PreToolUse hooks warn but do not block. Context window protection is best-effort.
- Adoption mode: retrofit
- Feature ID: 0000001-context-mode-enforcement-hooks

## Product Layer
- User stories confirmed: 3
- Acceptance criteria confirmed: 7
- Constraints: Hook scripts must be stateless (stdin → stdout only). No I/O, no network calls inside the hook.
- Integrations: Claude Code `settings.json` hooks system; context-mode MCP (assumed configured by the user)

## Architecture Layer
- Latency target: < 50ms hook execution overhead per tool call interception
- Availability target: not applicable — hooks are stateless local scripts
- Scalability target: not applicable
- Security: no credentials, no sensitive data, no auth. Hooks are read-only stdin processors. Hook scripts must not log tool input to disk.
- Data privacy: no regulated data
- Observability: none required for v1 — hook blocks are surfaced directly to the agent as block messages
- Cost boundary: not constrained

## Engineering Layer
- Stack: bash (hook scripts) / JSON (settings config) / existing setup.sh + setup.ps1 infrastructure / CI: existing planifest.yml
- Components:
  - `context-mode-hooks` — bash scripts in `planifest-framework/hooks/context-mode/` that intercept and block Grep, WebFetch, and pattern-matched Bash. Installed to `.claude/hooks/context-mode/` during setup.
  - `setup-hook-integration` — changes to `setup.sh`, `setup.ps1`, and `setup/claude-code.*` that copy hook scripts and write the `settings.json` hook wiring when `--context-mode-mcp` is passed
- Data ownership: no data owned — hooks are stateless
- Deployment: local only — scripts copied into `.claude/hooks/` at setup time, referenced by `.claude/settings.json`
- API versioning: not applicable

## Scope
- In:
  - Hook scripts: block `Grep`, `WebFetch`, and `Bash` commands matching blocked patterns (`grep`, `rg`, `curl`, `wget`, inline HTTP)
  - Bash allowlist: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, `pip install` — short-output commands never blocked
  - Block messages name the specific `ctx_*` replacement tool
  - Setup installs scripts to `.claude/hooks/context-mode/` and writes `settings.json` hook entries
  - Claude Code only
- Out:
  - Blocking `Read` calls (intent indistinguishable at hook level)
  - Hook support for Cursor, Windsurf, Cline, Antigravity (deferred)
- Deferred:
  - Other tool hook wiring — blocked until hook architectures confirmed per tool
  - Output-size estimation for Bash (volume-based blocking vs pattern-based) — too complex for v1
  - Upstream contribution to `mksglu/context-mode` — happens after this pipeline run

## Assumptions
- Claude Code `settings.json` supports `PreToolUse` hooks — **confirmed**. Output format is `hookSpecificOutput.permissionDecision: "deny"` + `permissionDecisionReason`. Top-level `decision`/`reason` are deprecated for PreToolUse.
- Hook stdin includes full `tool_input` JSON — **confirmed**. `tool_input.command` is present for Bash; `tool_input.url` for WebFetch; `tool_input.pattern` / `tool_input.path` for Grep.
- Hook scripts are invoked as bash on all platforms where Claude Code runs — impact if wrong: Windows needs `.ps1` equivalents (deferred)

## Risks
- Allowlist too narrow → legitimate Bash calls blocked → agent cannot proceed. Likelihood: medium. Impact: high. Mitigation: conservative allowlist with explicit list; easy to extend.
- Hook script path resolution on Windows — bash shebang may not resolve correctly. Likelihood: medium. Impact: medium. Mitigation: test on Windows; fall back to inline PowerShell if needed.
- Upstream context-mode changes its hook interface before contribution is made — scripts diverge. Likelihood: low. Impact: low. Mitigation: scripts are versioned in planifest-framework; upstream sync is a known follow-up.

## Dependencies
- Upstream: context-mode MCP configured by the user (assumed present when flag is passed)
- Downstream: upstream contribution to `mksglu/context-mode` (post-pipeline)

## Confirmation
Human confirmed this design before proceeding: yes
Date confirmed: 2026-04-12
