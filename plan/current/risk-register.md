# Risk Register - 0000011-setup-parity-and-consistency

**Feature:** 0000011-setup-parity-and-consistency
**Version:** 0.1.0
**Status:** active

---

| ID | Risk | Category | Likelihood | Impact | Mitigation |
|----|------|----------|------------|--------|------------|
| R-001 | `skill-sync.ps1 sync <tool>` interface differs from expected — setup.ps1 dispatch call uses wrong arguments | Technical | Low | Low | Guard in REQ-003 skips silently if script not found; easy to adjust if interface differs |
| R-002 | Copilot CLI version in use predates hooks support — `.github/hooks/` files written but never invoked | Operational | Medium | Medium | Hook adapters are fail-open; older versions degrade to instructions-only without breaking the session |
| R-003 | Cursor envelope schema changes between now and implementation — `conversation_id` or `workspace_roots` field names change | Technical | Low | Medium | Adapter reads with fallbacks; Cursor also provides `CLAUDE_PROJECT_DIR` env var as a stable alternative for cwd |
| R-004 | Codex CLI hook `PreToolUse` deny response format changes — JSON `hookSpecificOutput` shape is rejected | Technical | Low | High | Adapter exits 0 on unexpected errors (NFR-003); enforcement silently degrades rather than blocking the session |
| R-005 | Windsurf `agent_action_name` field name differs from documented — adapter receives unknown event name | Technical | Low | Low | Unrecognised events exit 0; no enforcement fires but session is not blocked |
| R-006 | Node.js not in PATH when tool invokes hook adapter — `node ...` command fails | Operational | Low | Medium | Tools that bundle Node (Cursor, Copilot CLI, Codex CLI) typically resolve this; adapter failing open (exit 0) means no session block |
| R-007 | `plan/archive/` and `plan/_archive/` both exist in this repo when migration runs — migrator must halt and ask human | Operational | Low | Low | REQ-014 migration doc explicitly handles this case; migrator halts and presents to human rather than merging |
| R-008 | Hook config files written by setup conflict with user-maintained hook configs — setup overwrites custom entries | Technical | Medium | Medium | REQ-015/016/017/018/019 specs say to write a named planifest file (e.g. `planifest.json`) rather than overwriting a root `hooks.json`; for tools that use a single file (Windsurf, Cursor, Codex), setup must merge rather than overwrite |
| R-009 | Roo Code users who run setup after the deprecation notice are not migrated automatically — they must re-run setup with `--tool cline` | Operational | Medium | Low | REQ-017 deprecation message explicitly instructs users; no data loss risk |
| R-010 | Requirement template update (REQ-007) is not retroactively applied to the 19 requirement files already written for this feature | Technical | Low | Low | Acknowledged — existing requirement docs for this feature were written without the new template; they serve as the baseline against which the template is validated |

