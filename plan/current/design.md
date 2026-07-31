# Design - 0000020-setup-refresh-skill

## Feature
- Problem: Refreshing a Planifest install's generated artifacts requires manually reconstructing the original `setup.sh`/`setup.ps1` invocation (tool + every flag) by reading installed hook wiring and marker files; nothing records this directly today
- Adoption mode: standard-iterative
- Feature ID: 0000020-setup-refresh-skill
- Version: `0.19.0` → `0.20.0` (minor bump — Feature Pipeline default; last known version from `docs/about.md`)
- Discovery: see `plan/current/discovery.md` (raw P0 findings — do not embed them here; this document records confirmed decisions only)

## Product Layer
- User stories:
  - US-001: As a human on the loop maintaining a Planifest install, I can invoke a skill that detects the named tool's install and reconstructs the setup flags in effect from hook wiring and marker files, so that I don't have to manually reverse-engineer them
  - US-002: As a human on the loop, I can have the skill delete only the boot files `setup.sh`/`setup.ps1` won't regenerate on their own (`CLAUDE.md`, `AGENTS.md`) and re-invoke the correct setup script with confirmed flags, so that templates actually regenerate without touching `settings.local.json` or other user-owned files
  - US-003: As a framework maintainer, I can have `setup.sh`/`setup.ps1` persist the flags used at install time to `.claude/.planifest-setup-flags`, so that future refreshes read them directly instead of inferring them from hook wiring
- Acceptance criteria confirmed: 10 (see `plan/current/feature-brief.md` Acceptance Criteria)
- Constraints: no new external dependencies; this feature's marker-write addition to `setup.sh`/`setup.ps1` must stay in parity between the two scripts
- Integrations: `setup.sh`, `setup.ps1`, and each tool's per-tool sub-script under `planifest-framework/setup/`

## Architecture Layer
- Latency target: not applicable (CLI/dev-tooling skill)
- Availability target: not applicable
- Scalability target: not applicable
- Security: no auth; runs locally; no credentials handled. The one safety-critical boundary is the file-deletion allowlist (`CLAUDE.md`, `AGENTS.md` only) — see Risks
- Data privacy: no regulated data; `.claude/.planifest-setup-flags` holds only flag names/values and a shell command, no secrets
- Observability: flag-by-flag confidence report printed to the human on the loop before any destructive action; on failure, exact attempted command printed as a copyable code block
- Cost boundary: not constrained

## Engineering Layer
- Stack: Bash (`setup.sh`, per-tool `.sh` scripts), PowerShell (`setup.ps1`, per-tool `.ps1` scripts), Markdown (skill authoring), no new runtime/framework/database
- Components:
  - `planifest-refresh-setup` (new skill) — detection, reconstruction, confirmation, safe deletion, re-invocation, failure handling, cross-session recovery
  - `setup-hook-integration` (existing) — `setup.sh`/`setup.ps1` gain the `.claude/.planifest-setup-flags` marker write at install time
- Data ownership: `.claude/.planifest-setup-flags` owned by `setup-hook-integration` (written by `setup.sh`/`setup.ps1`), read and updated by `planifest-refresh-setup` as its retry cache
- Deployment: skill runs locally from the repo root, same as `setup.sh`/`setup.ps1`
- API versioning: not applicable

## Component Paths
- `planifest-framework/skills/planifest-refresh-setup/`
- `.claude/skills/planifest-refresh-setup/`
- `planifest-framework/setup.sh`
- `planifest-framework/setup.ps1`
- `planifest-framework/setup/`
- `planifest-framework/tests/`

## Scope
- In: US-001, US-002, US-003 and all 10 acceptance criteria in `plan/current/feature-brief.md` — tool detection (all tools `setup.sh`/`setup.ps1` support, plus `setup.ps1` parity), flag reconstruction with confidence reporting, human confirmation gate before any deletion, safe boot-file deletion, re-invocation with confirmed flags, failure handling (stop, investigate cause, print attempted command, cache to `.claude/.planifest-setup-flags`), cross-session recovery from that same marker file, install-time marker write in `setup.sh`/`setup.ps1`
- Out: general `setup.sh`/`setup.ps1` parity fixes unrelated to flag reconstruction/persistence (pre-existing `.ps1` drift is a separately-tracked concern); new setup flags not already supported by `setup.sh`/`setup.ps1`
- Deferred: none

## Assumptions
- Installed hook wiring in `.claude/settings.json` (and each tool's equivalent) reliably signals which flags were used at install time — impact if wrong: reconstruction confidence is lower than expected, more runs require human confirmation, which is the designed fallback, not a failure
- `.claude/.planifest-setup-flags`, once present, is preferred over hook-wiring inference — impact if wrong: would need a staleness check between marker contents and actual hook wiring, currently out of scope

## Risks
- The skill deletes files (`CLAUDE.md`, `AGENTS.md`) as part of its normal flow — likelihood: n/a (by design), impact: high if the deletion allowlist is ever widened by mistake; mitigated by AC requiring the allowlist stay hardcoded to exactly those two files and never touch `settings.local.json` or other user-owned files
- A killed process between deletion and setup completion leaves boot files missing — likelihood: low, impact: medium; mitigated by the marker-file retry cache and recovery flow (US-002, cross-session AC)
- `setup.ps1` drift (pre-existing, out of scope) could make the PowerShell side of this feature's own marker-write logic diverge from `setup.sh` if not tested in parity — likelihood: medium, impact: low; mitigated by an explicit parity AC and test coverage for both scripts

## Dependencies
- Upstream: `planifest-framework/setup.sh` and `planifest-framework/setup.ps1` exist and are the canonical install scripts (confirmed)
- Upstream: hook wiring conventions from `0000011-setup-parity-and-consistency` (ADR-001/002/003) and `0000018-telemetry-emission-consistency` (ADR-001 unified telemetry signal) — this feature reads those conventions, does not change them
- Downstream: any human or agent maintaining a Planifest install who currently has to hand-reconstruct a setup invocation

## Active Skills
None

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| US-001 - tool-detection-and-flag-reconstruction | planifest-codegen-agent | direct implementation against existing hook-wiring/marker conventions |
| US-002 - safe-deletion-and-reinvocation | planifest-codegen-agent | direct implementation; failure handling and cross-session recovery are part of the same skill logic |
| US-003 - install-time-marker-write | planifest-codegen-agent | small addition to `setup.sh`/`setup.ps1`, must keep the two scripts in parity |
| Security review of file-deletion boundary | planifest-security-agent | P5 — the deletion allowlist is this feature's one safety-critical surface |

## Repo Instructions
### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. In some cases, you don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

The exception to the rule is that you can operate with git and GitHub commands if the human expressly asks you to. Report back if unsuccessful for any reason in these exceptional cases.

### Commit Granularly, Continuously
Commit locally after every meaningful artifact write — do not batch changes waiting for a phase gate, an approval checkpoint, or task completion. A single requirement doc, ADR, TDD cycle, or config fix is a commit on its own; don't hold it pending a bigger, later commit. Uncommitted work in the working directory is unrecoverable progress — commit early and often so nothing sits unsaved.

## Confirmation
Human confirmed this design before proceeding: yes // Date and Time confirmed: 01 Aug 2026 @ 12:07 AM BST
