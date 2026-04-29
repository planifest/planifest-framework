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
