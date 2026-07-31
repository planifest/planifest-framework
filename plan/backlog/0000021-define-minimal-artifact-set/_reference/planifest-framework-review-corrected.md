# Planifest Framework: Independent Review (Second Edition)

**Repository:** https://github.com/planifest/planifest-framework
**First edition:** 2026-07-30
**This revision:** 2026-07-31
**Basis:** Working tree of `feat/0000018-telemetry-emission-consistency` at `f2162f7`, with every quantitative claim re-derived from the filesystem rather than carried forward from the first edition.

**Why a second edition.** Several figures in the first edition were stale, one finding understated its own severity, one misdescribed the direction of a defect, and one finding was missed entirely. Corrections are itemised in the final section. The verdict is unchanged.

---

## Verdict

Strong engineering and unusually intellectually honest. Over-specified for most likely consumers, and currently unproven.

As an internal standard for a team that already values traceability, it is credible today. As a public framework, with formats still in flux and no adopters, the missing artifact is a short demonstration with numbers, not more surface area.

---

## What is genuinely good

| Area | Assessment |
|---|---|
| Rationale | The strongest part. "Agentic tools do not remove the planning bottleneck, they move it" is correct and better argued than most of this genre. |
| Substance beyond prompts | Git hooks, CI workflow, JSON schemas, 29 shell test scripts, per-tool setup adapters for nine tools. Above the great majority of spec-driven-AI repositories. |
| Dogfooding | `plan/_archive/` shows the framework built through its own pipeline, with ADRs and build logs. Real evidence of usability, and rare. |
| Honesty | The Limitations and non-goals section is unusual for this category. It should be retained and expanded, not softened. |
| Governance | The phase-reversal protocol and build-log enforcement are well designed, and visibly informed by a real prior failure. |
| Telemetry | `phase_start`/`phase_end` emission with computed `duration_ms`, degrading silently when unconfigured, is the right shape. Landed since the first edition. |
| Licence | Apache-2.0 over MIT for the patent grant is the right call for something with commercial intent. |

---

## Findings

### 1. Context tax on the orchestrator

`planifest-framework/skills/planifest-orchestrator/SKILL.md` is **83,699 bytes, 12,204 words, roughly 21k tokens**, loaded before any work begins.

The distribution matters more than the absolute figure. Across all twenty skills, `SKILL.md` files total 30,968 words. The orchestrator alone is **39% of that**. The next largest is `planifest-codegen-agent` at 2,521 words; the median skill is 772 words. This is not a systemic bloat problem. It is one file.

Two aggravating details the first edition missed:

- The file contains a "Framework Index (JIT Loading)" section describing deferred loading, but its own `references/` directory contains nothing but `.gitkeep`.
- **All twenty skills have an empty `references/` directory.** The JIT-loading mechanism is described in the framework's documentation and implemented nowhere in the skills layer. There is currently nothing to decompose *into*.

Long instruction sets degrade instruction adherence, which is precisely the failure mode the framework exists to prevent.

**Severity: high.** A reliability risk, not merely a cost one.

### 2. Ceremony-to-value ratio

Twenty skills, forty-two template entries, sixteen standards entries, **1,549 markdown files, 37 MB**.

The concern is concrete rather than aesthetic. `planifest-framework/workflows/feature-pipeline.md:25` mandates that Phase 1 produce "execution plan, OpenAPI spec (if applicable), scope, risk register, domain glossary, operational model, SLO definitions, cost model." Only the OpenAPI spec carries a condition. A trivial feature emits a cost model and a set of SLO definitions because the pipeline says so, not because anything about the feature warrants them.

The risk is not rigour. It is documentation theatre in which the artifacts become the deliverable and the reviewer stops reading, at which point the PR gate backstop fails silently.

**Severity: high.** The main barrier to adoption by anyone who is not the author.

### 3. README drift

Five of the seven rows in the framework table are wrong, and both structural references in the repository-structure diagram are wrong.

| README row | Claimed | Actual | Line |
|---|---|---|---|
| `skills/` | 8 | **20** | `README.md:99` |
| `templates/` | 24 | **42** (39 `.md`) | `README.md:100` |
| `schemas/` | 2 | 2 ✓ | `README.md:101` |
| `standards/` | 10 | **16** (14 `.md` + 2 dirs) | `README.md:102` |
| `setup/` | 14 | **18** | `README.md:103` |
| `hooks/` | 3 | **8** | `README.md:104` |
| `workflows/` | 4 | 4 ✓ | `README.md:105` |

The `setup/` row is wrong twice over: it enumerates seven tools, and the directory holds adapters for nine — `opencode` and `roo-code` are shipped but undocumented. Line 42 independently describes "orchestrator + 7 phase skills" against an actual twenty.

In the structure diagram:

- `README.md:46` points to `planifest-framework/feature-structure.md`, described as the canonical directory layout. **That file does not exist.** It lives at `plan/feature-structure.md`.
- `README.md:55` shows `planifest-docs/` as a sibling directory. The repository's own directory is `docs/`, and the framework's CI and hooks encode `docs/` as canonical — `grep -qE "^(plan/|docs/|...)"`. `README.md:144` separately, and correctly, describes `planifest-docs` as an external repository. The diagram is therefore not merely stale; it contradicts the enforcement.

A specification-accuracy framework whose own specification is inaccurate undercuts the pitch within the first thirty seconds of a reader's attention.

**Severity: high, effort low.** The highest ratio of damage to fix cost in the repository.

### 4. Manifest filename mismatch in CI and hooks

The framework's component manifest is `component.yml`. Four files match against `component.json`.

**Live matchers — these gate merges and pushes:**

| File | Lines |
|---|---|
| `.github/workflows/planifest.yml` | 26, 37 |
| `planifest-framework/hooks/planifest.yml` | 26, 37 |
| `planifest-framework/hooks/pre-push` | 22, 38 |
| `planifest-framework/hooks/pre-commit` | 8 |

**Stale prose in comments and error strings:** `pre-push` lines 20, 25, 34, 37, 45; `pre-commit` line 11.

Two corrections to the first edition, both material:

**The scope was understated.** The first edition named only `.github/workflows/planifest.yml`. The same defect is in the shipped `hooks/` copies, which is the more damaging location: those are what `setup.sh` installs into a consumer's repository. The framework's own CI failing is an inconvenience; every adopter's pre-push hook failing is a defect in the product.

**The direction was misstated.** The first edition implied a hole. It is the opposite. The standard check is `^(plan/|docs/|.*component\.json)` — `plan/` and `docs/` still match, so nothing slips through. The failure mode is a **false rejection**: a change that touches `src/` and correctly updates its `component.yml`, without touching `plan/` or `docs/`, is blocked with an error message that names `component.yml` as the remedy it just refused to accept. The fast-path branch, `(component\.json|plan/changelog/)`, fails the same way. This is over-strictness that teaches users the tool is unreliable, not a permissive gap.

Separately, and independently of the bug: the standard check proves only that *some* file under `plan/` or `docs/` changed in the same pull request. It does not establish that documentation corresponds to the code changed. It is a smoke alarm, not a fire door, and the framework's error message and README describe it as stronger than it is.

**Severity: medium for the bug, medium for the overclaim.**

### 5. The regression pack is nearly empty

*(New in this edition.)*

`planifest-framework/tests/` holds 29 top-level test scripts. `planifest-framework/tests/regression/` holds **one test** and a manifest, despite `scripts/promote-to-regression.sh` existing to populate it.

This matters chiefly because it invalidates the mitigation the first edition proposed for the orchestrator decomposition — "land behind the regression suite" — when the promoted suite is a single test covering feature 0000016. The 29 unpromoted scripts are per-feature tests, valuable but not a safety net for a cross-cutting refactor of the entry-point skill.

Promotion discipline is the gap, not test-writing discipline. The tests exist; nothing routes them into the pack.

**Severity: medium**, rising to high if the orchestrator decomposition is attempted before it is addressed.

### 6. No comparative evidence

Acknowledged in the README, and now the binding constraint on the project.

The two questions any adopter asks are: does defect escape rate fall, and what is the token and wall-clock multiple against a baseline agent. The second is now **partially answerable** — `hooks/telemetry/emit-phase-end.mjs:149-172` computes and emits `duration_ms` per phase, work that landed in feature 0000018 after the first edition. Token accounting is not captured. Neither question has a published answer.

Design rationale alone will not carry a framework that asks for this much upfront ceremony.

**Severity: high.** The single highest-leverage gap.

### 7. Hard limit 1 is a slogan

"Requirements must be complete before codegen begins" (`README.md:109`) is unachievable in the strict sense, and unfalsifiable as written. The framework's actual behaviour — record deferrals explicitly and proceed — is better than the wording and should be what is stated.

**Severity: low, but it invites the fair criticism that the framework overpromises.**

### 8. Scope overlap with host tools

*(Substantially revised. The first edition's conclusion was wrong on three of four skills.)*

The first edition proposed the right test — *does this provide governance or traceability the host tool cannot* — and then did not apply it. Applied properly:

| Skill | Words | Verdict |
|---|---|---|
| `planifest-test-writer` | 586 | **Retain.** Enforces exactly one failing test per requirement and confirms RED by non-zero exit before any implementation is written. No host tool enforces test-first ordering; they permit it. |
| `planifest-implementer` | 557 | **Retain.** Enforces minimum-code-to-green with a verified zero exit, gated on the prior RED. The constraint is the ordering, not the code generation. |
| `planifest-refactor` | 528 | **Retain, marginal.** Thinnest of the four. Its governance content is "all tests still pass" — genuine but close to what a host tool does unprompted. |
| `planifest-verify-by-execution` | 481 | **Retain, emphatically.** Encodes "do not accept test output as proof — run the software." This is the opposite of host-tool default behaviour, which is to trust the test run. |

These are 2,152 words in total, seven per cent of the skills corpus. The maintenance-liability argument does not survive contact with the sizes involved.

The durable point stands in weaker form: a principle should govern future skill additions, so that the corpus does not accrete re-specifications of host behaviour. That is worth an ADR. It is not worth a deprecation.

**Severity: low, and strategic rather than immediate.**

### 9. Adoption position is undecided

Zero stars, zero forks, one contributor, formats explicitly subject to change, and a product concept document describing a commercial model. The repository currently reads as both an internal standard and a product, and the two imply different next steps.

**Severity: medium.** A positioning decision, not a defect.

---

## Corrections to the first edition

| First edition | Corrected |
|---|---|
| Orchestrator "80,771 bytes, ~11,600 words" | 83,699 bytes, 12,204 words. Missed that all twenty `references/` directories are empty. |
| "Roughly 1,000 markdown files, 31 MB" | 1,549 markdown files, 37 MB. |
| "README claims 8 skills, 24 templates, 10 standards" — three rows | Five of seven rows wrong. Also missed the non-existent `feature-structure.md` path and the nine-versus-seven tool discrepancy. |
| `component.json` mismatch located in CI only | Present in four files, including the two shipped hooks that adopters install. |
| Mismatch framed as a hole in enforcement | It is a false rejection. Nothing slips through; correct changes are blocked. |
| Finding 7: deprecate four overlapping skills | Three of four provide ordering guarantees host tools do not. Retain; adopt a governing principle instead. |
| No comparative evidence, nothing instrumented | `duration_ms` per phase now emitted. Token accounting still absent. |
| Regression pack treated as a usable safety net | It contains one test. Raised as finding 5. |

---

## What I would do next, in order

1. **Correct the README.** Counts, the `feature-structure.md` path, the `planifest-docs/` versus `docs/` contradiction, and Hard Limit 1's wording. Half a day, and it removes the most damaging first impression.
2. **Fix `component.yml` in all four files**, prioritising the shipped hooks over this repository's CI, and restate what the parity check actually guarantees.
3. **Populate the regression pack** before touching the orchestrator. The decomposition needs a net beneath it.
4. **Decompose the orchestrator** to a router under 1,500 words with phase detail in `references/`. Risk is medium, not extreme, once step 3 is done — the phase skills are already separate and separately loadable, so this is prose relocation plus load instructions, not a rearchitecture.
5. **Define a genuinely minimal artifact set** and make cost model, SLO definitions and operational model conditional on a declared trigger.
6. **Publish one comparative measurement**, however small, against a baseline agent. Add token accounting alongside the existing duration emission first.
7. **Decide whether Planifest is an internal standard or a product**, and prune scope to match.
