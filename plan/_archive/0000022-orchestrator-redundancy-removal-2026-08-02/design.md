# Design - 0000022-orchestrator-redundancy-removal

## Feature
- Problem: `planifest-orchestrator/SKILL.md` (10,379 words) is loaded in full every session and restates content whose canonical home is a phase skill, workflow, standard, or template, degrading instruction adherence and costing tokens on every run.
- Adoption mode: standard-iterative
- Feature ID: 0000022-orchestrator-redundancy-removal
- Discovery: see `plan/current/discovery.md` (raw P0 findings — do not embed them here; this document records confirmed decisions only)

## Product Layer
- User stories:
  - US-001: As the human on the loop, I want each pipeline rule stated in exactly one canonical file, so that the orchestrator and its phase skills can never drift apart.
  - US-002: As the orchestrator agent, I want the model-tier table and parallelism/dispatch guidance in a standards file loaded at need, so that always-loaded context shrinks and stale model ids are maintained in one place.
  - US-003: As the framework maintainer, I want explanatory asides removed and content-pinning regression tests updated to assert the new canonical locations, so that the trim is verified lossless.
- Acceptance criteria confirmed: 5 (see feature brief)
- Constraints: 0000021 ADR-002 baseline-gated trim process; tests never deleted or weakened; no em dashes; "human on the loop" phrasing; per-session remote git grant (push at phase gates, PR at P9)
- Integrations: none (file pointers between framework files only)

## Architecture Layer
- Latency target: not applicable (static skill content)
- Availability target: not applicable
- Scalability target: not applicable
- Security: no runtime surface; repository access via existing GitHub permissions; data classification: public repository content, no PII, no credentials
- Data privacy: no regulated data
- Observability: build log per phase; telemetry confirmed-disabled this run
- Cost boundary: not constrained

## Engineering Layer
- Stack: Markdown (skills/standards) / Bash (regression tests) / no database / no ORM / no IaC / no cloud / local compute / local regression pack as CI / Build target: local
- Components: planifest-framework (existing component-pack) — standards, skills, hooks, setup scripts
- Data ownership: none (no data stores)
- Deployment: none (merged to main via PR)
- API versioning: not applicable

## Scope
- In: Class 1 removals (telemetry event table and JSON snippets; per-phase Input/Produces/Gate blocks P1-P7; Fast Path criteria and execution; Scope Lock suggested-answer detail; reversal execute/assess mechanics; retrofit scan and per-mode discovery content; Change Pipeline confirm questions; triple-stated load-the-skill rows); Class 2 relocations (Model Tier Decision Table, Parallelism Rules + Agent Dispatch Template to standards file(s), with pointers from orchestrator, ship-agent, codegen-agent); Class 3 exposition trims; relocation-aware regression test updates; baseline and comparison regression runs; docs updates at ship
- Out: structural router decomposition (backlog 0000020); phase-skill behaviour changes; hook `.mjs` logic; `setup.sh`/`setup.ps1`; other backlog entries (0000020-0000030); `.claude/` synced copies; new enforcement mechanisms (word-count test belongs to 0000020)
- Deferred: nothing deferred

## Assumptions
- Word estimates per section (~2,900-3,300 removable) were approximate. Realised: 1,787 words removed (10,379 -> 8,592) with zero content loss; the remaining gap to the original 7,600 ceiling was reviewed and found to be dense P0 operative content, not duplication. Human confirmed a revised ceiling of 8,600 on 2026-08-02 rather than cutting further.
- A new standards file is an acceptable home for model-tier and parallelism content - impact if wrong: P2 ADR selects an existing standards file instead; no scope change

## Risks
- A cut removes the sole statement of a rule that no regression test pins - likelihood medium, impact high - mitigated by dual detectors: red tests for pinned content, P4 diff review for everything else; both resolve by restoration, never rationalisation
- Regression tests pin phrases scheduled for relocation (4 tests known to grep orchestrator content) - likelihood high, impact low - resolved by relocation-aware test updates in the same commit as the move
- Pointer targets not loaded at the moment of need (rule moved somewhere the agent has not read at that point) - likelihood low, impact high - mitigated by the canonical-owner table in discovery.md: every Class 1 target is already loaded at phase entry or referenced by the JIT index

## Dependencies
- Upstream: 0000021 (guardrailed trim process, populated regression pack) - complete
- Downstream: backlog 0000020 (router decomposition) becomes smaller and safer after this lands

## Active Skills
None (no capability skills relevant to a Markdown/Bash framework trim)

## Skill Map
| Requirement | Best-fit Skill | Rationale |
|-------------|----------------|-----------|
| REQ-001 - regression baseline | planifest-validate-agent | Deterministic pack run and recorded results |
| REQ-002 - class 1 removals | planifest-codegen-agent | Multi-file skill edits with per-section commits |
| REQ-003 - class 2 relocations | planifest-codegen-agent | New standards file plus pointer edits in three skills |
| REQ-004 - class 3 trims and test updates | planifest-codegen-agent | Exposition trims with relocation-aware test edits |
| REQ-005 - comparison rerun | planifest-validate-agent | Baseline comparison per 0000021 ADR-002 |

## Repo Instructions
### Local Git Only
Don't fetch, pull, push or otherwise attempt to use remote git commands. In some cases, you don't have the passphrase so you will always fail on these commands. Instead commit changes to a local feature branch. The human on the loop can confirm that it's up to date at the start of a plan. The human on the loop will push your code and create any pull requests on your behalf. Don't use git worktrees - ensure you are on a feat/ branch but work directly in the working directory.

The exception to the rule is that you can operate with git and GitHub commands if the human expressly asks you to. Report back if unsuccessful for any reason in these exceptional cases.

(Per-session exception active this run: the human on the loop expressly authorised pushing the feature branch and raising the PR; grant recorded in the P0 build log.)

### Commit Granularly, Continuously
Commit locally after every meaningful artifact write — do not batch changes waiting for a phase gate, an approval checkpoint, or task completion. A single requirement doc, ADR, TDD cycle, or config fix is a commit on its own; don't hold it pending a bigger, later commit. Uncommitted work in the working directory is unrecoverable progress — commit early and often so nothing sits unsaved.

## Confirmation
Human confirmed this design before proceeding: yes // Date and Time confirmed: 02 Aug 2026 @ 12:47 PM UTC
