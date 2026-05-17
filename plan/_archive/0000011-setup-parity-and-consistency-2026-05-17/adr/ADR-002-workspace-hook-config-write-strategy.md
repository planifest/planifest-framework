---
title: "ADR-002: Workspace hook config write strategy — Planifest owns the workspace-level file"
summary: "For tools that use a single workspace-level hook config file (Windsurf, Cursor, Codex), Planifest setup writes that file entirely with Planifest-managed entries. Users who need custom hooks must use that tool's user-level or system-level config instead."
status: "accepted"
version: "0.1.0"
---
# ADR-002 - Workspace hook config write strategy — Planifest owns the workspace-level file

**Skill:** adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000011-setup-parity-and-consistency
**Status:** accepted
**Date:** 2026-05-16

---

## Context

Setup scripts must write hook configurations so that tools invoke the Planifest hook adapters. Tools differ in how many hook config files they support at the workspace level:

| Tool | Config path | Multiple workspace files? |
|------|------------|--------------------------|
| GitHub Copilot | `.github/hooks/*.json` | Yes — each `.json` file in the directory is loaded |
| Windsurf | `.windsurf/hooks.json` | No — single workspace file (multiple sources: system, user, workspace) |
| Cursor | `.cursor/hooks.json` | No — single workspace file (multiple sources: enterprise, team, project, user) |
| Codex CLI | `.codex/hooks.json` | No — single workspace file (also `~/.codex/hooks.json` for user) |

For Copilot, the setup script writes `planifest.json` into `.github/hooks/` without touching any other file in that directory. User customisations in other `.json` files are untouched.

For Windsurf, Cursor, and Codex, there is only one workspace-level file. The setup script must decide: write and own that file entirely, merge Planifest entries into any existing file, or refuse to write if custom entries are detected.

---

## Decision

**For single-file workspace configs (Windsurf, Cursor, Codex): Planifest setup writes and owns the workspace-level hook config file entirely.**

The file is written with Planifest entries only. A comment header `# Managed by Planifest — do not edit manually` is included.

Users who need custom hooks for these tools must use the tool's **user-level config** (`~/.cursor/hooks.json`, `~/.windsurf/hooks.json`, `~/.codex/hooks.json`), which all three tools support and merge with the workspace config automatically. This is the correct separation of concerns per each tool's documentation.

Setup is idempotent: re-running setup overwrites the workspace file with the same Planifest content. If a user has manually edited the workspace file, those edits will be lost on re-run. This is documented in the setup output.

**For Copilot: write `planifest.json` only.** Other `.json` files in `.github/hooks/` are untouched.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|--------------|
| Merge Planifest entries into existing workspace file | Preserves user customisations in the workspace file | Complex: requires parsing JSON, detecting existing Planifest entries, deep-merging arrays; error-prone on malformed JSON | Complexity risk outweighs benefit; user-level config is the correct place for personal customisations |
| Refuse to write if custom entries detected; instruct user to add manually | Zero risk of overwriting customisations | Setup cannot complete automatically; Planifest's enforce-on-install guarantee is broken | Planifest's value is automated installation; manual steps undermine it |
| Write to user-level config (`~/.cursor/hooks.json` etc.) instead | No conflict with user workspace customisations | Installs Planifest hooks globally for all repos on the machine; breaks repos that do not use Planifest | Per-repo enforcement is a core Planifest requirement; user-level config is not scoped to a repo |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| `setup/windsurf.sh` and `setup/windsurf.ps1` | Write `.windsurf/hooks.json` entirely; include managed-by comment |
| `setup/cursor.sh` and `setup/cursor.ps1` | Write `.cursor/hooks.json` entirely; include managed-by comment |
| `setup/codex.sh` and `setup/codex.ps1` | Write `.codex/hooks.json` entirely; include managed-by comment |
| `setup/copilot.sh` and `setup/copilot.ps1` | Write `.github/hooks/planifest.json` only; no impact on other hooks files |
| `getting-started.md` or equivalent docs | Must document that Windsurf/Cursor/Codex workspace hook files are Planifest-managed; custom hooks belong in user-level config |

---

## Consequences

**Positive:**
- Setup is simple and deterministic — no JSON parsing, no merge logic, no partial-write failures.
- Idempotency is guaranteed — re-running setup always produces the same file.
- All three tools (Windsurf, Cursor, Codex) support user-level configs that merge with workspace configs — so custom hooks have a correct home.

**Negative:**
- A user who edits the workspace hook file manually will have their changes overwritten on the next `setup.sh` run. This must be documented prominently.
- Users unfamiliar with the tool's multi-source config system may be confused about where to put custom hooks.

**Risks:**
- A tool updates its config format (e.g. changes the JSON schema or renames the file) and the written file is silently ignored. Planifest enforcement degrades to instructions-only with no warning.

---

## Related ADRs

- ADR-001 — related-to (the hook config files are what register the adapters whose output format is defined in ADR-001)

---

## Supersedes

- None

## Superseded By

- None
