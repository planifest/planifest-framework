# Risk — setup-hook-integration

Derived from `plan/current/risk-register.md` — component-scoped items only.

| ID | Risk | Severity | Mitigation | Status |
|---|---|---|---|---|
| R-008 | Hook scripts execute Node.js with filesystem access — a corrupted hook in `.claude/settings.json` could run attacker code | Low likelihood / High impact | Hooks are framework-shipped; setup writes only framework-relative paths; hooks dir is version-controlled | Open |
| R-009 | `PLANIFEST_TELEMETRY_URL` pointing to attacker endpoint exfiltrates session metadata | Low likelihood / Medium impact | No credentials in payload; URL is project-owner-controlled; documented in setup output | Open |
| TD-001 | Path traversal via malicious skill name in `rm -rf` | Medium | Add `validate_skill_name()` — see tech-debt.md | Open (TD-001) |
| TD-002 | JS injection via `$name` in `node -e` | Medium | Use env-var pattern — see tech-debt.md | Open (TD-002) |
| TD-003 | `--from` URL accepts non-HTTPS schemes | Low-Medium | Validate `https://` prefix — see tech-debt.md | Open (TD-003) |
| TD-006 | `setup.ps1` missing skill subcommand routing | Low | Add equivalent to setup.ps1 | Open (TD-006) |
