# Audit Findings - planifest-orchestrator SKILL.md (Round 2)

Second fresh-context audit of `planifest-framework/skills/planifest-orchestrator/SKILL.md`, read in full as it stands after the round 1 trim. No round 1 finding is repeated here; every item below is newly identified.

**Current line count:** 1,030 (was 1,195 before round 1; 13.8% already removed)
**Recommended target:** 935 lines (9.2% further reduction, ~95 lines)
**Cumulative against original:** 1,195 to 935 = 21.8%
**Genuinely new items found:** 23

---

## Honest reasoning for the 935 target

Round 1 did real work. The obvious wins are gone: there is no worked walkthrough left, no dead section, no stale phase numbering, and the Phase Conventions block (593-598) is a textbook factoring of what used to be six repeated STOP/commit/build-log preambles. The file is genuinely dense now.

What remains is a different *shape* of redundancy, which is why a first pass tuned for obvious duplication would miss it:

1. **Distance-separated restatement.** The same rule is stated correctly in two or three places 200 to 600 lines apart, so neither copy looks wrong locally. The ship-agent ownership rule appears four times; the adoption-mode signal priority three times; the context-reset behaviour three times; the discovery regenerate-fresh rule three times.
2. **Concern lists enumerated three ways.** Phase 0 lists what a complete requirements set needs in three different formats (what you are assessing against, priority order, gate checklist) with only partial overlap in each direction.
3. **Prompt-template repetition.** Recommend-then-confirm is defined canonically at 295-301, then re-instanced as a full multi-line prompt block three more times.

Only two whole sections are wholesale deletable (Signal Priority Order, the `## Routing` pointer). Everything else is a 2 to 7 line cut. That is why the target is ~9% and not ~20%: I am not going to invent a bigger number when the arithmetic of the itemised list below adds to roughly 95 lines.

**Important caveat on measurement.** A meaningful share of this file's remaining bloat is *inside* long single physical lines (Hard Limit 7 at line 32, step 3d at 395, step 3c at 393, the backlog ID convention). Condensing those cuts real tokens but moves the line count by zero. Items marked **[token-only]** below are worth doing but must not be counted toward the line target.

---

## Newly identified redundant sections

### Preamble and conventions

- **NEW-1. Lines 12, 16-18 (~5 lines).** The header blockquote and the `## What You Do` section state the same thing twice: brief in, coached requirements out, pipeline executed. Merge into one, keeping the "you are the quality gate" clause which is the only non-obvious part.
- **NEW-2. Lines 44-45 (3 lines).** "This table is the complete and exhaustive list of pipeline phases. No phase exists outside it." is Hard Limit 9 restated 10 lines after Hard Limit 9. Also line 42's "it lets the human orient instantly without reading prose" is a WHY for a rule already marked non-negotiable.
- **NEW-3. Lines 95, 99 (2 lines).** Row 99 ("Begin Phase 0 | You are already reading it - this file is the orchestrator skill") carries no routing information. Line 95's "it prevents context rot and ensures your output matches the current template exactly" is justification for an instruction already marked "not optional".
- **NEW-4. Lines 143-145 (3 lines).** The blockquote under Standalone Skills restates, in prose, the "Pipeline relationship" column of the table immediately above it. Nothing in it is absent from the table.

### Pause and context hygiene

- **NEW-5. Lines 207-210, 221 (5 lines).** Step 2 says "read `pause.template.md` for the exact format" and then glosses four of its fields. Verified against the template: `phase`, `active_task`, `last_artifact` and the in-progress body are all defined there, and the template already carries "Delete this file once the interrupted task has been re-engaged" (duplicated at line 221) and the `{phase-id}: Resuming` format. Keep the pointer, drop the gloss. This is the same template-gloss pattern round 1 flagged in adr-agent.
- **NEW-6. Lines 227-231, 349, 746 (~5 lines).** The `/clear`-or-flag-to-the-human behaviour is fully specified three times: Context Hygiene, Phase 0 Start Actions step -1, and Phase 9. Worse, 231 and 746 cross-reference each other circularly, and 231 is a pointer that also restates what it points to. Specify the behaviour once (Context Hygiene is the natural owner), leave a bare pointer at step -1 and P9.

### Phase 0 coaching

- **NEW-7. Lines 275-289 (~10 lines).** `### What you are assessing against` is the third enumeration of the same concern set, alongside the priority order (303-313) and the gate checklist (549-564). The gate checklist is load-bearing (checkable, item-by-item). The priority order is load-bearing (sequencing). The three-layer prose adds only a handful of unique items (integrations, team capability, cost boundaries, deployment topology) plus the observability and API-design standards links. Fold those unique items and both links into the priority order list; drop the layer framing.
- **NEW-8. Line 271 (2 lines).** "This is where you spend most of your time with the human. The goal is a complete set of requirements, not a perfect one..." is motivational framing; its operative content ("addressed or explicitly deferred") is Hard Limit 1.
- **NEW-9. Lines 323-327, 332-335, 343 (~7 lines).** Decomposition carries three illustrative bullets (one API resource / one UI screen / one integration) that restate the deterministic rule of thumb at 328. Waves carries a historical rename note ("previously called phases in this decomposition sense") and a two-line WHY about context limits. Line 343 ("The Feature Brief Template guides the human through this before they reach you") changes no behaviour.
- **NEW-10. Lines 381-385, 406-411, 941-944 (~8 lines).** Recommend-then-confirm is defined canonically with its exact format at 295-301, and 301 explicitly scopes it to all phases. It is then re-instanced as a full multi-line prompt block for adoption mode, for version bump, and for conflict warnings. Replace each with a one-line instruction naming the decision and the alternatives; the format is already owned upstream. (The version **hard block** at 413-419 is a different rule and stays.)
- **NEW-11. Lines 442-455, 570-589, 634 (~10 lines).** Capability skills are handled in four places: the inbox check (436-438), Capability Skill Intake, Skill Discovery REQ-026, and a Phase 3 framing paragraph. Intake and Skill Discovery are the same procedure reached by two triggers (skill arrives in inbox vs. orchestrator proposes one) and share an identical two-destination install rule. Merge into one section with two trigger bullets. Line 634's "they encode craft knowledge... Planifest skills encode discipline... The two are complementary" is a WHY paragraph for a check stated in one clause.
- **NEW-12. Lines 539, 541 (3 lines).** The P0 Audit Trail closes with three sentences saying "write incrementally, not batched", plus a one-line cross-reference noting Scope Lock entries are part of the trail. One sentence covers both.

### Phases 1 to 9

- **NEW-13. Lines 641, 643 (~4 lines).** Subagent Decomposition step 4 restates the Agent Dispatch Template's self-contained-prompt rule (830) almost clause for clause, including "do not pass the full conversation history". Step 3 restates the Model Tier "How to apply" line (781). Line 643 restates step 636's own opening ("the codegen-agent and other phase agents MUST decompose"). The Agent Dispatch Template's rule is protected and stays; these are the copies.
- **NEW-14. Line 703 (2 lines).** The Cross-Model Review Gate states its ordering three times in one paragraph: in the heading "(end of P6, strictly before P7)", in "after the P6 commit and before invoking the ship-agent", and in "The ordering is structural: P7 archive begins only after this gate approves". The ADR-008 citation preserves the rejected-alternative record in one clause.
- **NEW-15. Lines 715, 721-722, 728, 730, 740, 744 (~6 lines).** "The ship-agent owns P7 to P9, you do not invoke them separately" is stated four times (715, 728, 730, 740). Line 715 states it canonically and completely. Separately, the P7 gate at 721-722 is explicitly labelled "(after P9 completes)" and lists the same five confirm items as the P9 gate at 744; one gate statement suffices, and it belongs under P9.
- **NEW-16. Lines 787, 789 (2 lines).** Within Parallelism Rules, "If you cannot state why task B must wait for task A's output, dispatch them in parallel" and the Dependency test "Can task B start before task A's output is available?" are the same test stated twice in consecutive paragraphs. Condensation only: the default-parallel posture and the test both survive intact.
- **NEW-17. Lines 818, 832 (~3 lines).** The Agent Dispatch Template's level-1 parallelism (multiple native tool calls in one message) duplicates Parallelism Rules; only the level-2 spawn-vs-inline heuristic is unique. Line 832 restates the Model Tier table's mapping for the two tiers it happens to mention, then points at the table anyway.

### Adoption modes and routing

- **NEW-18. Line 881 (2 lines).** Pure cross-reference: it points back to step 3a for detection and forward to Conflict Warnings, restating a fragment of each. Both targets are complete.
- **NEW-19. Lines 928-934 (7 lines).** `### Signal Priority Order` is a whole section restating the priority column of the step 3a table (373-378), which already carries "Apply the highest-priority signal only". It is also stated a fourth time at line 926 ("External Anchor takes priority over all other signals"). Delete the section outright. This is the single largest clean deletion left in the file.
- **NEW-20. Lines 887, 893 (3 lines).** Structured Discovery Pass restates the shared-header contents already listed inside step 3d, and its Cross-session bullet duplicates Resume Detection 6a. Since this section is the natural owner of discovery semantics, keep it and thin the copies at 87 and 395 instead (see NEW-23).
- **NEW-21. Line 920 (1 line).** "The human may need fewer questions (codebase answered them) or more (codebase reveals conflicts)" is speculative narration about coaching that changes nothing.
- **NEW-22. Lines 950-952 (4 lines).** `## Routing` is a top-level heading whose entire body is "See the Routing Directive section above". Delete the heading and the pointer, and promote `### Invoking the Change Pipeline` to a top-level section. Exactly the merge-a-thin-header case.
- **NEW-23. Lines 87, 395, 893 (~2 lines).** The "if missing or incomplete, regenerate fresh rather than patching, discovery is a read-only scan with no human dialogue to preserve" rule appears three times in near-identical wording. Keep the Adoption Modes copy (893); reduce 87 and 395 to the bare instruction without the trailing justification.

---

## Token-only condensations (do not count toward the line target)

These are inside long single physical lines. Real token savings, zero line movement.

- **[token-only] Line 32 (Hard Limit 7).** Keep every rule. Remove the two self-restating clauses: "In-progress work must never be more than one artifact away from recoverable" and "On a feature branch this is low risk and preserves design history". The rule, the per-phase commit list, and the full push cadence protocol all stay.
- **[token-only] Line 393 (Backlog ID sequence).** The WHAT (independent monotonic sequence; next = highest ever allocated plus one, including spent IDs) is three clauses. The remainder explains why collisions are expected and where to look for the high-water mark.
- **[token-only] Line 395 (step 3d).** Its closing "This is mandatory, a missing or incomplete discovery.md before coaching begins is a pipeline error (Hard Limit 11)" is Hard Limit 11 verbatim, and gate checklist item 563 already self-declares as the redundant catch. One of the three can go, and it should be this one, since 563 is checkable and 36 is the Hard Limit itself.
- **[token-only] Lines 667, 681, 697.** Each STOP carries "or if `continuous_run: true` was set at P0", which Phase Conventions line 598 already establishes for every phase. The phase-specific exception (the genuinely-nothing-to-review condition) is what each line uniquely contributes.
- **[token-only] Lines 612, 628, 653.** "No exception, requirements are always consequential" and its two siblings are justifications appended to an already-absolute "No exception".
- **[token-only] Lines 754-768 (Model Tier table Rationale column).** Thirteen rows of justification for tier assignments that are themselves the operative data. Dropping the column removes no rows. Flagged only because the table is protected and a trimmer should not touch its rows.
- **[token-only] Lines 501-505 (Scope Lock).** Each of the four questions repeats "(Want me to suggest an answer first? yes/no)", which line 500 already mandates in bold. These are literal prompt text inside protected mechanics, so the safest treatment is no change at all; noted for completeness only.

---

## Checked and explicitly rejected as cut candidates

Recording these so a later pass does not re-litigate them.

- **Lines 1006-1029 (five JSON payload snippets).** I expected these to duplicate `telemetry-standards.md`, since line 969 delegates the envelope to it. Verified by grep: `telemetry-standards.md` contains no `duration_ms`, no `avg_token_delta`, no `phase_name` payload shapes. The orchestrator is the only definition of these `data` fields. **Load-bearing. Do not cut.** (The 14-type event reference table at 983-1000 is protected by the brief and also stays.)
- **Lines 258-267 (tool detection signals).** Seven filesystem and env-var signals that are not derivable from general knowledge. Keep.
- **Lines 913-918 (Retrofit six-step scan).** Concrete procedure, not illustration. Keep.
- **Lines 549-564 (P0 to P1 Gate Checklist).** Overlaps NEW-7, but it is the checkable form and item 563 self-identifies as a deliberate redundant catch. Keep in full.
- **Line 315 (the "It should be fast" to "p95 < 200ms" example).** One line, and it calibrates the required specificity in a way the surrounding rule does not. Keep.
- **Lines 593-598 (Phase Conventions).** Already the highest-density block in the file. Keep verbatim.
- **All protected items per the audit brief:** Hard Limits, STOP gates, Resume Detection, Phase Skip Protocol, Scope Lock mechanics, Model Tier Decision Table, Parallelism Rules, Agent Dispatch self-contained-prompt rule, Governed Phase-Reversal Protocol, Telemetry event-type reference. None of the items above removes or weakens any of these.

---

## Incidental defect (not a trim item)

Lines 97, 152, 155 contain mojibake from a prior encoding round-trip: `â€¦` (should be an ellipsis), `â€“` (should be an en dash), `â‰¥` (should be the greater-than-or-equal sign). Line 155 currently reads "new user stories (â‰¥ 3)", which garbles a routing threshold. Worth fixing while the file is open.
