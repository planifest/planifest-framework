# Dependency Graph

**Last updated:** 0000028-telemetry-hardening-and-enforcement-fixes (08 Aug 2026, first intra-component module dependency: six shared `.mjs` modules now sit between the hook entry files and their helpers, including two cross-directory edges from `hooks/telemetry/` up into `hooks/enforcement/`. No new cross-component edge was added; the new edges are entirely inside `planifest-framework`'s hooks tree. Prior note, 0000027: `setup-hook-integration`'s `SH` node wires `resolve-phase.mjs` (an interposing hook resolving the active pipeline phase before re-invoking `emit-phase-start.mjs`/`emit-phase-end.mjs`) and `emit-event-receipt.mjs`)
**Maintained by:** planifest-docs-agent

---

## Component Dependency Diagram

```mermaid
graph TD
    subgraph "planifest-framework (component-pack)"
        SKILLS["skills/ (orchestrator + phase agents)"]
        STANDARDS["standards/, templates/"]
        ENFORCE["hooks/enforcement/\n(gate-write, ratchet-check, check-design,\nem-dash-guard, check-telemetry-*)"]
        ENFSHARED["hooks/enforcement/ shared modules\n(read-stdin.mjs, phase-enum.mjs)\nalways installed"]
        TELEM["hooks/telemetry/\n(context-pressure, emit-phase-start,\nemit-phase-end, emit-event-receipt,\nresolve-phase)"]
        TELSHARED["hooks/telemetry/ shared modules\n(emit-event, record-telemetry-failure,\nread-product-id, get-flag-path)\ninstalled only with --structured-telemetry-mcp"]
    end

    subgraph "Claude Code Runtime"
        CC[Claude Code Agent]
        HookRunner["PreToolUse Hook Runner\n(Claude Code internal)"]
    end

    subgraph "context-mode-hooks (this component)"
        BG["block-grep.mjs"]
        BB["block-bash.mjs"]
        BW["block-webfetch.mjs"]
    end

    subgraph "context-mode MCP Server (external)"
        CTX["ctx_execute\nctx_fetch_and_index\nctx_search"]
    end

    subgraph "setup-hook-integration (component-pack)"
        SH["setup.sh / setup.ps1"]
        SKS["skill-sync.sh"]
        MARKER[".planifest-setup-flags\n(per tool dir)"]
    end

    subgraph "planifest-refresh-setup (skill, 0000020)"
        RS["planifest-refresh-setup/SKILL.md"]
        DEL["refresh-delete-boot-files.sh/.ps1"]
    end

    subgraph "System Tools (runtime deps)"
        NODE["node (required, sole runtime)"]
    end

    CC -->|"plans Grep call"| HookRunner
    CC -->|"plans Bash call"| HookRunner
    CC -->|"plans WebFetch call"| HookRunner

    HookRunner -->|"stdin JSON"| BG
    HookRunner -->|"stdin JSON"| BB
    HookRunner -->|"stdin JSON"| BW

    BG -->|"stdout deny JSON"| HookRunner
    BB -->|"stdout deny JSON / empty"| HookRunner
    BW -->|"stdout deny JSON"| HookRunner

    HookRunner -->|"surfaces permissionDecisionReason"| CC
    CC -->|"redirects to ctx_* tool"| CTX

    SH -->|"copies scripts + writes settings.json"| BG
    SH -->|"copies scripts + writes settings.json"| BB
    SH -->|"copies scripts + writes settings.json"| BW
    SH -->|"reads hooks/skills/templates from"| ENFORCE
    SH -->|"copies skills into IDE-discovered dir"| SKILLS
    SKS -->|"syncs external skills for"| SKILLS
    ENFORCE -->|"wired via"| HookRunner
    HookRunner -->|"PreToolUse Write/Edit"| ENFORCE
    ENFORCE -->|"reads Component Paths from"| STANDARDS

    BG --- NODE
    BB --- NODE
    BW --- NODE

    ENFORCE -.->|"imports (13 readStdin callers, 1 phase-enum caller)"| ENFSHARED
    TELEM -.->|"imports cross-directory (../enforcement/)"| ENFSHARED
    TELEM -.->|"imports (same directory)"| TELSHARED
    TELSHARED -->|"POST /emit, retried on network failure only"| BACKEND["Telemetry backend\n(PLANIFEST_TELEMETRY_URL, external)"]
    SH -->|"copies *.mjs (glob widened for tier 1)"| TELEM
    SH -->|"copies *.mjs unconditionally"| ENFSHARED

    SH -->|"writes on successful install"| MARKER
    RS -->|"reads (reconstruction) and writes (pre-deletion cache)"| MARKER
    RS -->|"invokes"| DEL
    RS -->|"re-invokes with confirmed flags"| SH
```

---

## Dependency Direction Notes

- `context-mode-hooks` → `node`: sole runtime dependency since the 0000017 `.mjs` port (req-004, ADR-002); `jq`, `awk`, and `grep` removed; parsing and matching are native JavaScript. If Node is missing, setup warns and the wired command fails open with a runtime message.
- `context-mode-hooks` → `Claude Code hook runner`: platform dependency. Hook scripts are useless without it.
- `context-mode-hooks` → `context-mode MCP server`: conceptual dependency only. Hooks emit redirect text; they do not call the MCP server directly.
- `setup-hook-integration` → `context-mode-hooks`: installer reads from `planifest-framework/hooks/context-mode/` and copies to target project. One-way.
- `setup-hook-integration` → `planifest-framework`: `setup.sh`/`setup.ps1` are the sole distribution mechanism: they copy `skills/`, `hooks/enforcement/`, `templates/`, and `standards/` into whichever directory the target agentic tool auto-discovers. One-way; `planifest-framework` has no dependency back on `setup-hook-integration`.
- `planifest-framework`'s `hooks/enforcement/` → Claude Code's PreToolUse hook runner: `gate-write.mjs` and `ratchet-check.mjs` are invoked on every Write/Edit; `ratchet-check.mjs` additionally reads `plan/current/loop-state-*.md` (not shown, not a component, a runtime artifact) to decide whether it is armed.
- `planifest-framework`'s `hooks/telemetry/` -> `hooks/enforcement/` (0000028, ADR-002): a one-way, cross-directory module dependency. Five telemetry hooks import `../enforcement/read-stdin.mjs`, and two additionally import `../enforcement/phase-enum.mjs`. The direction is not arbitrary and must not be reversed: `install_enforcement_hooks()` runs unconditionally and `install_tier1_hooks()` copies `hooks/enforcement/*.mjs` before `hooks/telemetry/*.mjs`, so `telemetry/` is never present on disk without `enforcement/`, while the reverse is the majority install. A helper with any enforcement caller therefore belongs in `enforcement/`. An import that resolves the wrong way fails at ESM module-load time, before the hook's own `try/catch`, so it breaks the exit-zero invariant rather than degrading gracefully.
- `planifest-framework`'s hook entry files -> their shared modules (0000028): the first intra-component module dependency in this repo. Hooks are installed as copies, not symlinks, so a shared module exists at runtime only because a `setup.sh` glob actually copies it. That is why the tier 1 telemetry glob was widened from `emit-phase-*.mjs` to `*.mjs`: the narrow form would have silently dropped every new shared module for Cursor, Windsurf and Cline while leaving their callers wired.
- `planifest-refresh-setup` (0000020) -> `setup-hook-integration`: two-way relationship via the `.planifest-setup-flags` marker file. `setup.sh`/`setup.ps1` write it on every successful install (producer); the refresh skill reads it for reconstruction and writes to it again before deletion (consumer and secondary writer of the same file, ADR-002). The refresh skill also re-invokes `setup.sh`/`setup.ps1` directly once flags are confirmed, and calls `refresh-delete-boot-files.sh`/`.ps1` (its own hardcoded deletion script, not a dependency on `setup-hook-integration`).

---

## Planned Components (future pipelines)

| Planned Component | Depends On | Provides |
|-------------------|-----------|---------|
| `mcp-workspace-server` | N/A | `ctx_workspace_*` tools for multi-repo operations |
| `mcp-context-mode-fork` | `context-mode-hooks` | Forked context-mode MCP with planifest-specific extensions |
