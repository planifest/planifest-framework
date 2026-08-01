# Audit Findings — Skills, Round 2

Second-round fresh-context audit of 18 `planifest-framework/skills/*/SKILL.md` files, read in their
current post-trim state. Excludes `planifest-migrator`, `planifest-optimise-agent` (already at target)
and `planifest-orchestrator` (handled separately).

**Aggregate current:** 2207 lines
**Aggregate honest target:** 1922 lines (-285, 12.9%)
**Files with genuinely new reducible content:** 16 of 18
**Files already exhausted:** 2 (`planifest-reversal-assessor`, `planifest-verify-by-execution`)

---

## Cross-cutting findings

These two patterns account for most of the aggregate and are listed per-file below rather than
repeated in full.

### C1 — Excess `---` horizontal rules (170 lines, 60% of the total cut)

103 body-level `---` rules across the 18 files. Markdown `##` headers already delimit sections; each
rule costs 2 lines (the rule itself plus one of its two surrounding blanks) and carries no
information.

The four newest files in the corpus (`design-critic`, `reversal-assessor`, `scope-lock-agent`,
`verify-by-execution`) already use exactly one rule — the one closing the blockquote intro — and read
no worse for it. The remaining 14 files carry 5 to 10 each. Normalising every file to the newer
one-rule convention removes 85 rules = **170 lines** with zero information loss and no structural
change.

Three files (`implementer`, `refactor`, `test-writer`) additionally end with a trailing `---` on the
final line, which delimits nothing at all.

### C2 — Double telemetry pointer (14 lines)

Seven files open their `## Telemetry` section with two consecutive lines that both say "go read
`telemetry-standards.md`":

```
See `planifest-framework/standards/telemetry-standards.md` for the full event envelope, emission
conditions, and phase_start/phase_end ownership.

**Emission gate:** see `telemetry-standards.md` for the block-or-proceed protocol when telemetry is
active but `emit_event` fails.
```

Affected: `adr-agent`, `change-agent`, `codegen-agent`, `docs-agent`, `security-agent`, `spec-agent`,
`validate-agent`. Collapsible to a single line naming both concerns (envelope, gate, failure
handling) plus the ADR refs where present. **-2 lines each = -14.**

### Split of the aggregate

| Source | Lines |
|---|---|
| C1 horizontal rules | 170 |
| C2 telemetry double pointer | 14 |
| Per-file content findings | 101 |
| **Total** | **285** |

The content-only figure (115 lines including C2, 5.2% of corpus) is the honest measure of remaining
*prose* redundancy. The first pass left these files genuinely lean on content; C1 is the one large
uniform win still available.

---

## planifest-adr-agent

**Current:** 82 · **Target:** 61 (-21)

| Lines | Item | Rationale |
|---|---|---|
| 73-77 | C2 telemetry double pointer | -2 |
| 16-27 | `## Input` (2 bullets) + `## What You Produce` (1 line) | Two headers, four blank lines and a rule carrying 3 lines of content. Merge to one `## Input / Output` section. -3 |
| 46-48 | `## ADR Format` → "Follow the [ADR Template](../templates/adr.template.md)." | Whole section is a pointer to a template already declared in `bundle_templates: [adr.template.md]`. Fold the link into What You Produce. -3 |
| 57 | Rule: "Do not write ADRs for decisions that are fixed by the stack declaration - those are already decided." | Restates line 42's closing clause ("direct consequences of the stack declaration ... don't either") in the same file. Keep only the non-duplicated half ("Write one ADR that records the stack choice itself"). -1 |
| — | C1: 6 excess rules | -12 |

Also worth trimming without a line saving: line 42's "but those are self-evident" is a WHY that
weakens the rule it closes.

**Load-bearing, keep:** the six-row "What Requires an ADR" criteria table, the Parallelism Directive
table, the `adr_decision` event shape, "One question at a time."

---

## planifest-build-assessment-agent

**Current:** 151 · **Target:** 127 (-24)

| Lines | Item | Rationale |
|---|---|---|
| 16-19 | `## Prefix` section | The `P8:` prefix token is load-bearing; the standalone section is not. One sentence carrying its own header + blanks + rule. Fold verbatim into Hard Limits as item 1. -2 (plus its rule, counted in C1) |
| 29-39 | `## Input` + `## What You Produce` | Same short-section merge as adr-agent. -3 |
| 133-139 | `## Rules` bullets 2, 4, 5 | Genuine within-file duplication of `## Critical Audit` (104-130): rule at 136 ("if the build log is sparse ... note which phases have no recorded data") restates the Build log integrity bullets at 128-129; rule at 138 ("default to: not evidenced — treat as not applied") and rule at 139 ("if a phase has no build log entry, assume it was not parallelised and did not use the cheaper tier") are the same instruction stated twice, and both restate 109 and 115. Collapse five bullets to two: source-from-log, and be-specific-adversarial-default-to-not-evidenced. -3 |
| — | C1: 8 excess rules | -16 |

**Load-bearing, keep:** the whole `## Critical Audit` block (104-130) — five named audits with
specific interrogatives, all project-specific; the report-structure fence; the `P8: Complete` token.

---

## planifest-change-agent

**Current:** 171 · **Target:** 156 (-15)

| Lines | Item | Rationale |
|---|---|---|
| 147-151 | C2 telemetry double pointer | -2 |
| 141-143 | `## Capability Skills` | Two sentences under their own header. The second ("Follow Code Quality Standards for all code changes") restates `bundle_standards: [code-quality-standards.md]` in the frontmatter and is not about capability skills at all. Fold the first sentence into Phase 2 Rules. -3 |
| — | C1: 5 excess rules | -10 |

Non-line-saving trims: line 98's WHY ("leaving `plan/current/` in place misleads future
adoption-mode detection") is longer than the WHAT it justifies; Phase 1 read-list item 6
("domain-glossary.md - confirm you are using the correct terms") restates Phase 2 rule at line 56.

**Load-bearing, keep:** the Phase 6 archive sequence — it duplicates ship-agent's P7 Step 6 by
design, because the Change Pipeline never invokes the ship-agent; the migration-proposal stop
(line 60); the ADR-invalidation sequence; the blast-radius steps; the change-summary fence.

Observation, not a cut: `## Output Header` (122-137) says "Before writing any code, produce this
summary" but is positioned after Phase 6 (archive), so an agent reading top-down encounters it long
after the point it applies.

---

## planifest-codegen-agent

**Current:** 238 · **Target:** 207 (-31)

| Lines | Item | Rationale |
|---|---|---|
| 214-218 | C2 telemetry double pointer | -2 |
| 29-34 | Precision Reading Protocol preamble | "**Precision Reading Protocol:**" / "Do not read the entire `plan/` directory unconditionally." / then "1. Scope your context by navigating precisely:" — three lines of framing for the same instruction, and the numbered "1." has no sibling "2." (the bullets at 40-41 are orphaned continuations at the wrong level). Collapse to one header line + the list. -2 |
| 45-47 | `## Capability Skills` | One paragraph under its own header; the load-bearing sentence is "Do not invent a skill reference that does not exist." Fold into `## Input`. -3 |
| 71-74 | "Between components, verify:" + 3 bullets | Each bullet restates a rule already stated elsewhere in the same file: shared types → line 164; API contracts → line 99; data contracts → line 113. Pure restatement in a different position. -5 |
| 197-202 | Parallel Dispatch Checklist steps 3-5 | Steps 3 ("identify leaf requirements"), 4 ("dispatch all leaf requirements in a single parallel batch") and 5 ("wait for all leaf requirements, then dispatch dependent requirements") are the prose form of the MUST/Cannot table immediately below (204-208). Collapse to one step. -2 |
| 178 | "See the [Component Template](../templates/component.template.yml) for the full schema." | Template already declared in `bundle_templates`. -1 |
| — | C1: 8 excess rules | -16 |

Non-line-saving trims: line 118's "This is the mandatory implementation discipline — not optional."
adds nothing to the pseudocode that follows; line 96's "— ask one question" restates the bold lead
"**One question at a time.**" verbatim (the same tic appears in `adr-agent:54` and
`change-agent:52`).

**Load-bearing, keep:** the Build Target: docker block; the full TDD inner-loop pseudocode with its
RED/GREEN confirmations; the escalation fence; the library-standards pre-scaffold sequence; the
sub-agent model-tier rule; the framework `component.yml` close-out.

---

## planifest-design-critic

**Current:** 71 · **Target:** 69 (-2)

Effectively exhausted. Already one rule, table-driven throughout, rubric and verdict template both
load-bearing.

| Lines | Item | Rationale |
|---|---|---|
| 67 | "In **report-only** mode the verdict is presented alongside the artifacts and blocks nothing. In **on** mode, REJECT returns the artifacts for revision per the loop." | Restates the toggle semantics that `planifest-loop-runner` owns (loop-runner:30-31), and line 21 already delegates loop mechanics to that skill. -2 |

**Load-bearing, keep:** everything else — the fresh-context contract with its refuse-on-violation
rule, the mechanical-check-first ordering, the 8-item REJECT-default rubric, the verdict fence.

---

## planifest-docs-agent

**Current:** 190 · **Target:** 163 (-27)

| Lines | Item | Rationale |
|---|---|---|
| 166-170 | C2 telemetry double pointer | -2 |
| 98-105 | `### System-wide artifacts` table | **Within-file duplication the first pass missed.** This table lists Component Registry → `docs/component-registry.md` and Dependency Graph → `docs/dependency-graph.md`. The "Mandatory living docs" table at 26-32 lists both files at the same paths, plus three more. The later table is a strict subset. Delete it and cross-reference the earlier one. -8 |
| 150-152 | `## Capability Skills` | One sentence under its own header. Fold into `## Rules`. -3 |
| — | C1: 7 excess rules | -14 |

**Load-bearing, keep:** the P6 Gate A/B sequence with its failure string and confirmation prompt; the
per-component artifact table; the six-row drift-detection table; the legitimate-absences list (it
prevents false-positive drift flags, which is not the same rule as line 119's produce-or-note-it);
the three living-doc template paths at 37-39, which are *not* in `bundle_templates` and so are the
only pointer to them.

Observation, not a cut: the "**Recommendations.**" bullet at line 146 belongs to `## Rules` but sits
below the `### Drift Detection` subheader, so it reads as a drift check. Moving it up costs nothing.

---

## planifest-implementer

**Current:** 62 · **Target:** 46 (-16)

| Lines | Item | Rationale |
|---|---|---|
| 55-62 | `## What You Do NOT Do` | The negative-restatement section flagged in the brief — still present, now down to a single bullet ("Do not run the full test suite — run only the current requirement's test"). The bullet itself is load-bearing and not stated anywhere else in the file, but it costs a header, four blank lines and two rules to carry one line. Relocate it verbatim as Hard Limit 6 and delete the section. -4 content (its two rules counted in C1) |
| 36 | "The minimum implementation code to make the failing test pass. Written to disk. Test run. Confirmed GREEN." | Third statement of the same sequence in one file: Hard Limits 1 and 4 state it, Process steps 1-3 state it, the blockquote intro states it. The two bullets below (38-41) are load-bearing and stay. -2 |
| — | C1: 5 excess rules | -10 |

**Load-bearing, keep:** all five Hard Limits; the `GREEN ✓` confirmation fence with exit code and
file list; the 3-fix-attempt escalation cap; the domain-glossary input.

---

## planifest-loop-runner

**Current:** 93 · **Target:** 80 (-13)

| Lines | Item | Rationale |
|---|---|---|
| 80 | "The escalation carries **full context in the state file** — a human or a fresh session must need nothing from the dead conversation." | WHY-explanation for the rule stated one line earlier (73: "populate the state file's Escalation Context section (stop rule hit, outstanding finding, attempts summary, recommended next step)"), which already enumerates exactly what full context means. -2 |
| 93 | "Emission is async and non-blocking — a telemetry failure is logged once and never stops a loop." | Restates the emission-gate protocol in `telemetry-standards.md`, which line 86 already delegates to. -2 |
| 32 | "With every toggle off, pipeline behaviour is identical to a pipeline without loop support — zero-config regression guarantee." | A design guarantee about the framework, not an instruction to the agent; the toggle rules at 29-31 are complete without it. -1 |
| — | C1: 4 excess rules | -8 |

**Load-bearing, keep:** all four Hard Limits, in particular the full `.ratchet-approve` protocol at
line 19 (path/reason/timestamp format, the pipe-character failure mode, the dedicated-commit
requirement, the ADR supersession) — every clause there is hook-enforced or hook-adjacent; the
iteration-cycle pseudocode; the four-row stop-rule table with its cap values; the escalation fence.

---

## planifest-refactor

**Current:** 67 · **Target:** 55 (-12)

| Lines | Item | Rationale |
|---|---|---|
| 60-67 | `## What You Do NOT Do` | Same as implementer: one load-bearing bullet ("Do not refactor code in other components") carried by a header, four blanks and two rules. Relocate as Hard Limit 6. -2 content (rules in C1) |
| 36 | "Improved implementation code. No new files unless splitting an existing file. Full test suite runs green." | "Full test suite runs green" is the third statement of Hard Limit 3 and Process step 4. Trim the sentence to the file-creation constraint only. -0 lines, but removes the third restatement |
| — | C1: 5 excess rules | -10 |

**Load-bearing, keep:** all five Hard Limits, especially 4 (test-is-the-contract escalation); the
`REFACTOR ✓` fence; the in-scope / out-of-scope quality lists at 38-40; the revert-and-retry rule.

---

## planifest-refresh-setup

**Current:** 159 · **Target:** 130 (-29)

| Lines | Item | Rationale |
|---|---|---|
| 153-159 | `## What This Skill Never Does` | **Textbook negative-restatement section, all three bullets verbatim duplicates.** "Never deletes any file other than `CLAUDE.md`/`AGENTS.md`" = line 122. "Never proceeds past Step 4 without an explicit human affirmative, regardless of confidence" = lines 88 + 95. "Never invents a flag not already supported by setup.sh/setup.ps1" = line 10 intro + line 22. Delete the section entirely. -6 (incl. its rule) |
| 12-17 | `## When You Run` | Third statement of the same fact. The frontmatter `description` says "Invoke on request"; `hooks: phase: standalone` says it; line 10 says "You are a standalone skill, invoked on request, not part of the P0-P9 pipeline." The only marginal addition — no `design.md` or phase gate required — folds into line 10. -5 |
| — | C1: 9 excess rules (the highest count in the corpus) | -18 |

Non-line-saving trims: line 122's middle sentences ("The script hardcodes the exact allowlist in
code, not in this skill's prose. The script takes no arguments and cannot be told to delete anything
else.") are WHY for the rule at line 120; line 114's second sentence is WHY for the rule at line 101;
line 49's parenthetical restates Step 1.4.

**Load-bearing, keep:** the nine-row tool-signal table; the flag-inference table with its confidence
column; every step's REQ/ADR anchor; Step 1a's exact report string; Step 4's no-bypass confirmation;
the Step 5 marker JSON; Step 6's script-only deletion rule and its `settings.local.json` prohibition;
Step 8's failure-report checklist.

---

## planifest-reversal-assessor

**Current:** 67 · **Target:** 67 (0)

**No further safe reduction found.** Already at the one-rule convention, table-driven, and every
paragraph is either the invocation contract, a rubric item with its grant condition, or the verdict
template. The one internal echo — line 21's "You never revise artifacts, never re-run phases."
restating "You judge; the **orchestrator** executes." — is a sentence fragment on a shared line, not a
line to remove, and the negative form is the operative one for an agent.

---

## planifest-scope-lock-agent

**Current:** 51 · **Target:** 47 (-4)

| Lines | Item | Rationale |
|---|---|---|
| 45-47 | `## What you must never do` | A single-bullet negative-restatement section, and the bullet duplicates drafting rule 4 (line 30: "state it explicitly alongside the draft — never smooth it over or resolve it yourself"). The section's own bullet adds only the WHY ("surfacing the flag is the point"), which can ride on rule 4. -4 |

Optional, flagged not recommended: `## Telemetry` (49-51) exists to say nothing is emitted. Removing
it would save 4 more lines, but the explicit no-op arguably prevents an agent inventing an event
type, and the second sentence anchors where the durable record actually lives.

**Load-bearing, keep:** the five-row drafting-rules table (rule 5's no-implicit-confirmation clause
in particular); the invocation contract's one-item-at-a-time and never-pre-emptively constraints;
the output fence.

---

## planifest-security-agent

**Current:** 126 · **Target:** 109 (-17)

| Lines | Item | Rationale |
|---|---|---|
| 101-105 | C2 telemetry double pointer | -2 |
| 84 | "**Be specific.** Every finding must reference a specific file, endpoint, or configuration." | Verbatim duplicate of the blockquote intro at line 12 ("Every finding references a specific file, endpoint, or configuration. Generic security advice is not acceptable."). The SQL-injection example that follows is illustrative of a rule already fully stated. Keep one statement, drop the example. -1 |
| 28-32 | `## What You Produce` (one line: the report path) | Merge into the `## Report Structure` header line. -3 |
| 20-21 | Input bullets 1 and 2 | Both point at `src/{component-id}/`; mergeable to one bullet naming implementation and IaC. -1 |
| — | C1: 5 excess rules | -10 |

Conditional, **not** counted in the target: the six one-sentence report subsections inside the
template fence (45-67 — Dependency Audit, Secrets Management, Auth Review, Input Validation, Network
Policy, IaC Review) are 24 lines carrying six sentences and convert cleanly to a `Section | What to
flag` table for a further ~10. Do this **only** if the produced report's shape is allowed to change
— the fence is the literal output format, so converting it changes every security report the
framework emits.

**Load-bearing, keep:** the STRIDE table skeleton; the conservative-rating and
cross-reference-the-risk-register rules; the critical/high PR-gate flag; all four event shapes; the
Parallelism Directive table.

---

## planifest-ship-agent

**Current:** 283 · **Target:** 259 (-24)

The largest file in scope and the least reducible by proportion — it is mostly ordered procedure and
literal output fences, both load-bearing. Step 8/9 numbering untouched throughout.

| Lines | Item | Rationale |
|---|---|---|
| 36-42 | `## Input` | Two bullets, both restated at their point of use: "All artifacts at `plan/current/`" is the subject of the entire P7 sequence, and "`.skips` file at `plan/current/.skips` (if any)" is restated at line 78 ("If `plan/current/.skips` exists"). The section adds nothing the steps do not. -6 |
| 158 | "The build-assessment-agent reads `build-log.md` from the archive and writes `build-report.md` to the same directory" | Verbatim restatement of the prompt string three lines above (155: "Read build-log.md from the archive and write build-report.md to the same directory"). -2 |
| 185 | "Confirm the tag was created locally." | Duplicated by the Step 10 prompt fence at line 196 ("Git tag v{version} created locally."), which the agent emits immediately after. -2 |
| 86 | "This marker enables resume detection to identify stale artifacts from a failed archive." | WHY for the one-line WHAT at 84. -2 |
| — | C1: 6 excess rules | -12 |

**Load-bearing, keep:** the `## Prefix` step-range mapping (P7 Steps 1-7 / P8 Step 8 / P9 Steps 9-12
— the renumbering that must not be touched); all five Hard Limits; every fenced output block
(changelog, `gh pr create`, PR description template, Step 11 confirmation, Step 12 advisory); the
copy-then-delete sequence with its seven deletions; the Step 9 version-derivation cases with their
exit codes and the validation regex; the Step 10 `local-git-only` override check; Step 6b's blocking
declaration.

Correctness observations, not cuts:
- Line 121's cross-reference check is filed under `### Step 6` but instructs "before Step 1, not
  after Step 6" — an agent reading top-down reaches it 70 lines after the point it applies.
- Line 144 states "Append a P8 phase block to `plan/current/build-log.md`" and then negates itself in
  the same line ("at this point `plan/current/` has been archived ... The original
  `plan/current/build-log.md` no longer exists"). It should simply name the archive path.
- Line 246 emits "Git tag: v{version} (push with: `git push origin --tags`)" unconditionally, but
  under Option [1] the tags were already pushed at line 206.

---

## planifest-spec-agent

**Current:** 124 · **Target:** 105 (-19)

| Lines | Item | Rationale |
|---|---|---|
| 115-119 | C2 telemetry double pointer | -2 |
| 99-103 | `## Retrofit Mode` | Three lines under their own header that mostly delegate ("follow the orchestrator's Adoption Modes → Retrofit scan"), and line 64 already carries the retrofit-specific instruction this agent actually owns (read the existing codebase for terms in use). Fold the remaining sentence into `## Rules`. -3 |
| 76 | "Populate the `purpose`, `scope`, `risk`, and `contract` sections based on the requirements you produce. The `stack` section is pre-seeded - do not modify it." | **Within-file duplication:** the Component Manifest row of the What You Produce table (line 33) already says "The `stack` section will already be pre-seeded by the human or orchestrator; populate `purpose`, `scope`, `risk`, and `contract` based on your requirements set". Keep one; fold the "do not modify it" clause into the survivor. -1 |
| 94-95 | "Carry forward the domain glossary" + "Carry forward the risk register" | Two bullets stating the same cumulative-carry-forward rule for two artifacts. Merge to one bullet naming both. -1 |
| — | C1: 6 excess rules | -12 |

Non-line-saving trims: line 89's parenthetical explains that waves were "formerly called 'phases',
renamed to avoid collision with the P0–P9 pipeline phases" — the distinction is load-bearing, the
rename history is not; line 75 is the third statement of the manifest path (after line 26 and the
table's path column); line 59's "No more, no less." restates the preceding sentence.

**Load-bearing, keep:** the 10-row artifact/path/purpose table; the OpenAPI **CRITICAL CONDITION**;
the write-as-you-go / do-not-accumulate rule; the assumptions boundary (documented-minor vs
report-back-material); `notResponsibleFor` mandatory; leave `contract.consumedBy` empty; the
Parallelism Directive table.

---

## planifest-test-writer

**Current:** 74 · **Target:** 57 (-17)

| Lines | Item | Rationale |
|---|---|---|
| 67-74 | `## What You Do NOT Do` | Same pattern as implementer and refactor: one load-bearing bullet ("Do not run the full test suite — run only this one test") behind a header, four blanks and two rules. Relocate as Hard Limit 5. -3 content (rules in C1) |
| 34 | "One test file. Written to disk. Run. Confirmed RED." | Third statement of the same sequence in one file: the blockquote intro at line 11 ("You write one failing test, run it, confirm it fails, and stop"), Hard Limit 3, and Process steps 1-3 all state it. The four bullets below (37-40) are load-bearing and stay. -2 |
| — | C1: 6 excess rules | -12 |

**Load-bearing, keep:** all four Hard Limits; the `RED ✓` fence; the test-file naming and
req-ID-in-description conventions; the `# REGRESSION-CANDIDATE:` tag format (hook/script-adjacent —
ship-agent scans for this exact string).

Correctness observation, not a cut: line 66 says the ship-agent presents tagged tests "at Step R".
There is no Step R in `planifest-ship-agent`; regression confirmation is **Step 4** (ship-agent
88-99). Stale cross-reference.

---

## planifest-validate-agent

**Current:** 140 · **Target:** 126 (-14)

| Lines | Item | Rationale |
|---|---|---|
| 121-125 | C2 telemetry double pointer | -2 |
| 109 / 113-114 / 117 | Parallelism Directive dependency chain | The merged section (not reverted) still states one dependency chain three times. Prose at 109: "lint and typecheck are always independent of each other; tests depend on typecheck passing (type errors cause spurious test failures); build depends on tests passing." Table rows at 113-114 restate it including the identical parenthetical "(type errors cause spurious test failures)". Dispatch order at 117 restates it a third time as batches. Reduce the prose at 109 to its unique instruction (batch independent checks in one message; state the dependency reason for anything run serially) and keep the table + dispatch order. -2 |
| — | C1: 5 excess rules | -10 |

Non-line-saving trims: line 63's "and your halt/escalate behaviour is unchanged" is a no-op
reassurance; line 92's second sentence restates its first; line 99's "Do not suppress linting rules,
skip failing tests" restates the intro at line 12.

**Load-bearing, keep:** the Build Target: docker block; the strict 0-6 check order including the
library audit paths and the semantic-correctness AC-coverage rules; the cap-of-5 with its explicit
override of loop-runner's default 3; both fenced formats (cycle tracking, `VALIDATION BLOCKED`); the
do-not-widen-scope rule with its docs-agent handoff; the verify-by-execution toggle wiring.

---

## planifest-verify-by-execution

**Current:** 58 · **Target:** 58 (0)

**No further safe reduction found.** Already at the one-rule convention and almost entirely two
tables plus a report fence. The one internal echo — the blockquote intro's "Tests passing proves the
tests pass" and "The One Rule" at line 18 — is the intro/rule pairing used consistently across the
corpus, and the line-18 form is the enforceable one; removing either loses the framing or the rule.

The prod-systems prohibition at line 32, the `not-verifiable` outcome semantics, and the
method-selection table are all load-bearing.

---

## Summary table

| File | Current | Target | Cut | of which C1 rules |
|---|---:|---:|---:|---:|
| planifest-ship-agent | 283 | 259 | -24 | 12 |
| planifest-codegen-agent | 238 | 207 | -31 | 16 |
| planifest-docs-agent | 190 | 163 | -27 | 14 |
| planifest-change-agent | 171 | 156 | -15 | 10 |
| planifest-refresh-setup | 159 | 130 | -29 | 18 |
| planifest-build-assessment-agent | 151 | 127 | -24 | 16 |
| planifest-validate-agent | 140 | 126 | -14 | 10 |
| planifest-security-agent | 126 | 109 | -17 | 10 |
| planifest-spec-agent | 124 | 105 | -19 | 12 |
| planifest-loop-runner | 93 | 80 | -13 | 8 |
| planifest-adr-agent | 82 | 61 | -21 | 12 |
| planifest-test-writer | 74 | 57 | -17 | 12 |
| planifest-design-critic | 71 | 69 | -2 | 0 |
| planifest-reversal-assessor | 67 | 67 | 0 | 0 |
| planifest-refactor | 67 | 55 | -12 | 10 |
| planifest-implementer | 62 | 46 | -16 | 10 |
| planifest-verify-by-execution | 58 | 58 | 0 | 0 |
| planifest-scope-lock-agent | 51 | 47 | -4 | 0 |
| **Total** | **2207** | **1922** | **-285** | **170** |

No Hard Limit, STOP gate, confirmation token (`RED ✓`, `GREEN ✓`, `REFACTOR ✓`, `P8: Complete`,
`P9: Ship complete`, `VALIDATION BLOCKED`, `TDD LOOP BLOCKED`, `# REGRESSION-CANDIDATE:`,
`.ratchet-approve`), or hook-referenced string appears in any recommendation above. No new files, no
splits, no additions.
