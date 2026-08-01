# Quirks — setup-hook-integration

## Q-001 — context-mode `block-bash.sh` hook fires on git commit messages containing URLs

The context-mode blocking hook intercepts Bash commands containing URL patterns. When `git commit -m "..."` includes an `https://` URL in the message body, the hook blocks the command. Workaround: keep URLs out of commit message bodies, or use multi-line commits via a heredoc that separates the subject (URL-free) from the body.

## Q-002 — `jq` not available on Windows; node used as fallback

`setup.sh` originally used `jq` for `settings.json` manipulation. `jq` is not installed by default on Windows. All JSON operations use `node -e` with BOM-stripping (`.replace(/^\uFEFF/, '')`). This means `node` ≥18 is a hard runtime requirement.

## Q-003 — commit-msg advisory hook subject line length uses byte count, not char count

`${#SUBJECT}` in bash counts bytes, not Unicode characters. For commit messages with non-ASCII characters (e.g., em-dash `—`), the reported length may exceed the actual visible character count. The `—` in `feat(0000003): Phase 3 — commit standards` registers as 3 bytes, causing false advisory triggers when the visual length is under 72 chars. Known but low-impact — advisory hook exits 0.

## Q-004 — `skill-sync.sh sync` produces "No manifest found" on first run

Before any external skills are added, `external-skills.json` does not exist. `cmd_sync` logs "No manifest found — nothing to sync." This is expected and non-fatal (calls use `|| true`), but may appear as noise in setup output.

## Q-005 — Windows `mktemp` paths not recognized as git repos

`mktemp -d` on Windows/Git Bash creates directories under a path that git treats as having "dubious ownership". `git init` in these directories succeeds but subsequent `git config` calls fail with exit 128. This affects the telemetry integration tests (see TD-004).

## Q-006: `Write-SetupFlagsMarker` (0000020) verified statically only, no pwsh in this dev environment

The `.claude/.planifest-setup-flags` marker write added to `setup.ps1` (REQ-008) could not be exercised by a live invocation during this feature's codegen pass because no PowerShell runtime (`pwsh`) is available in this session's environment. `bash`/`setup.sh`'s equivalent logic was verified with live temp-workspace runs (see `tests/test-0000020-req-008-install-time-marker-write.sh`, parts a-d); the `setup.ps1` side (part e) is checked statically (function exists, calls the marker writer, uses the matching field names). Recommend a live `pwsh` run of `test_setup.ps1` plus a manual `.\planifest-framework\setup.ps1 claude-code` invocation on Windows or a pwsh-enabled CI runner before this feature ships, to catch anything the static check cannot (e.g. a `ConvertTo-Json` depth or encoding mismatch).

## Q-007: OpenCode's `setup.ps1` tool config does not return a `SkillsDir`-bearing object (pre-existing)

`setup/opencode.ps1` performs its install as a sequence of top-level statements rather than returning a config object like every other `setup/<tool>.ps1`, so `Invoke-PlanifestSetup`'s `$toolConfig.SkillsDir` is empty for OpenCode on Windows. This predates 0000020 and is out of scope for this feature per `plan/current/scope.md` (general `setup.ps1` parity drift), but it means the new `Write-SetupFlagsMarker` call is guarded to skip silently for OpenCode on Windows rather than error. OpenCode's marker write works correctly on the `setup.sh` side (bespoke branch in `run_tool_setup`, see ADR-002 implementation notes).
