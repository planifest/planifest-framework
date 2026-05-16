# Security Report - 0000009-framework-rail-tightening

**Date:** 12 May 2026
**Phase:** P5
**Reviewer:** planifest-security-agent

---

## Threat Model (STRIDE)

| Threat | Category | Severity | Mitigation |
|--------|----------|----------|------------|
| Crafted `plan/.orchestrator-active` file injects arbitrary text into model context via hook banner | Tampering | Medium | **Fixed in P5**: `featureId` sanitised to `[a-zA-Z0-9\-_.]`, max 80 chars, before banner interpolation |
| `session_id` from hook stdin echoed into strict-mode banner | Info Disclosure | Low | Session_id is Claude Code runtime-controlled; not attacker-reachable in normal use; accepted |
| `cwd` field in hook stdin not validated against process.cwd() | Tampering | Low | Hook only reads local files and writes stdout (no execution); impact limited to wrong-directory sentinel check; accepted |
| Path traversal attempt via `rawTarget` in gate-write | Tampering | None | `resolve(cwd, rawTarget)` produces path outside `cwdPrefix`; falls back to `norm(rawTarget)`; fails all permitted-path checks; correctly blocked |
| Sentinel files (`plan/.orchestrator-active`, `plan/.orchestrator-strict`) deleted or manipulated by attacker | Tampering | Low | Local developer filesystem; no network exposure; attacker with filesystem access can already do anything |

---

## Dependency Audit

No external npm dependencies in any of the new or modified hook scripts. All imports are Node.js built-ins (`node:fs`, `node:path`). No dependency vulnerabilities.

---

## Secrets Management

No hardcoded credentials, tokens, or API keys found in any hook script, setup script, or template file. Confirmed by scan across `planifest-framework/hooks/`.

---

## Authentication & Authorisation Review

Not applicable — this feature adds no API endpoints or authentication flows.

---

## Input Validation Review

| Input | Source | Validation |
|-------|--------|------------|
| `cwd` | Hook stdin JSON | Optional chaining with `process.cwd()` fallback — safe |
| `session_id` | Hook stdin JSON | `(input?.session_id ?? "").trim()` — safe; used only as opaque comparison string |
| `featureId` from sentinel | File read | **Fixed P5**: sanitised to `[a-zA-Z0-9\-_.]`, max 80 chars |
| `rawTarget` in gate-write | Hook stdin JSON | `resolve(cwd, rawTarget)` then prefix check — path traversal correctly blocked |
| JSON.parse of stdin | Hook stdin | Wrapped in outer `try/catch { process.exit(0) }` — malformed JSON exits safely |

---

## Network Policy

Not applicable — all hooks are local filesystem operations. No network calls.

---

## Infrastructure as Code Review

Not applicable — no IaC files in this feature.

---

## Summary

**Overall risk rating: Low**

One Medium finding was identified and fixed during this phase:

1. ~~**S-001 (Medium)**: Prompt injection via crafted `.orchestrator-active` content~~ — **Fixed**: `featureId` sanitised in `check-orchestrator-presence.mjs` before banner interpolation.

Two Low findings accepted as residual risk appropriate for a local developer tool:

2. **S-002 (Low)**: `session_id` echoed into strict-mode banner — Claude Code runtime-controlled; not externally reachable.
3. **S-003 (Low)**: `cwd` from stdin not validated against host value — hook is read-only relative to filesystem state; impact is limited to advisory banner targeting wrong directory.

No credentials, no API surface, no network exposure. Risk profile is appropriate for a local developer toolchain component.
