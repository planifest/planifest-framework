---
title: "Operational Model - 0000012-docs-restructure-commit-directives"
summary: "Operational concerns for this feature."
status: "active"
version: "0.1.0"
---
# Operational Model - 0000012-docs-restructure-commit-directives

## Summary

This feature makes changes to documentation files and SKILL.md directives only. There are no running services, no infrastructure, and no on-call requirements.

## Runbook Triggers

None. All changes are static files. No runtime behaviour to observe or intervene in.

## Post-merge Actions

1. Re-run `planifest-framework/setup.sh {tool}` on all developer machines to register updated SKILL.md content with the tool (if required by the tool).
2. Execute the `retroactive-release-tags` migration via the migrator skill.
3. Human pushes retroactive tags: `git push origin --tags`.
