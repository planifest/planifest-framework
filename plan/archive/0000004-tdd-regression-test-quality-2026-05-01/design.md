# Design - 0000004-tdd-regression-test-quality

## Feature
- Problem: Planifest pipelines generate code and tests together in P3, with no structured red-green-refactor discipline, no distinction between long-term regression tests and feature-specific tests, and no consolidated test report showing regression health across features.
- Adoption mode: retrofit
- Feature ID: 0000004-tdd-regression-test-quality

## Product Layer
- User stories confirmed: 3
  1. As a pipeline operator, I want each requirement implemented via a red-green-refactor sub-loop so that code is always test-driven and never written before a failing test exists.
  2. As a framework maintainer, I want a curated regression pack that survives feature archives so that core framework behaviour is protected long-term.
  3. As a reviewer, I want a test report at ship time showing all tests run for the plan, the full regression pack state, and which tests were newly promoted to regression.
- Acceptance criteria confirmed: see requirements (P1 output)
- Constraints:
  - Must not break existing pipelines — codegen-agent change is additive
  - Regression pack must survive P7 archive unchanged
  - Sub-agents must be model-efficient (cheaper model tier where task is narrow)
- Integrations: planifest-codegen-agent (inner loop), planifest-ship-agent (report + regression confirmation)

## Architecture Layer
- Latency target: not applicable (offline pipeline tooling)
- Availability target: not applicable
- Scalability target: sub-agent loop runs per-requirement; scales linearly with requirement count
- Security: no external data; no credentials involved; same trust model as existing skills
- Data privacy: no PII; no regulated data
- Observability: test report is the primary observability artifact; regression manifest tracks promotion history
- Cost boundary: sub-agent token cost must be minimised — see Engineering Layer risk mitigation

## Engineering Layer
- Stack: bash, node.js (consistent with existing framework)
- Components:
  - `planifest-test-writer` — new skill; writes one failing test per requirement (red phase); narrow and focused
  - `planifest-implementer` — new skill; writes minimum code to make the failing test pass (green phase); narrow and focused
  - `planifest-refactor` — new skill; improves code quality while keeping all tests passing (refactor phase); narrow and focused
  - `planifest-codegen-agent` (updated) — gains inner TDD loop protocol: for each requirement, orchestrates test-writer → implementer → refactor sub-agents; loads stack capability skill alongside each sub-agent
  - `regression-pack` — new infrastructure: `planifest-framework/tests/regression/` directory, `regression-manifest.json` tracking promoted tests by feature and date, `promote-to-regression.sh` tooling
  - `planifest-ship-agent` (updated) — gains regression confirmation step (presents agent-suggested candidates to human, records human decisions) and test report generation step before archiving
  - `test-report` — new output artifact template; written to `plan/changelog/` at P7
- Data ownership: regression-manifest.json owned by regression-pack component
- Deployment: local framework tooling — no cloud deployment
- API versioning: not applicable

## Sub-Agent Model Tier (Risk Mitigation)
The three TDD sub-agents (test-writer, implementer, refactor) have narrow, well-defined tasks. They SHOULD be invoked with a cheaper/faster model tier (e.g. claude-haiku) to minimise token cost per requirement loop. The orchestrating codegen-agent retains the full model for planning, synthesis, and sub-agent coordination. Model tier selection is an ADR.

Each new skill MUST include a `recommended_model` frontmatter field and note the rationale in its SKILL.md.

## Scope
- In:
  - 3 new skill files: planifest-test-writer, planifest-implementer, planifest-refactor
  - planifest-codegen-agent SKILL.md updated with TDD inner loop protocol
  - planifest-ship-agent SKILL.md updated with regression confirmation + test report steps
  - regression-pack infrastructure (directory, manifest, promotion script)
  - test-report template and ship-time generation
- Out:
  - Retroactive promotion of tests from completed features (0000001–0000003)
  - Changes to planifest-validate-agent, planifest-spec-agent, planifest-adr-agent
  - TDD loop for non-bash/node stacks beyond what existing stack skills cover
  - External CI/test reporting integrations
- Deferred:
  - ML-based automatic regression candidate scoring
  - Cross-feature regression trend dashboard
  - Regression flakiness detection

## Assumptions
- Stack capability skills (e.g. webapp-testing) are available for the declared stack at P3 time — impact if wrong: sub-agents proceed without capability skill, quality degrades but pipeline does not block
- Claude Code Agent tool supports model override per sub-agent invocation — impact if wrong: all sub-agents run at default model tier, cost mitigation not realised
- Existing tests in planifest-framework/tests/ are not retroactively classified — impact if wrong: regression pack starts empty; operators manually seed it post-ship

## Risks
- R-001: Sub-agent token cost — 3 sub-agents × N requirements may multiply context cost significantly. Mitigation: cheaper model tier for sub-agents; narrow skill prompts; capability skill loaded only when declared in stack.
- R-002: Regression pack staleness — promoted tests may break as framework evolves. Mitigation: regression pack runs in full on every P4; failures block P7.
- R-003: Sub-agent coordination failure — test-writer writes a test the implementer cannot satisfy. Mitigation: codegen-agent detects red→green failure after 3 attempts and escalates to human.

## Dependencies
- Upstream: planifest-codegen-agent (reads), planifest-ship-agent (reads)
- Downstream: test-report artifact (consumed by human reviewer)

## Confirmation
Human confirmed this design before proceeding: yes
Date confirmed: 2026-04-25
