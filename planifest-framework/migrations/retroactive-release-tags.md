---
title: "Migration: retroactive-release-tags"
type: "git-operation"
description: "Tag historical merge-to-main commits with their release version tags (v0.1 through v0.10)."
status: "pending"
created: "2026-05-18"
feature: "0000012-docs-restructure-commit-directives"
---
# Migration: retroactive-release-tags

> Processed by the `planifest-migrator` skill. Human confirmation required at each step. Tags are created locally only — the human pushes them.

---

## Context

The repository has no git tags for releases prior to this migration. Tags v0.1 through v0.10 need to be applied retroactively to the merge-to-main commits for each release.

---

## Step 1 — List merge commits

Run the following command and present the output to the human:

```bash
git log --oneline --merges origin/main
```

> If `origin/main` is not accessible (local-git-only), use:
> ```bash
> git log --oneline --merges main
> ```

Present the full output. Ask the human to map each merge commit to its release version.

---

## Step 2 — Confirm commit → version mapping

Present a table for the human to fill in:

| Version | Commit SHA | Commit message |
|---------|-----------|----------------|
| v0.1 | `{sha}` | `{message}` |
| v0.2 | `{sha}` | `{message}` |
| v0.3 | `{sha}` | `{message}` |
| v0.4 | `{sha}` | `{message}` |
| v0.5 | `{sha}` | `{message}` |
| v0.6 | `{sha}` | `{message}` |
| v0.7 | `{sha}` | `{message}` |
| v0.8 | `{sha}` | `{message}` |
| v0.9 | `{sha}` | `{message}` |
| v0.10 | `{sha}` | `{message}` |

Wait for human confirmation of the complete mapping before proceeding.

---

## Step 3 — Validate SHAs

For each SHA in the confirmed mapping, validate it matches `[0-9a-f]{7,40}`. If any SHA does not match, do not run the tag command for that entry — prompt the human to supply the correct SHA.

---

## Step 4 — Create tags

For each confirmed and validated entry, run:

```bash
git tag {version} {sha} -m "{version}"
```

Example:
```bash
git tag v0.1 abc1234 -m "v0.1"
git tag v0.2 def5678 -m "v0.2"
```

Confirm each tag was created successfully before moving to the next.

---

## Step 5 — Human pushes tags

This migration does not push tags (local-git-only constraint). Instruct the human:

```
All tags created locally. Push with:

  git push origin --tags

Verify on the remote that all tags appear.
```

---

## Step 6 — Mark migration complete

Move this file to `planifest-framework/migrations/_done/retroactive-release-tags.md`.

```bash
mkdir -p planifest-framework/migrations/_done
mv planifest-framework/migrations/retroactive-release-tags.md \
   planifest-framework/migrations/_done/retroactive-release-tags.md
git add planifest-framework/migrations/
git commit -m "chore(migrations): complete retroactive-release-tags"
```
