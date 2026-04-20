---
feature: 0000003-hook-based-enforcement
phase: security
date: 2026-04-20
reviewer: planifest-security-agent
---

# Security Report — 0000003-hook-based-enforcement

## Threat Model (STRIDE)

| Threat | Category | Severity | Location | Mitigation |
|---|---|---|---|---|
| Malicious skill name with embedded quote/code injected into `node -e` string | Tampering | Medium | `skill-sync.sh:78` (`get_skill_scope`) | Pass `$name` via env var; use `process.env.SKILL_NAME` |
| Path traversal via skill name in `rm -rf "$dest/$name"` | Tampering | Medium | `skill-sync.sh:154–161`, `L208–210` | Validate `$name` matches `^[a-zA-Z0-9_-]+$` before use |
| Downloaded SKILL.md has no size limit, content-type, or schema check | Info Disclosure / Tampering | Medium | `skill-sync.sh:222` (`_fetch_skill`) | Add max-size check; validate YAML frontmatter `^---` present |
| `--from` URL accepts `file://` or `ftp://` scheme, enabling local file read | Info Disclosure | Low-Medium | `skill-sync.sh:218–219` | Validate `--from` value starts with `https://` |
| `--authorized` flag is a social contract — agent can bypass without human confirmation | Elevation of Privilege | Low | `skill-sync.sh:257–263` | By design (ADR-009); no technical second factor |
| `$MANIFEST` path interpolated directly into `node -e` JS string | Tampering | Low | `skill-sync.sh:78` | Replace with env-var pattern (same fix as finding #1) |
| R-008 (pre-existing): hook scripts execute Node.js with filesystem access | Elevation of Privilege | Low | `.claude/hooks/**` | Hooks are framework-shipped; setup writes only framework-relative paths |
| R-009 (pre-existing): `PLANIFEST_TELEMETRY_URL` exfiltration | Info Disclosure | Low | `emit-phase-*.mjs` | Payload contains no credentials; URL is project-owner-controlled |

---

## Dependency Audit

| Dependency | Version | Risk |
|---|---|---|
| `curl` (system) | System default | No known CVE in this usage; `-fsSL` follows redirects. No checksum verification on fetched content (see finding F-003). |
| `node` (system) | ≥18 required | Used for JSON manifest manipulation and hook scripts. No npm deps — only `node:fs`, `node:http` builtins used. |
| `bash` (system) | System default | Hooks use standard POSIX constructs. No `eval`. |

No third-party npm packages introduced by this feature.

---

## Secrets Management

No credentials, API keys, or tokens are introduced or handled by REQ-023/024/025/026.

- `external-skills.json` records skill name, GitHub URL, and install date — no secrets.
- `PLANIFEST_TELEMETRY_URL` (pre-existing) is an env var, not stored in code — unaffected by this feature.
- `commit-msg` hook reads only the commit message file — no credentials in scope.

**Status: No secrets management gaps introduced.**

---

## Authentication & Authorisation Review

No HTTP API introduced. The skill trust model is:

- **Anthropic-hosted skills** (`github.com/anthropics/skills`): trusted by default, no approval gate.
- **Non-Anthropic skills**: require `--authorized` flag, which is a social enforcement mechanism. An autonomous agent could pass this flag without human review.

**Finding F-005** (Low): The `--authorized` flag is documented in ADR-009 as a social contract. No technical second factor (e.g., a human-written confirmation file, a signed token) enforces that human approval actually occurred. Acceptable for a developer-tooling context but worth documenting as a known gap.

---

## Input Validation Review

### `skill-sync.sh` — `$name` parameter

**Finding F-001 — Medium** (`skill-sync.sh:78`, CWE-78 / CWE-116):

```bash
# VULNERABLE: $name is interpolated directly into a JS string literal
node -e "
  const m = JSON.parse(fs.readFileSync('$MANIFEST','utf8'));
  const s = m.skills.find(s => s.name === '$name');   # ← injection point
"
```

A skill name containing `'` followed by JS code (e.g., `foo'; process.exit(1)//`) would execute arbitrary Node.js. `$name` originates from CLI argument or manifest lookup — agent-controlled.

**Recommendation:** Replace with the env-var pattern already used by `add_to_manifest`:
```bash
SKILL_NAME="$name" SKILL_MANIFEST="$MANIFEST" node -e "
  const fs = require('fs');
  const m = JSON.parse(fs.readFileSync(process.env.SKILL_MANIFEST,'utf8'));
  const s = m.skills.find(s => s.name === process.env.SKILL_NAME);
  if (s) process.stdout.write(s.scope);
"
```

### `skill-sync.sh` — `$name` in path operations

**Finding F-002 — Medium** (`skill-sync.sh:154, 208–210`, CWE-22):

```bash
rm -rf "$tool_skills_dir/$name"   # L157
dest_dir="$PLAN_SKILLS_DIR/$name" # L210
```

If `$name` = `../../etc`, `rm -rf` would traverse out of the skills directory. Names come from CLI or manifest — potentially attacker-controlled if manifest is tampered.

**Recommendation:** Add a validation guard before any path operation:
```bash
validate_skill_name() {
  [[ "$1" =~ ^[a-zA-Z0-9_-]+$ ]] || die "Invalid skill name '$1' — only alphanumeric, hyphens, underscores allowed."
}
```
Call at entry to every `cmd_*` function.

### `skill-sync.sh` — `--from` URL scheme

**Finding F-003 — Low-Medium** (`skill-sync.sh:218–220`, CWE-73):

```bash
raw_url="$source_url/SKILL.md"
curl -fsSL "$raw_url" -o ...
```

`curl` supports `file://`, `ftp://`, `ldap://`, etc. A `--from file:///etc/passwd` would exfiltrate local files into the skills directory and expose them to the agent's context.

**Recommendation:**
```bash
if [[ "$from_url" != https://* ]]; then
  die "--from URL must use https:// scheme. Got: $from_url"
fi
```

### `commit-msg` hook

No injection risk. `$COMMIT_MSG` is read from a file via `cat` then pattern-matched with `grep -qiE`. No shell interpolation into commands. Always exits 0. **Clean.**

---

## Network Policy

- Outbound: `curl` to `raw.githubusercontent.com` (Anthropic skills repo) and optionally user-specified `--from` URLs.
- No inbound surface introduced.
- Telemetry outbound (pre-existing, unaffected).

**No new inbound network surface.**

---

## Infrastructure as Code Review

No IaC files in scope for this feature.

---

## Pre-existing Risk Register Confirmation

| Risk | Status | Notes |
|---|---|---|
| R-008: Hook scripts execute arbitrary Node.js | Open — unchanged | No new hooks introduced; existing hooks unaffected by this feature |
| R-009: PLANIFEST_TELEMETRY_URL exfiltration | Open — unchanged | Not in scope for this feature |

---

## Summary

**Overall risk rating: Low**

The feature introduces shell scripts that fetch external content (SKILL.md files) and manage a local JSON manifest. There are no credentials, no production APIs, and no sensitive data in scope. All attack vectors require either a malicious skill name passed by the agent or a MITM against GitHub raw content.

**Top actions before production:**

1. **F-001** — Fix `get_skill_scope()` in `skill-sync.sh` to use env vars instead of direct `$name` interpolation in `node -e` (prevents JS injection via crafted skill names).
2. **F-002** — Add `validate_skill_name()` guard before all path operations in `skill-sync.sh` (prevents path traversal in `rm -rf`).
3. **F-003** — Validate `--from` URL scheme to `https://` only (prevents local file exfiltration via `file://` scheme).
