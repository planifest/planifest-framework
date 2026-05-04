---
title: "ADR-004 - Setup manifest for managed directory tracking"
status: "accepted"
date: "04 May 2026"
feature: "0000007-agent-optimisation"
---
# ADR-004 — Setup manifest file tracks installed directories for clean re-runs

## Context

When `setup.sh` / `setup.ps1` is re-run (e.g. after updating framework skills), it needs to remove the previously installed skill directories before reinstalling. Without tracking what was installed, the script must either delete a hardcoded list of directories (brittle — breaks if names change) or delete the entire target directory (dangerous — may remove user-added files).

## Decision

After each install run, write a `.planifest-manifest` file listing every directory installed. On re-run, read the manifest and remove only the listed directories. Directories not in the manifest are never touched.

## Alternatives Considered

| Option | Pros | Cons | Rejected because |
|--------|------|------|-----------------|
| Hardcode directory names in the script | Simple | Breaks silently when skill directory names change; must be manually updated | Maintenance burden and silent failures |
| Delete entire target directory | Always clean | Destroys user-added files (e.g. `planifest-overrides/capability-skills/`) | Unacceptable data loss risk |
| No cleanup — always add/overwrite | Simple | Stale directories from renamed skills accumulate; agents may load orphaned skills | Orphaned skills add context cost and could conflict |
| Manifest file (chosen) | Precise; survives renames; protects user files | Requires manifest to be accurate; must be written atomically at end of install | Correct behaviour with minimal complexity |

## Affected Components

- `planifest-framework/setup.sh`
- `planifest-framework/setup.ps1`
- `.planifest-manifest` (written to the tool's skill installation directory)

## Consequences

**Positive:**
- Re-runs are safe: only framework-managed directories are ever removed
- Skill renames are handled correctly on the next run
- User-added files in the same parent directory are never touched

**Negative:**
- If setup is interrupted before the manifest is written, the next run may not clean up correctly — mitigated by writing the manifest as the final step after all copies succeed

**Risks:**
- Manifest written to wrong location could cause the cleanup to target wrong directories — mitigated by writing the manifest to the same directory that contains the installed skills, using a relative path

## Related ADRs

- None
