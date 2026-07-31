# Planifest Framework: Fix Recommendations (Second Edition)

**Companion to:** `planifest-framework-review-corrected.md`
**First edition:** 2026-07-30
**This revision:** 2026-07-31
**Format:** Requirements written to be liftable straight into a Planifest feature brief.

Requirement IDs are preserved from the first edition so that any prior reference remains resolvable. Where a requirement's content has changed, the change is stated inline and summarised at the end. One requirement is new (REQ-013); one has been substantially reduced (REQ-006); one has been reversed (REQ-011).

---

## Priority summary

| ID | Requirement | Severity | Effort | Order |
|---|---|---|---|---|
| REQ-001 | Correct README counts, paths and structure | High | S | 1 |
| REQ-002 | Fix manifest filename mismatch in CI and shipped hooks | Medium | XS | 2 |
| REQ-003 | Restate CI parity guarantee honestly | Medium | XS | 3 |
| REQ-010 | Reword Hard Limit 1 | Low | XS | 4 |
| REQ-004 | Add a repository self-description check to CI | Medium | S | 5 |
| REQ-013 | Populate the regression pack | Medium | S | 6 |
| REQ-005 | Decompose the orchestrator skill | High | M | 7 |
| REQ-007 | Define a minimal artifact set | High | M | 8 |
| REQ-009 | Add token accounting per phase | Medium | S | 9 |
| REQ-008 | Publish a baseline comparison | High | M | 10 |
| REQ-011 | Record a skill-scope principle | Low | S | 11 |
| REQ-012 | Declare adoption position and stability policy | Medium | S | 12 |
| REQ-006 | *Folded into REQ-005* | — | — | — |

**Suggested grouping.** REQ-001, 002, 003 and 010 as one fast-path feature — all four are text and regex edits with no behavioural surface. REQ-004, 013 and 005 as a second: the two checks are prerequisites that make the orchestrator work safe. REQ-007, 009, 008, 011 and 012 as a third.

**Ordering change from the first edition.** REQ-010 moves early — it is a two-line wording fix in the same files as REQ-001 and costs nothing to carry along. REQ-013 is new and gates REQ-005. REQ-009 now precedes REQ-008, which depends on it.

---

## Wave 1: correctness and credibility

### REQ-001 Correct README counts, paths and structure

*Expanded. The first edition identified three wrong figures; there are five, plus two broken structural references.*

**Problem.** Five of the seven rows in the framework table are wrong: skills 8 against 20, templates 24 against 42, standards 10 against 16, setup 14 against 18, hooks 3 against 8. The `setup/` row also enumerates seven tools where nine adapters ship — `opencode` and `roo-code` are undocumented. `README.md:42` independently claims "orchestrator + 7 phase skills."

In the structure diagram, `README.md:46` points to `planifest-framework/feature-structure.md`, which does not exist — the file is at `plan/feature-structure.md`. `README.md:55` shows a `planifest-docs/` directory where the repository has `docs/`, and where the framework's own CI and hooks encode `docs/` as canonical.

**Requirement.** The framework table and repository structure diagram in `README.md` must describe the repository as it exists, and must not carry figures that will drift again.

**Acceptance criteria.**
- The Count column is **removed** rather than corrected. Counts are a drift-generating construct with no reader value; the folder links already let a reader see the contents.
- Each table row describes its folder by category, not by enumerating members.
- Every path named in the structure diagram resolves to something that exists.
- The diagram's documentation entry names `docs/`, consistent with the path the CI and hooks enforce; the external `planifest-docs` repository remains described in the Documentation section, where it is already correct.
- `README.md:42` and the `setup/` row no longer enumerate a member list.

**Note.** The first edition asked for counts that "equal the directory entry counts." That criterion is unimplementable without an arbitrary counting rule — `standards/` is fourteen `.md` files plus two directories, `templates/` is forty-two entries but thirty-nine `.md`. Deleting the column removes the whole class of defect instead of automating a debate about it.

---

### REQ-002 Fix manifest filename mismatch in CI and shipped hooks

*Expanded, and the failure direction corrected. The first edition named one file and implied an enforcement hole.*

**Problem.** The framework's component manifest is `component.yml`. Four files match against `component.json`:

| File | Live matcher lines | Stale prose lines |
|---|---|---|
| `.github/workflows/planifest.yml` | 26, 37 | — |
| `planifest-framework/hooks/planifest.yml` | 26, 37 | — |
| `planifest-framework/hooks/pre-push` | 22, 38 | 20, 25, 34, 37, 45 |
| `planifest-framework/hooks/pre-commit` | 8 | 11 |

The shipped `hooks/` copies matter more than this repository's CI: `setup.sh` installs them into every consuming repository.

The defect is **over-strictness, not a hole**. The standard matcher is `^(plan/|docs/|.*component\.json)`; `plan/` and `docs/` still match, so nothing slips through. The failure is a false rejection — a change touching `src/` that correctly updates its `component.yml`, without touching `plan/` or `docs/`, is blocked by an error message that names `component.yml` as the very remedy it refused. The fast-path branch fails identically.

**Requirement.** All CI, hook and script file matching must reference `component.yml`, in both the matchers and the human-readable strings.

**Acceptance criteria.**
- No occurrence of `component.json` or the regex `component\.json` remains outside `plan/_archive/`.
- A test asserts that a change touching only `src/` plus a `component.yml`, with no `plan/` or `docs/` change, **passes** — this is the case currently broken.
- A test asserts that a change touching only `src/`, with no manifest, plan or docs change, fails.
- Both tests run against the shipped `hooks/pre-push` and `hooks/pre-commit`, not only against the workflow.

**Note.** Searching for this defect is itself error-prone: the workflow files contain the escaped regex `component\.json`, so a fixed-string search for `component.json` misses them, and an unescaped pattern search misses the plain-text mentions in the hook comments. Verify with both forms.

---

### REQ-003 Restate CI parity guarantee honestly

*Unchanged from the first edition.*

**Problem.** The check proves that a file under `plan/` or `docs/` changed. It does not prove that documentation corresponds to the code changed. The error message and README imply stronger enforcement.

**Requirement.** Documentation and error messages must describe the check as a presence heuristic, not a correspondence guarantee.

**Acceptance criteria.**
- CI failure message reworded to state what was and was not checked.
- The same rewording applied to `hooks/pre-push` and `hooks/pre-commit`, which carry equivalent strings.
- README Hard Limits and Limitations sections reflect the same distinction.

---

### REQ-010 Reword Hard Limit 1

*Moved earlier. Same content, plus the orchestrator alignment made explicit.*

**Problem.** "Requirements must be complete before codegen begins" (`README.md:109`) is unachievable in the strict sense and unfalsifiable as written. The framework's actual behaviour — surface gaps, resolve or explicitly defer them, then proceed — is both better and more defensible than the claim.

**Requirement.** Reword to describe the enforceable behaviour.

**Acceptance criteria.**
- README and orchestrator wording aligned.
- The wording maps to an observable artifact in the plan folder, so that a reader can check the claim rather than take it on trust.

---

### REQ-004 Add a repository self-description check to CI

*Target corrected. The first edition asked for this to extend `consistency-check.mjs`; that is the wrong host.*

**Problem.** REQ-001 drift will recur without automation. The project's own credibility depends on its self-description being accurate.

**Requirement.** CI must fail when the README's structural claims diverge from the repository contents.

**Acceptance criteria.**
- A script verifies that every path named in the README structure diagram exists, and that every folder in the framework table has a row.
- Runs on pull request; failure names the divergent path or row.
- Implemented as a **new repository-scoped script**, not as an extension of `consistency-check.mjs`.

**Note on the corrected target.** `scripts/consistency-check.mjs` validates `plan/current/` during a feature run — story traceability, acceptance-criteria counts, ADR resolution, risk mitigations, design scope — and is invoked by the design-critic with exit-code semantics tied to that role. README-versus-filesystem accuracy is a repository invariant on a different lifecycle, checked in CI regardless of whether a feature is in flight. Combining them couples a per-feature gate to repository metadata and makes `consistency-check.mjs` fail in contexts where it has nothing to say.

**Scope note.** With the Count column removed under REQ-001, this check verifies existence and coverage only. It does not count anything, which is what keeps it stable.

---

## Wave 2: context and ceremony

### REQ-013 Populate the regression pack

*New in this edition.*

**Problem.** `planifest-framework/tests/` holds 29 top-level test scripts. `planifest-framework/tests/regression/` holds one test and a manifest, despite `scripts/promote-to-regression.sh` existing to populate it.

The first edition proposed landing the orchestrator decomposition "behind the regression suite." That mitigation does not currently exist. The promoted suite covers feature 0000016 alone.

**Requirement.** The regression pack contains the tests that guard cross-cutting framework behaviour, and promotion is part of shipping rather than a discretionary afterthought.

**Acceptance criteria.**
- Every test asserting orchestrator routing, phase sequencing, hook enforcement or gate behaviour is promoted.
- The pipeline's ship phase prompts for promotion, and the build log records the promote-or-decline decision with a reason.
- `run-tests.sh` executes the regression pack as a distinct, separately reportable stage.

**Note.** The gap is promotion discipline, not test-writing discipline — 29 tests exist. Whatever routes a test into the pack is missing or unused.

---

### REQ-005 Decompose the orchestrator skill

*Risk framing corrected; scaffolding prerequisite added; REQ-006 folded in.*

**Problem.** `planifest-orchestrator/SKILL.md` is 83,699 bytes, 12,204 words, roughly 21k tokens, loaded in full before work begins. It is 39% of the entire skills corpus of 30,968 words; the next largest skill is 2,521 words and the median is 772. This degrades instruction adherence, which is the failure mode the framework exists to prevent.

The file describes a "Framework Index (JIT Loading)" mechanism. **All twenty skills have an empty `references/` directory.** The mechanism is documented and unimplemented; there is currently nothing to decompose into.

**Requirement.** The orchestrator entry point must be a router. Phase-specific detail must load only when that phase is entered.

**Acceptance criteria.**
- `SKILL.md` under 1,500 words.
- Each phase's detail lives in `references/` and is loaded at phase entry.
- Hard limits, phase table and routing rules remain in the always-loaded file.
- A test asserts that no `SKILL.md` exceeds 1,500 words, with a recorded exemption mechanism rather than a silent bypass. *(This is the whole of former REQ-006 — see below.)*
- The regression pack passes unchanged.

**Dependency.** REQ-013 first. Do not attempt this against a one-test pack.

**Risk.** Medium, not extreme. The first edition called this the highest-risk change in the set; that overstates it. The phase skills are already separate, separately described and separately loadable — this is prose relocation plus load instructions at phase boundaries, not a rearchitecture. The two things that make it safe are a populated regression pack and a full pipeline run compared before and after.

---

### REQ-006 Enforce a skill size budget

**Folded into REQ-005 as a single acceptance criterion.**

The first edition proposed a published budget in `standards/`, a pre-push hook, a CI check and an exemption mechanism. Measured against the corpus, exactly one skill exceeds any sane budget, and REQ-005 fixes it; the next largest is 2,521 words against a 1,500-word target, and the median is 772. That is a one-line assertion in the existing test suite, not a standards document with its own governance apparatus.

Building the full apparatus would add ceremony to a repository whose principal finding is excess ceremony.

---

### REQ-007 Define a minimal artifact set

*Unchanged in substance; the problem statement is now evidenced.*

**Problem.** `planifest-framework/workflows/feature-pipeline.md:25` mandates that Phase 1 produce "execution plan, OpenAPI spec (if applicable), scope, risk register, domain glossary, operational model, SLO definitions, cost model." Only the OpenAPI spec carries a condition. A trivial feature emits a cost model and SLO definitions because the pipeline says so.

Unread artifacts erode the review discipline the PR gate depends on.

**Requirement.** A named minimal set is produced by default. Everything else is opt-in by explicit brief declaration or trigger condition.

**Acceptance criteria.**
- Minimal set documented, with the trigger condition for each optional artifact.
- `feature-pipeline.md:25` and the spec-agent both reflect the conditional set.
- Orchestrator produces only the minimal set absent a trigger.
- README states the default artifact count for a typical feature.

---

## Wave 3: evidence and positioning

### REQ-009 Add token accounting per phase

*Narrowed. Duration is already implemented.*

**Problem.** Adopters ask what the framework costs. Half the answer now exists: `hooks/telemetry/emit-phase-end.mjs:149-172` computes and emits `duration_ms` per phase, degrading silently when unconfigured — the right shape. Token accounting is absent.

**Requirement.** Phase-level token figures recorded per run, alongside the existing duration emission.

**Acceptance criteria.**
- `phase_end` carries token counts where the host tool exposes them, using the same optional-field pattern as `duration_ms`.
- Absent instrumentation degrades gracefully without blocking the pipeline, consistent with existing behaviour.
- Feeds REQ-008 directly.

**Note.** The first edition treated duration and tokens as one unbuilt requirement. Duration landed in feature 0000018. Only the token half remains, which makes this cheaper than originally scoped.

---

### REQ-008 Publish a baseline comparison

*Unchanged, with its dependency made explicit.*

**Problem.** No comparative evidence exists. This is the binding constraint on external adoption.

**Requirement.** Publish a measured comparison of a fixed task set built three ways: baseline agent with no framework, Planifest fast-path, Planifest full pipeline.

**Acceptance criteria.**
- Minimum five tasks of varied size, task definitions published.
- Metrics: defects reaching pull request, rework cycles, total tokens, wall-clock duration.
- Method and raw results published, including results unfavourable to the framework.
- Linked from the README Limitations section, replacing the "no benchmarks yet" note.

**Dependency.** REQ-009 supplies two of the four metrics automatically. Run it first or collect them by hand.

**Note.** Small and honest beats large and delayed. Five tasks published now is worth more than fifty planned.

---

### REQ-011 Record a skill-scope principle

*Reversed. The first edition proposed deprecating four skills; applying its own test retains three of them, and the fourth is marginal.*

**Problem.** The first edition proposed the right test — *does this provide governance or traceability the host tool cannot* — and then did not apply it. Applied:

| Skill | Words | Verdict |
|---|---|---|
| `planifest-test-writer` | 586 | Retain. Enforces one failing test per requirement and RED confirmation by non-zero exit before implementation. Host tools permit test-first; they do not enforce it. |
| `planifest-implementer` | 557 | Retain. Enforces minimum-code-to-green with verified zero exit, gated on the prior RED. The constraint is the ordering. |
| `planifest-refactor` | 528 | Retain, marginal. Thinnest of the four; its governance content is close to host-tool default behaviour. |
| `planifest-verify-by-execution` | 481 | Retain. Encodes "do not accept test output as proof — run the software," which is the opposite of host-tool default. |

Together these are 2,152 words, seven per cent of the skills corpus. The maintenance-liability argument does not survive the sizes involved.

**Requirement.** The durable point survives in weaker form: a stated principle should govern future skill additions so the corpus does not accrete re-specifications of host behaviour.

**Acceptance criteria.**
- An ADR records the governing test and its rationale.
- The four assessments above are recorded against it as worked examples, including the marginal verdict on `planifest-refactor`.
- The ADR is referenced by whatever process adds a new skill.

**Note.** If `planifest-refactor` is later dropped, it should be on the evidence of a build assessment showing it adds nothing, not on this argument.

---

### REQ-012 Declare adoption position and stability policy

*Unchanged from the first edition.*

**Problem.** The repository reads as both an internal standard and a commercial product. The two imply different roadmaps, and the ambiguity deters adopters who need format stability.

**Requirement.** State the current position and the stability commitment in the README.

**Acceptance criteria.**
- README Status section states the intended audience.
- Versioning and breaking-change policy stated, including how migrations are delivered.
- Roadmap link reflects the same position.

---

## Changes from the first edition

| Requirement | Change |
|---|---|
| REQ-001 | Expanded — five wrong rows not three, plus a non-existent `feature-structure.md` path and the `docs/` contradiction. Acceptance criterion changed from correcting counts to removing the Count column. |
| REQ-002 | Scope expanded from one file to four, including both shipped hooks. Failure direction corrected: false rejection, not an enforcement hole. Test criteria rewritten to match. |
| REQ-003 | Unchanged, plus application to the hook strings. |
| REQ-004 | Target corrected — new repository-scoped script rather than extending `consistency-check.mjs`, which is scoped to `plan/current/` on a different lifecycle. |
| REQ-005 | Risk downgraded from highest-in-set to medium, with reasoning. Prerequisite REQ-013 added. Former REQ-006 folded in as one acceptance criterion. Empty `references/` directories noted as a scaffolding prerequisite. |
| REQ-006 | Reduced to a single acceptance criterion under REQ-005. One skill breaches any sane budget and REQ-005 fixes it. |
| REQ-007 | Unchanged; problem statement now cites the mandating line. |
| REQ-008 | Unchanged; dependency on REQ-009 made explicit; reordered after it. |
| REQ-009 | Narrowed to tokens. Duration landed in feature 0000018. |
| REQ-010 | Moved from tenth to fourth — same-file edit as REQ-001, free to carry along. |
| REQ-011 | Reversed. Deprecation replaced by an assessment that retains three skills outright and one marginally, plus the ADR that was the durable part of the original. |
| REQ-012 | Unchanged. |
| REQ-013 | New. The regression pack holds one test; the first edition's mitigation for REQ-005 assumed a populated suite. |
