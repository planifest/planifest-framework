# Security Report - 0000011-setup-parity-and-consistency

**Date:** 17 May 2026
**Reviewer:** planifest-security-agent
**Feature:** Hook adapter parity, setup script updates, skill telemetry gate

---

## Threat Model (STRIDE)

This feature delivers a tooling framework — hook adapters and setup scripts. There is no user-facing web surface, no authentication flow, and no database. The threat model is scoped accordingly.

| Threat | Category | Severity | Mitigation |
|---|---|---|---|
| Crafted JSON stdin envelope in hook adapter causes unexpected path resolution | Tampering | Low | All adapters wrap `JSON.parse` in try/catch, fail-open (exit 0) on parse failure |
| `SCRIPT_NAME` argument in `cursor.mjs` constructed into file path (see Finding S-001) | Elevation of Privilege | Low | `existsSync` guard means non-existent paths exit 0; actual risk only if hook config is compromised |
| Path traversal via `rawTarget` in `gate-write.mjs` | Tampering | Low | Resolved and blocked correctly — `resolve(cwd, rawTarget)` followed by `startsWith(cwdPrefix)` check; paths outside cwd fall back to normalised relative form, then fail component-path match |
| Information disclosure via error message including `relTarget` | Info Disclosure | Info | `relTarget` is logged to stdout — appropriate for a local CLI tool; no secrets in the message |
| Malicious `design.md` expands component paths to cover unintended directories | Tampering | Low | design.md is written only by the Planifest pipeline itself (gate-write blocks writes to plan/current without sentinel); external modification would require filesystem access |
| Large stdin payload causing slow `resolve()` or `JSON.parse()` | DoS | Info | Node.js handles gracefully; hooks exit after single parse cycle with no loops |

---

## Dependency Audit

All hook adapters (`copilot.mjs`, `cursor.mjs`, `windsurf.mjs`, `codex.mjs`, `gate-write.mjs`, `check-design.mjs`) use **Node.js built-ins only**:
- `node:fs`, `node:path`, `node:child_process`, `node:os`, `node:url`

No external npm packages are imported. Supply-chain risk is eliminated.

Setup scripts (`setup.sh`, `setup.ps1`) use standard system tools only (`bash`, `sed`, `awk`, `git`, `PowerShell` built-ins). No third-party tooling installed.

**Verdict:** No vulnerable or abandoned dependencies.

---

## Secrets Management

Scanned all modified files for hardcoded credentials, API keys, tokens, and passwords.

- `setup.sh` / `setup.ps1`: No secrets. `PLANIFEST_TELEMETRY_URL` default is `http://localhost:3741` (localhost only — not a credential).
- All hook adapters: No secrets. No environment variables read beyond `process.execPath` (Node.js own path).
- `context-pressure.mjs`: Reads `PLANIFEST_TELEMETRY_URL` from environment — correct pattern; no hardcoded URL in emitted code.
- Skill SKILL.md files: Documentation only. No secrets.

**Verdict:** No secrets in code.

---

## Authentication & Authorisation Review

Not applicable — this feature has no API surface and no authentication flow. The hook adapters are local IPC mechanisms invoked by the IDE.

---

## Input Validation Review

### gate-write.mjs — stdin JSON (planifest-framework/hooks/enforcement/gate-write.mjs)

- `JSON.parse(raw)` wrapped in top-level try/catch → exit 0 on failure. Safe.
- `rawTarget = toolInput?.path ?? toolInput?.file_path ?? ""` — empty string case handled (`if (!rawTarget) process.exit(0)`). Safe.
- `resolve(cwd, rawTarget)` normalises paths including `..` components. Prefix check against `cwdPrefix` correctly handles traversal attempts — paths outside cwd fall back to the raw normalised form, which then fails the component-path allowlist.

### cursor.mjs — argv[2] path construction (planifest-framework/hooks/adapters/cursor.mjs:66-67)

**S-001 (Low):** `SCRIPT_NAME` from `process.argv[2]` is used to construct a file path:
```js
const scriptSubdir = SCRIPT_NAME.startsWith("emit-") ? "telemetry" : "enforcement";
const scriptPath = join(HOOKS_DIR, scriptSubdir, `${SCRIPT_NAME}.mjs`);
```
An adversary who can modify the IDE hook configuration could pass a traversal string (e.g., `../../evil`) as `argv[2]`, causing `scriptPath` to resolve outside the hooks directory. The `existsSync` guard prevents execution of non-existent paths, but an attacker with filesystem access sufficient to plant a file could trigger execution.

**Severity:** Low — requires IDE hook configuration write access, which implies broader compromise. No fix required for production, but an allowlist validation would harden this.

### copilot.mjs / windsurf.mjs / codex.mjs

All three follow the same pattern: JSON parse → normalise event name → spawnSync with explicit script path resolved from `__dir`. No user-controlled string reaches `spawnSync` arguments directly.

---

## Network Policy

No network connections made by hook adapters at runtime. `context-pressure.mjs` makes an HTTP POST to `PLANIFEST_TELEMETRY_URL` (default: `http://localhost:3741`) — localhost only by default. The `--backend-url` flag allows override; no validation is performed on the URL value.

**S-002 (Info):** `--backend-url` in setup.sh accepts any URL without validation. A user could configure a remote URL. This is intended behaviour (telemetry to a remote server is supported), but it should be documented. No technical finding.

---

## Infrastructure as Code Review

Not applicable — this feature contains no IaC files (Terraform, Pulumi, CDK, etc.).

---

## Risk Register Cross-Reference

| Risk ID | Status |
|---|---|
| R-001: skill-sync.ps1 interface | Open — not a security concern |
| R-002: Copilot CLI version predates hooks | Open — mitigated by fail-open design |
| R-003: Cursor envelope schema changes | Open — mitigated by fallback field reads |
| R-004: Codex deny format changes | Open — mitigated by exit 0 on unexpected errors |
| R-005: Windsurf event field name | Open — unrecognised events exit 0 |
| R-006: Node.js not in PATH | Open — tool-bundled Node handles most cases |
| R-007: plan/archive coexistence | Mitigated — migration 0003 applied |
| R-008: Hook config file conflicts | Mitigated — named planifest files used; merge not overwrite |
| R-009: Roo Code user migration | Open — informational, no security risk |
| R-010: Requirement template retroactive | Open — acknowledged, no security risk |

---

## Summary

**Overall risk rating: Low**

The implementation is a local tooling framework with no network exposure, no authentication, no external dependencies, and a consistently applied fail-open NFR. No critical or high findings.

Top actions before production:

1. **(S-001, Low)** Add an allowlist validation for `process.argv[2]` in `cursor.mjs` to restrict SCRIPT_NAME to known values (`gate-write`, `check-design`, `emit-phase-start`, `emit-phase-end`). This closes the theoretical path traversal in script resolution.
2. **(S-002, Info)** Document that `--backend-url` accepts remote URLs — add a note in setup.sh usage text so users understand telemetry can be sent off-host.
3. No further actions required for this risk tier.
