# Design - 0000021-framework-context-bloat-audit

## Feature
- Problem: Planifest's skill and instruction files have accumulated redundant explanation, restated conventions, and spelled-out behavior that current-generation models already infer correctly without being told, inflating the context every agent loads before doing any real work.
- Adoption mode: standard-iterative
- Feature ID: 0000021-framework-context-bloat-audit
- Version: 0.21.0 (minor bump from 0.20.0, Feature Pipeline convention)
- Discovery: see `plan/current/discovery.md` (raw P0 findings — do not embed them here; this document records confirmed decisions only)

## Product Layer
- User stories:
  - US-001: As the human running Planifest pipelines, I want the framework's skill/instruction content audited by a fresh-context Opus 5 agent, so that redundant boilerplate is identified before any edit is made
  - US-002: As the human running Planifest pipelines, I want redundant/implicit content trimmed from skills, templates, standards, and CLAUDE.md while every enforcement-relevant instruction survives, so that agents spend less context on boilerplate
  - US-003: As the human running Planifest pipelines, I want a populated regression pack covering orchestrator routing, phase sequencing, hook enforcement, and gate behavior, so that the trims can be verified safe before they ship
- Acceptance criteria confirmed: 8
- Constraints: never edit `.claude/` (generated, not authored); every Hard Limit/STOP gate/enforcement-referenced instruction must survive; no structural decomposition or skill-scope ADR this pass; regression pack populated and run to record a baseline before any audit or trim begins; failed trims retry up to 5 times with failure-informed reductions, then revert
- Integrations: none

## Architecture Layer
- Latency target: not applicable (no runtime component)
- Availability target: not applicable
- Scalability target: not applicable
- Security: no new auth surface, no PII; `claude-opus-5` model override is project-scoped to this feature only
- Data privacy: no regulated data
- Observability: existing telemetry standards apply; regression pack pass/fail and self-correction counts recorded as the before/after comparison signal; build log records every phase
- Cost boundary: not constrained

## Engineering Layer
- Stack: Markdown (instruction content) / Bash (tests, scripts). No runtime, no database, no cloud, no IaC, no frontend. Testing: existing `planifest-framework/tests/` suite (`run-tests.sh`) plus the newly-populated `tests/regression/` pack. CI: existing `test-000xxxx-*.sh` pattern. Build target: local.
- Components:
  - `planifest-framework` (existing) — skills/, templates/, standards/, plus this repo's root `CLAUDE.md`
- Data ownership: `planifest-framework` owns all touched artifacts
- Deployment: local developer toolchain — no deployment topology
- API versioning: not applicable

## Scope
- In: regression-pack population and baseline run (prerequisite, sequenced first); fresh-context `claude-opus-5` audit pass producing a written findings report; per-file trimming with dual-guardrail review (no enforcement-content loss, no ambiguity/doom-loop regression) and a 5-attempt failure-informed retry before reverting; regression pack re-run and compared against baseline; before/after metrics in the changelog
- Out: anything under `.claude/` (synced copy, refreshed separately via setup.sh); structural decomposition of the orchestrator into a router + `references/` pattern (backlog 0000020); skill-scope principle ADR (backlog 0000024); conditional/minimal per-run artifact set (backlog 0000021); hook `.mjs` logic changes; `external-skills/` content
- Deferred: orchestrator structural decomposition and skill-scope ADR — both blocked until this general bloat-removal pass lands first, per human direction

## Assumptions
- The 29 existing test scripts in `planifest-framework/tests/` are sufficient raw material to promote from for the regression pack — impact if wrong: baseline would need net-new test authoring, extending the prerequisite step before any audit work can start
- `claude-opus-5` is available to this session via the Agent tool's `model` parameter — impact if wrong: audit pass degrades to the default primary tier (Sonnet) with a build-log note, per standard model-tier degradation handling
- Trimming is achievable at the line/paragraph level without file restructuring — impact if wrong: some files may need light restructuring (not full router decomposition) to trim safely; flag to human if a file cannot be trimmed 20%+ without restructuring

## Risks
- Trim silently drops an enforcement-relevant instruction a hook depends on via prose only, not code — likelihood medium, impact high — mitigated by dual-guardrail fresh-context reviewer diffing against the findings report, plus regression pack baseline comparison
- `claude-opus-5` misjudges "implicit" and cuts something a cheaper model actually needs explicitly stated — likelihood medium, impact medium — mitigated by keeping project-specific/non-obvious content, cutting only generic restatement, and the same dual-guardrail review
- Trimmed instructions remain technically complete but become ambiguous, increasing future agent confusion/retries/escalated "doom loops" — likelihood medium, impact high — mitigated by this pipeline run's own P1-P9 phases dogfooding the trimmed orchestrator and phase skills in real time, the 5-attempt failure-informed retry loop, and the baseline self-correction-count comparison
- Scope creep into the deferred structural decomposition (backlog 0000020) — likelihood low, impact medium — mitigated by explicit scope boundary, line-level edits only, no new files/directories
- Regression-pack promotion selects the wrong tests or produces a flaky baseline — likelihood low, impact medium — mitigated by human review of the promoted test list before the baseline run

## Dependencies
- Upstream: none — self-contained framework maintenance work
- Downstream: every future Planifest pipeline run loads the trimmed skills/instructions; this feature is foundational infrastructure for context efficiency across all subsequent feature work

## Active Skills
None — `planifest-framework/skills-inbox/` is empty

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| US-003 — regression pack population and baseline | planifest-implementer | Mechanical promotion of existing test scripts into `tests/regression/`, no novel decisions |
| US-001 — Opus 5 audit pass, findings report | planifest-codegen-agent | No dedicated "audit skill" exists in the framework; codegen-agent owns Phase 3 subagent orchestration and dispatches the `claude-opus-5` audit as a scoped subagent per the model-tier override |
| US-002 — per-file trim + guardrail review | planifest-codegen-agent (apply) + planifest-design-critic (review) | Codegen-agent applies the trim; design-critic's fresh-context REJECT-default critique pattern is repurposed as the second-reviewer diff against the findings report and both guardrails |
| US-002 — regression pack re-run and baseline comparison | planifest-validate-agent | Existing CI/test-execution and self-correction skill fits re-running the pack and comparing against the recorded baseline |

## Repo Instructions
### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. In some cases, you don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

The exception to the rule is that you can operate with git and GitHub commands if the human expressly asks you to. Report back if unsuccessful for any reason in these exceptional cases.

### Commit Granularly, Continuously
Commit locally after every meaningful artifact write — do not batch changes waiting for a phase gate, an approval checkpoint, or task completion. A single requirement doc, ADR, TDD cycle, or config fix is a commit on its own; don't hold it pending a bigger, later commit. Uncommitted work in the working directory is unrecoverable progress — commit early and often so nothing sits unsaved.

## Confirmation
Human confirmed this design before proceeding: yes // Date and Time confirmed: 01 Aug 2026 @ 07:08 AM BST
