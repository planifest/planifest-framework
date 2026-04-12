# Feature Brief — context-mode Enforcement Hooks

## Problem statement

Context-mode routing rules are advisory. Agents read the rules and override them anyway — choosing Grep or Bash because it's faster, deciding the risk is low. The hooks that currently fire before tool calls inject guidance text but do not block. Without hard enforcement, context window protection is best-effort and degrades under pressure.

## Target users

Agents operating in any Planifest project where `--context-mode-mcp` has been passed during setup. The hooks are invisible to the human — they enforce routing automatically.

## User stories

1. **As an agent with context-mode configured**, when I call `Grep`, I receive a block with a specific redirect instruction so I cannot bypass the routing rules even when it feels convenient.

2. **As an agent with context-mode configured**, when I call `Bash` with a command matching a blocked pattern (`grep`, `rg`, `curl`, `wget`, or any inline HTTP call), I receive a block with the correct sandbox alternative.

3. **As a developer running setup with `--context-mode-mcp`**, enforcement hooks are installed automatically alongside the routing rules file — one flag, complete protection.

## Acceptance criteria

- Calling `Grep` with context-mode hooks active returns a block decision with redirect to `ctx_execute(language:"shell", code:"grep ...")`
- Calling `Bash` with blocked command patterns returns a block decision with the specific sandbox alternative
- Calling `WebFetch` returns a block decision with redirect to `ctx_fetch_and_index`
- `--context-mode-mcp` installs both the routing rules file and the enforcement hooks in a single setup run
- Hooks are installed per-tool into the correct hook configuration location for that tool
- Removing `--context-mode-mcp` (re-running setup without the flag) does not install hooks
- Hook block messages name the specific `ctx_*` tool to use, not a generic error

## Known limitation

`Read` calls cannot be reliably blocked — the hook cannot distinguish "reading to edit" (correct) from "reading to analyse" (should use `ctx_execute_file`). This is documented and accepted. Routing rules remain the mechanism for Read discipline.

## Ownership split

The blocking hook *scripts* are general-purpose context-mode behaviour — not Planifest-specific. They will be contributed to the upstream [context-mode](https://github.com/mksglu/context-mode) repo. Planifest's responsibility is installation and wiring only.

| What | Owned by |
|---|---|
| Blocking `PreToolUse` hook scripts | `mksglu/context-mode` (upstream contribution) |
| Hook config wiring into tool settings | `planifest-framework` |
| Setup flag that installs hooks | `planifest-framework` |

## Scope

**In (planifest-framework):**
- Setup script changes: write tool hook config pointing at context-mode hook scripts when `--context-mode-mcp` is passed
- Tool configs declare hook config file path per tool

**Out:**
- Blocking `Read` calls (cannot distinguish intent at hook level)
- Blocking `Edit` or `Write` calls (these are always correct)
- Runtime detection of context-mode availability (if the hooks are installed, context-mode is assumed configured)
- The hook scripts themselves (upstream contribution — tracked separately)

**Deferred:**
- Per-command output-size estimation for Bash (blocking based on predicted output volume, not pattern match) — too complex for v1

## Stack

- **Hook config:** JSON (Claude Code `settings.json`), tool-equivalent config files
- **Integration:** existing `setup.sh` / `setup.ps1` infrastructure

## Components

| Component | Location | Responsibility |
|---|---|---|
| Hook scripts | `mksglu/context-mode` (upstream) | Blocking enforcement — `Grep`, `Bash` pattern-match, `WebFetch` |
| Setup integration | `setup.sh` / `setup.ps1` | Write tool hook config when `--context-mode-mcp` passed |
| Tool configs | `setup/{tool}.sh` / `setup/{tool}.ps1` | Declare hook config file path per tool |

## Hook config file per tool

| Tool | Hook config location |
|---|---|
| claude-code | `.claude/settings.json` (hooks array) |
| cursor | Deferred |
| windsurf | Deferred |
| cline | Deferred |
| antigravity | Deferred |

## Non-functional requirements

- **Hook latency:** < 50ms execution overhead per tool call interception. Hooks are synchronous shell scripts doing stdin JSON parsing + pattern matching only — no I/O, no network calls.

## Data ownership

No data. Hook scripts are stateless read-then-block.

## Risks

- Tool hook architectures vary — Claude Code's block mechanism may not map cleanly to other tools. Risk: medium likelihood, medium impact. Mitigation: implement Claude Code first; treat other tools as stretch goals.
- Hook script path handling on Windows (PowerShell vs bash shebangs). Risk: medium likelihood, low impact. Mitigation: separate `.ps1` hooks for Windows where needed.
- Overly aggressive blocking breaks legitimate Bash usage (e.g. `git`, `mkdir`). Risk: low likelihood, high impact. Mitigation: allowlist short-output commands explicitly in the pattern match.

## Open questions

1. What is the exact JSON format for Claude Code `settings.json` hook blocks — specifically the `decision: "block"` output contract?
2. Does Cursor support `PreToolUse` hooks with block capability, or advisory-only?
3. Same question for Windsurf, Cline, Gemini CLI.
4. Should the hook allowlist be maintained in the hook script itself, or configurable per-project?
