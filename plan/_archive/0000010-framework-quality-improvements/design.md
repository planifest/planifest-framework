# Design - 0000010-framework-quality-improvements

## Feature
- Problem: Four pipeline quality gaps identified in 0000009 P8 build report: Agent tool never invoked (missing allowedTools entry + no dispatch template), sequential execution where parallel was required, external-skill directory names inconsistent with SKILL.md name fields, and high-signal repos only partially extracted.
- Adoption mode: retrofit
- Feature ID: 0000010-framework-quality-improvements

## Product Layer
- User stories confirmed: 4
- Acceptance criteria confirmed: TBD (written at P1)
- Constraints: Skill directory renames must preserve all file content. No duplicate skill `name` values introduced. Agent allowedTools addition must be scoped to this project's settings only (not global).
- Integrations: planifest-framework/templates/requirement.template.md, planifest-framework/setup.sh, planifest-framework/setup.ps1, planifest-framework/skills/planifest-orchestrator/SKILL.md, planifest-framework/skills/planifest-codegen-agent/SKILL.md, planifest-framework/skills/planifest-validate-agent/SKILL.md, planifest-framework/external-skills/, _temp/ repos (sw-agent-skills, wondelai-skills, garden-skills, marketingskills)

## Architecture Layer
- Latency target: not applicable (no runtime component)
- Availability target: not applicable
- Scalability target: not applicable
- Security: no auth, no API surface, no PII. Agent tool addition to allowedTools: project-scoped only, does not affect global Claude Code settings.
- Data privacy: no regulated data
- Observability: standard defaults — changes validated by existing test suite
- Cost boundary: not constrained

## Engineering Layer
- Stack: Node.js (hooks/scripts), bash, PowerShell, Markdown. No database. No cloud. No IaC. No frontend. CI: existing test-0000010-*.sh pattern.
- Components:
  - `planifest-framework` (existing) — templates, skills, hooks, setup scripts, external-skills library
- Data ownership: planifest-framework owns all framework artifacts; external-skills owns skill content
- Deployment: local developer toolchain — no deployment topology
- API versioning: not applicable

## Scope
- In:
  - REQ-001: Add `## Input Validation` section to `planifest-framework/templates/requirement.template.md` with a filesystem-content AC pattern for requirements that read untrusted file content into displayed or injected output
  - REQ-002: `setup.sh` and `setup.ps1` add `"Agent"` to `allowedTools` when configuring for Claude Code; add Agent dispatch template + parallel batch planning step to `planifest-framework/skills/planifest-orchestrator/SKILL.md` and `planifest-framework/skills/planifest-codegen-agent/SKILL.md`; add pre-execution parallelism checklist to `planifest-framework/skills/planifest-validate-agent/SKILL.md`
  - REQ-003: Audit all `planifest-framework/external-skills/*/SKILL.md` files for name-vs-directory mismatch; rename mismatched directories to kebab-case of the `name` frontmatter field; update `planifest-framework/external-skills/README.md` index accordingly
  - REQ-004: Extract skills from `_temp/sw-agent-skills`, `_temp/wondelai-skills`, `_temp/garden-skills`, `_temp/marketingskills`; write `SKILL.md` + `attribution.txt` per skill under `planifest-framework/external-skills/`; skip categories already covered unless meaningfully different; update `planifest-framework/external-skills/README.md`
- Out:
  - Exhausting `antigravity-awesome-skills`, `privacy-skills`, `useful-ai-prompts` (too large for human review; deferred to feature 0000011 with automated filter)
  - Changes to phase skills other than orchestrator, codegen-agent, validate-agent
  - New original skills (no original work in this pipeline)
  - Global allowedTools changes (only project-scoped settings.json)
- Deferred:
  - Automated bulk filter (option C) for large repos — blocked until a quality-filter script is written (feature 0000011)
  - Agent tool testing end-to-end (requires a test pipeline to spawn and verify an Agent; deferred)

## Assumptions
- `_temp/` repos are still on disk and intact — impact if wrong: REQ-D cannot proceed; pipeline halts at P3
- Skill `name` fields in SKILL.md frontmatter are the authoritative names — impact if wrong: directory rename targets the wrong value
- `allowedTools` in project `.claude/settings.json` takes precedence over global settings for this project — impact if wrong: Agent tool may still prompt; acceptance criterion fails

## Risks
- REQ-C rename touches 200 directories: high probability of some mismatch count being larger than expected — impact Medium; mitigation: dry-run audit before rename, commit separately
- REQ-D skill quality from exhausted repos may be lower than initially sampled — impact Low; mitigation: human spot-check before commit
- Adding Agent to allowedTools enables autonomous subagent spawning — impact Medium if misused; mitigation: project-scoped settings only, not global

## Dependencies
- Upstream: 0000009 (external-skills library, check-orchestrator-presence hook) — must be merged before this branch targets it
- Downstream: 0000011 (automated bulk skill filter) — depends on REQ-D establishing the baseline count

## Active Skills
None

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| REQ-001 — input validation template | planifest-codegen-agent | Template authoring with security awareness |
| REQ-002 — Agent tool + parallelism | planifest-codegen-agent | SKILL.md authoring + settings.json change |
| REQ-003 — skill dir normalisation | planifest-implementer | Mechanical audit + rename operations |
| REQ-004 — additional external skills | planifest-implementer | Bulk file extraction, no novel decisions |

## Repo Instructions
### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. You don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

## Confirmation
Human confirmed this design before proceeding: yes
Date confirmed: 12 May 2026
