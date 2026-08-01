# Audit Findings — Skill Instruction Files (0000021 req-002)

Fresh-context content audit of all 21 `planifest-framework/skills/*/SKILL.md` files. Every file read in full. Findings classify content as load-bearing (keep) or redundant (candidate for removal/condensation).

## Summary Table

| File | Current lines | Target lines | Reduction |
|---|---:|---:|---:|
| planifest-adr-agent | 102 | 65 | 36% |
| planifest-build-assessment-agent | 165 | 125 | 24% |
| planifest-change-agent | 195 | 135 | 31% |
| planifest-codegen-agent | 315 | 195 | 38% |
| planifest-design-critic | 71 | 66 | 7% |
| planifest-docs-agent | 222 | 165 | 26% |
| planifest-implementer | 89 | 52 | 42% |
| planifest-loop-runner | 93 | 88 | 5% |
| planifest-migrator | 104 | 90 | 13% |
| planifest-optimise-agent | 101 | 80 | 21% |
| planifest-orchestrator | 1195 | 900 | 25% |
| planifest-refactor | 89 | 55 | 38% |
| planifest-refresh-setup | 169 | 145 | 14% |
| planifest-reversal-assessor | 69 | 64 | 7% |
| planifest-scope-lock-agent | 54 | 48 | 11% |
| planifest-security-agent | 146 | 110 | 25% |
| planifest-ship-agent | 310 | 245 | 21% |
| planifest-spec-agent | 136 | 105 | 23% |
| planifest-test-writer | 93 | 58 | 38% |
| planifest-validate-agent | 181 | 135 | 25% |
| planifest-verify-by-execution | 60 | 56 | 7% |
| **Total** | **3959** | **2982** | **24.7%** |

---

## Cross-File Duplication Register

These are the highest-leverage findings: fixing each once removes N-1 copies. Per-file sections below reference this register rather than repeating the rationale.

**DUP-1 — "Commit Cadence (Hard Limit 7)" trailing section (6 copies, ~30 lines).**
Appears as the last section of `adr-agent` (100-102), `spec-agent` (134-136), `security-agent` (144-146), `validate-agent` (179-181), `docs-agent` (220-222), `codegen-agent` (313-315). Byte-identical body. The text itself declares its own redundancy: *"the definition and per-phase examples live in the orchestrator's Hard Limit 7; this skill adds no local variation."* Remove all six. The rule survives in orchestrator Hard Limit 7 and CLAUDE.md § Commit Granularly, Continuously.

**DUP-2 — Telemetry "Emission gate (0000018, ADR-001/ADR-002)" paragraph (7 copies).**
`adr-agent` 91, `spec-agent` 125, `security-agent` 119, `validate-agent` 160, `docs-agent` 196, `change-agent` 175, `codegen-agent` 289. One physical line each but ~90 words, restating the same block-or-proceed protocol that `telemetry-standards.md` owns and the orchestrator states canonically at 1134-1144. Replace each with a one-clause pointer. Low line saving, high token saving.

**DUP-3 — "One question at a time" elaboration (9 copies).**
`adr-agent` 64, `spec-agent` 46, `security-agent` 91, `validate-agent` 104, `change-agent` 60, `codegen-agent` 113, `docs-agent` 78, `ship-agent` 33 (as HL5), `orchestrator` 320/328/1115. Each expands the rule into the same three clauses ("wait for the answer, then continue / lead with a recommendation / never present a list"). Orchestrator line 328 already states the scope explicitly: *"This pattern applies across all pipeline phases (P0–P9)... Any phase skill that needs a decision from the human should recommend first."* Keep the bare rule where a skill genuinely gates on it; delete the three-clause expansion everywhere except the orchestrator.

**DUP-4 — "Model Tier Rationale" section (3 copies, 15 lines).**
`implementer` 15-19, `refactor` 15-19, `test-writer` 15-19. Each is a five-line prose justification for the `recommended_model: haiku` value already present in the same file's frontmatter. Nothing in it changes behaviour. Remove all three.

**DUP-5 — "Parallelism Directive" boilerplate (6 copies).**
`adr-agent` 74-83, `spec-agent` 107-117, `security-agent` 101-111, `validate-agent` 142-152, `docs-agent` 178-188, `codegen-agent` 224-236. Identical skeleton: one framing sentence + the dependency test + a two-column MUST/Cannot table + an "In practice" line. The dependency test is stated canonically in orchestrator 885-912. Keep only the per-skill table rows that name genuinely skill-specific dependencies; drop the framing prose and the "In practice" restatement in all six.

**DUP-6 — "Context-Mode Protocol" blockquote (6 copies).**
`security-agent` 18, `validate-agent` 39, `change-agent` 29, `docs-agent` 147, `codegen-agent` 32, `orchestrator` 1063. CLAUDE.md already carries the standing directive ("Use context-mode MCP when available") with the same tool-selection guidance. Condense each to a single clause or drop.

**DUP-7 — Verbose worked `Agent()` dispatch examples (2 copies, ~75 lines).**
`orchestrator` 930-974 (45 lines, two fully-written prompts from feature 0000010) and `codegen-agent` 250-279 (30 lines, three `Agent()` calls). They teach the same thing. One ~10-line skeleton in the orchestrator suffices.

**DUP-8 — Test-runner command block (2 copies).**
`test-writer` 57-62 and `implementer` 59-64. Both list bash/node/vitest invocations then close with "whatever the declared stack test runner is" — which makes the preceding three lines decorative.

**DUP-9 — "What You Do NOT Do" lists that restate the same file's Hard Limits (3 copies).**
`implementer` 81-88, `refactor` 81-88, `test-writer` 85-92. In each case 4 of 5 bullets are the negative restatement of a Hard Limit stated 60 lines earlier in the same file.

**DUP-10 — Copy-then-delete archive sequence + cross-reference check (2 copies).**
`ship-agent` 110-124 and `change-agent` 111-125. Near-identical seven-step sequence plus the same cross-reference warning, each carrying its own war-story anecdote. Both call sites need the sequence (different pipelines), so keep both — but the anecdotes and the self-evident confirm steps are trimmable in both.

**NOT a duplication candidate:** "Credentials are never in your context" appears as a Hard Limit in `implementer`, `refactor`, `test-writer`, `migrator`, `build-assessment-agent`, `ship-agent`, and `orchestrator`. It is duplicated, and CLAUDE.md Hard Limit 6 covers it globally — but it is a Hard Limit in every one of those files and these are fresh-context subagents. Flagged here only so the trimming agent does not mistake it for an oversight. **Do not remove.**

---

## planifest-framework/skills/planifest-adr-agent/SKILL.md

**Current line count:** 102
**Recommended target:** 65 (36% reduction)

### Redundant sections (candidates for removal/condensation)
- Line 12: header quote's trailing clause "so future humans and agents understand not just what was decided, but why" — generic explanation of what an ADR is for.
- Lines 42-45: "A decision does not require an ADR if" — three bullets that are the logical inverse of the criteria table directly above. Only the third (already-a-requirement case) is non-obvious; condense to one line.
- Lines 49-58: "ADR Format — Follow the ADR Template. Key sections:" followed by six bullets naming and glossing each template section. The Framework Index mandates JIT-reading `adr.template.md` before writing an ADR; restating its section names here duplicates the template and risks drift. Keep the template reference, drop the gloss.
- Line 64: DUP-3.
- Line 65: "Be specific. Vague ADRs are useless. 'We chose PostgreSQL' is not an ADR..." — a worked example for a rule the model applies unprompted.
- Line 66: second sentence "Every decision has trade-offs" — restates the sentence before it.
- Lines 74-83: DUP-5.
- Line 91: DUP-2.
- Lines 100-102: DUP-1.

### Load-bearing content confirmed present (do not touch)
- The "What Requires an ADR" criteria table (31-40) — six framework-specific triggers including the mandatory data-ownership ADR.
- Output path convention `plan/current/adr/ADR-{NNN}-{title}.md` (25) and sequential numbering from ADR-001 (68).
- Superseded-ADR marking protocol for change-pipeline runs (69).
- "Write each ADR to disk as you complete it. Do not hold them all in memory." (70).
- `adr_decision` telemetry event shape (93-96).

---

## planifest-framework/skills/planifest-build-assessment-agent/SKILL.md

**Current line count:** 165
**Recommended target:** 125 (24% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 104-109: the "Efficiency Observations" bullets inside the report template ask the same four questions the Critical Audit section (118-142) asks in detail. One or the other, not both — keep the Critical Audit (it carries the non-obvious thresholds), drop the template bullets to a bare heading.
- Lines 58-60, 66, 75-76, 82-83, 99-100: placeholder filler rows (`| ... | ... | ... |`) inside the report skeleton. One example row per table conveys the shape.
- Line 116: "The Efficiency Observations section is not a summary — it is an adversarial review. Ask the questions a technically rigorous human reviewer would ask" — framing prose; the rubric that follows already enforces it.
- Line 149: the "Parallelism was underused" vs. the eight-clause counter-example — the be-specific rule holds without the full worked example.
- Lines 162-163: "The caller (ship-agent) receives this confirmation and continues its sequence." — explains the caller's behaviour to the callee, which cannot act on it.

### Load-bearing content confirmed present (do not touch)
- `P8:` response prefix requirement (17-18) — cross-referenced by the orchestrator's Response Prefix Convention table.
- Hard Limit 1 (read-only, modifies nothing) and Hard Limit 2 (credentials) (24-25).
- Input/output paths: reads `plan/_archive/{feature-id}-{date}/build-log.md`, writes `build-report.md` to the same directory (31-38).
- The report skeleton's section set — build-assessment output is consumed downstream by human review; section names are the contract.
- "If cheaper tier usage is zero or near-zero: flag it explicitly" (121) and "not evidenced — treat as not applied" default (150) — specific, non-inferable audit thresholds.
- `P8: Complete — build-report.md filed to {archive-path}` confirmation string (160) — the ship-agent waits on this exact token.

---

## planifest-framework/skills/planifest-change-agent/SKILL.md

**Current line count:** 195
**Recommended target:** 135 (31% reduction)

### Redundant sections (candidates for removal/condensation)
- Line 29: DUP-6.
- Lines 44-51: the coupling taxonomy (API consumer / data reader / event subscriber / shared type consumer) and impact levels (direct / indirect / none) — standard dependency-analysis vocabulary the model produces unprompted. The load-bearing part is line 52 ("only Direct impact requires contract test updates"); the taxonomy above it can shrink to a clause.
- Line 60: DUP-3.
- Line 61: "Scope creep is a process violation" — restates the clause before it.
- Lines 89-91: rollback items 2-3 are generic rollback-documentation advice. Item 1 (rollbacks are human-initiated, never automatic) is the actual constraint.
- Line 109: the archive rationale paragraph — five clauses explaining *why* an unarchived `plan/current/` is bad. Orchestrator Hard Limit 10 owns this rule; the change-agent needs the instruction, not the argument.
- Lines 116, 118: "Confirm the copy is complete before proceeding" / "Confirm the original location is empty" — self-evident steps inside a numbered sequence (DUP-10 note: keep the sequence, trim these).
- Line 123: the cross-reference-check rationale sentence ("A moved folder with stale incoming links is worse than an unarchived one — it silently breaks navigation instead of just being inconsistently placed").
- Line 125: "This applies to Feature Pipeline archiving too (ship-agent P7 Step 6) — see the companion change to that skill." — a maintenance note about a past edit, not an instruction to this agent.
- Lines 131-138: New Component Handoff steps 1-5 restate artifact paths already owned by spec-agent and docs-agent; condense to a pointer plus the two non-obvious rules (build inline, don't hand off; escalate if >3 stories).
- Lines 165-167: Capability Skills paragraph — generic "load a skill if one is relevant" advice, duplicated in codegen-agent 45-58, validate-agent 118-120, docs-agent 172-174.
- Line 175: DUP-2.

### Load-bearing content confirmed present (do not touch)
- **Migration proposal STOP gate** (68): schema changes → write `src/{component-id}/docs/migrations/proposed-{description}.md` and stop for human approval. This is CLAUDE.md Hard Limits 3 and 4.
- Precision Reading Protocol read-order with specific paths (31-38).
- Phase 6 Archive copy-then-delete sequence, "never use atomic move", `.orchestrator-active` deleted last (111-119) — deletion ordering is failure-recovery-critical.
- ADR invalidation protocol (83-86).
- Documentation update checklist with `component.yml` version-bump semantics (97-105).
- Change Summary output header schema (150-161).
- All four telemetry event shapes (177-195), notably `migration_proposal`.

---

## planifest-framework/skills/planifest-codegen-agent/SKILL.md

**Current line count:** 315
**Recommended target:** 195 (38% reduction)

This is the second-largest file and carries the densest redundancy after the orchestrator.

### Redundant sections (candidates for removal/condensation)
- Line 30: "This wastes context tokens." — explains the rule stated in the same line.
- Line 32: DUP-6.
- Lines 45-58: Capability Skills section — the four-row example table is illustrative only (and one row is explicitly speculative: "relevant for future roadmap items"). Line 58's "If a relevant capability skill exists, load it. If not, proceed with your own knowledge." is the whole instruction. Condense 14 → 3.
- Lines 76-91: Multi-Component Sequencing — five numbered steps describing standard dependency-ordered builds (shared packages → data owners → consumers). The load-bearing parts are the circular-dependency halt (86) and the between-component verification list (88-91). Condense 16 → 7.
- Line 113: DUP-3.
- Lines 119-121: stack pitfall bullets (missing `await`, `any` escape hatch, `useEffect` deps, stale closures, "AI slop") — a current-generation model's own known failure modes, listed generically. The Stack Summary link (119) carries the real signal.
- Line 124: "Software engineering is inherently discovery-driven." — preamble to the escalation protocol; the two numbered options are what matters.
- Lines 130-131: the Order/purchase glossary example — a worked example for a rule stated fully in the line above.
- Lines 179-184: Code quality bullets. "Keep functions short and single-purpose", "Read existing code patterns before generating new code", "a senior engineer should approve this in a PR review" — generic craft advice, and the section already delegates to `code-quality-standards.md` in its first line. Condense 6 → 2.
- Lines 191-193, 195: "Every endpoint must have an integration test / every pure function a unit test / run tests iteratively" — implied by the TDD Inner Loop Protocol above and by testing-standards.md.
- Lines 198-200: Infrastructure — two generic lines ("IaC must be parameterised", "Dockerfiles must be multi-stage") already covered by the Build Target: docker section at 16-24.
- Lines 224-236: DUP-5.
- Lines 239-281: **Parallel Dispatch Checklist (43 lines)** — the single largest condensation opportunity in this file. Steps 1-6 restate the Parallelism Directive immediately above it, which in turn restates orchestrator 885-912. Lines 250-279 are a 30-line worked example (DUP-7) duplicating the orchestrator's own. Merge the Directive and the Checklist into ~10 lines; drop the worked example entirely.
- Line 289: DUP-2.
- Lines 313-315: DUP-1.

### Load-bearing content confirmed present (do not touch)
- **Build Target: docker** block (16-24) — the "never check host runtimes / never fail because a runtime is absent" rules are non-inferable and referenced by `build-target-standards.md` and validate-agent.
- **Data contract STOP gate** (134): "write a migration proposal ... and stop. Do not modify the schema directly. This is a hard limit." (CLAUDE.md Hard Limits 3/4.)
- **TDD Inner Loop Protocol** pseudocode (136-156) — the mandatory test-writer → implementer → refactor sequence and the 3-attempt escalation cap. Cross-referenced by all three sub-agent skills.
- Escalation format block (160-175) — the exact output the human sees on TDD block.
- Library Standards Pre-Scaffold Check (95-107) — specific override/fallback path precedence and the stub-detection rule.
- Requirement traceability rule (190): req-ID must appear in the test description. validate-agent step 1 checks exactly this.
- Component manifest close-out list (202-209) and the **Framework component.yml close-out** (211-216) — the minor-version bump the ship-agent reads at P9 tag time.
- Quirks/tech-debt write-through to `component.yml` arrays (218-220).
- All four telemetry event shapes (291-309).

---

## planifest-framework/skills/planifest-design-critic/SKILL.md

**Current line count:** 71
**Recommended target:** 66 (7% reduction) — near-minimal reduction available; this file is already dense

### Redundant sections (candidates for removal/condensation)
- Line 13: header quote's middle clause "you were spawned fresh, with no memory of how these artifacts were written, and that ignorance is your value — you have none of the author's rationalizations" — rhetorical amplification of "You are a checker, not a maker (ADR-006)".
- Line 67: "it exists to measure your precision on real features before you are trusted with blocking power" — WHY-prose about the toggle's rollout strategy; the operative rule (report-only blocks nothing) is in the same sentence.

### Load-bearing content confirmed present (do not touch)
- Invocation Contract (19-21), including the contract-violation refusal on finding authoring context in the prompt.
- **Mechanical layer first**: `node planifest-framework/scripts/consistency-check.mjs plan/current`, non-zero exit = automatic REJECT, no rubric override (27-31).
- REJECT-default rule: "An item without cited positive evidence FAILS. Absence of objection is not approval." (35).
- The eight-item rubric table (37-46) — each row is a specific, non-generic acceptance test.
- Verdict artifact path `plan/current/critic-verdict-{iteration}.md` and its schema (50-65).
- Loop mechanics delegation to `planifest-loop-runner` with cap 3 / no-progress halt at 2 (21).
- `loop_iteration` telemetry with loop_id `design_critic` (71).

---

## planifest-framework/skills/planifest-docs-agent/SKILL.md

**Current line count:** 222
**Recommended target:** 165 (26% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 18-19: the prose sentence introducing the layer table restates what the table itself says; the same distinction is restated a third time in orchestrator line 784. Keep the table, drop the lead-in.
- Lines 55-59: Gate A's five-line failure message block for "docs/ does not exist" — a one-line failure instruction plus the `P6:` prefix would do.
- Lines 117-131: Feature-level completeness — eleven bullets each ending "(from spec-agent)" / "(from adr-agent)" / "(from security-agent)". The provenance annotations add nothing to a completeness check. Condense to a compact inline list.
- Line 78: DUP-3.
- Line 147: DUP-6.
- Lines 172-174: Capability Skills — generic (same text pattern as change-agent 165-167, validate-agent 118-120).
- Lines 178-188: DUP-5.
- Line 196: DUP-2.
- Lines 220-222: DUP-1.

### Load-bearing content confirmed present (do not touch)
- **P6 Gate A** (49-61): `docs/` absent = immediate fail, blocks all docs work.
- **P6 Gate B** (63-78): human confirmation required before docs work; decision recorded in the P6 build log block.
- Living-docs table with per-doc conditions and the `Last updated: {feature-id}` header requirement (28-36).
- "Update, do not recreate. Destroying historical context is a defect." (26).
- Per-component artifact table — the nine specific filenames under `src/{component-id}/docs/` (96-106).
- Drift Detection table (151-158) — six specific source-of-truth/verify-against pairs.
- Legitimate absences list (160-166) and "Do not flag legitimate absences as drift."
- "Flag any drift you find - do not silently fix it." (143).
- Audit trail path `plan/changelog/{feature-id}-<YYYY-MM-DD>.md` (135).
- All four telemetry event shapes (198-216).

---

## planifest-framework/skills/planifest-implementer/SKILL.md

**Current line count:** 89
**Recommended target:** 52 (42% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 15-19: DUP-4 (Model Tier Rationale).
- Lines 44-48: "Implementation code: is placed in the correct source location / uses domain glossary terms / does not duplicate logic / does not introduce imports not in the stack declaration" — bullets 2 and 3 restate Input line 36 and Hard Limit 1 respectively.
- Lines 54-56: Process steps 1-3 ("Read the failing test file. Understand exactly what it expects." / "Read the requirement file." / "Load the stack capability skill") — restate the Input section verbatim as imperatives.
- Lines 59-64: DUP-8 (test-runner command block).
- Lines 75-77: "Minimum Code Principle" — a three-line definition of "minimum" for a rule already stated as Hard Limit 1 and in the header quote. The model applies the removal test without being taught it.
- Lines 81-88: DUP-9. Bullet 2 restates HL2, bullet 3 restates HL3, bullet 4 restates the role boundary in the header quote, bullet 5 restates the invocation contract. Only "do not run the full test suite — run only the current requirement's test" adds a constraint (and it appears nowhere else).

### Load-bearing content confirmed present (do not touch)
- Hard Limits 1-5 (23-27), including "The test MUST exit zero (GREEN)" and the credentials limit.
- **3-attempt fix cap before escalating to the codegen-agent** (65) — pairs with codegen-agent's TDD loop cap.
- The `GREEN ✓` report format (67-71) — codegen-agent waits on this confirmation token.
- Domain glossary path and the use-its-terms-for-all-identifiers rule (36).
- Source-location conventions `src/{component-id}/`, `planifest-framework/scripts/` (45).

---

## planifest-framework/skills/planifest-loop-runner/SKILL.md

**Current line count:** 93
**Recommended target:** 88 (5% reduction) — no meaningful reduction available; this file is dense and almost entirely enforcement-relevant

### Redundant sections (candidates for removal/condensation)
- Line 12: header quote's closing "Improvements here propagate to every loop at once." — a maintenance observation, not an instruction.
- Line 69: "If you find yourself rationalizing 'one more iteration past the cap', the control flow will stop you; file what you have." — motivational framing; the preceding sentence already states that enforcement is in orchestrator control flow, not this text.

### Load-bearing content confirmed present (do not touch)
- **Hard Limit 2 — `plan/current/.ratchet-approve` protocol** (19): the single most enforcement-critical paragraph in the skill set. Human-instruction-only, `path | reason | timestamp` strict 3-field format, a `|` in the reason invalidates the line (fails closed), immediate dedicated commit, same-uncommitted-changeset backstop. Directly describes `ratchet-check.mjs` behaviour. **Every clause is load-bearing.**
- Hard Limit 1 (armed stop rule before first iteration), 3 (agents never reset budget counters), 4 (run-log append-only) (18-21).
- Toggle Protocol (25-34) — absent/invalid → off, the zero-config regression guarantee, and "The framework never creates `planifest-overrides/loop-toggles.yml`".
- Loop-state file convention `plan/current/loop-state-{loop-id}.md`, commit-after-every-iteration, and the `status: active` → ratchet-check armed relationship (38-42).
- Stop Rules table (62-67) — cap default 3, P4 keeps 5, no-progress at 2 consecutive iterations, budget exhaustion always escalates to the human regardless of run mode.
- Escalation format and the "full context in the state file" requirement (71-80).
- `loop_iteration` telemetry shape (88-91).

---

## planifest-framework/skills/planifest-migrator/SKILL.md

**Current line count:** 104
**Recommended target:** 90 (13% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 41-45: the four-field finding record (file path / line number / current value / proposed correction) restates the presentation format shown at 58-59 in a different notation.
- Lines 24-27: Input section — "Migration file path (passed by orchestrator)" and "Working directory (cwd)" are the invocation parameters, already implied by Step 1.
- Line 69: "After each batch, confirm: `Batch {n} complete — {applied} applied, {skipped} skipped.`" partially duplicated by the Step 5 total report (82-84).
- Lines 102-104: Response Style — "Do not narrate what you are about to do — just do it" overlaps CLAUDE.md § Be succinct and the `formatting-standards.md` reference in the same line. Keep the standards pointer, drop the gloss.

### Load-bearing content confirmed present (do not touch)
- Hard Limits 1-4 (17-20): never modify `src/`; never auto-apply to code identifiers/inline spans/fenced blocks; **never proceed past a human "none" or explicit skip**; credentials.
- Batch-of-20 presentation format with the `all / none / pick` response contract (51-63).
- Archive path `planifest-framework/migrations/_done/{filename}` (73-77) — the orchestrator's Resume Detection step 1 scans for files *not* in `_done/`.
- Exclusions list (89-98) — the prose-vs-code discrimination rules and the "(uncertain — manual review recommended)" annotation are the skill's core safety mechanism.

---

## planifest-framework/skills/planifest-optimise-agent/SKILL.md

**Current line count:** 101
**Recommended target:** 80 (21% reduction)

Note: this skill's own four-category rubric is the closest existing framework analogue to this audit. Its categories should survive intact.

### Redundant sections (candidates for removal/condensation)
- Lines 64-77: Phase 3 Accumulate — six lines of output template for showing a running numbered list, plus two lines explaining that `confirm` adds and `reject` doesn't. Condense to two lines.
- Lines 79-93: Phase 4 Summary — fifteen lines of output template. The counts line and the confirmed-changes list are the content; the surrounding scaffolding can halve.
- Line 44: "Build an internal list — do not present anything yet." partially restates Phase 2's one-at-a-time protocol.
- Lines 19-22: the "Do NOT review" list — three of the four entries are implied by "Target: `planifest-framework/skills/` only" on line 17. The `planifest-overrides/capability-skills/` exclusion is the non-obvious one; keep that.

### Load-bearing content confirmed present (do not touch)
- Scope restriction to `planifest-framework/skills/` and the `planifest-overrides/capability-skills/` exclusion (17-21).
- The four superfluous-content categories (30-36), including the named stale references (`design-requirements.md`, `pipeline-run.md`, `external-skills.json`, `skill-sync.sh`) and the named hooks (`gate-write.mjs`, `check-design.mjs`, commit-msg).
- Phase 2 suggestion format and the wait-for-response gate (48-62).
- **Hard Limits 1-3** (99-101): never write/edit/delete any file; never mark confirmed without explicit human `confirm`; never suggest removing genuinely load-bearing content.

---

## planifest-framework/skills/planifest-orchestrator/SKILL.md

**Current line count:** 1195
**Recommended target:** 900 (25% reduction)

Constraint honoured: all recommendations below are in-file condensations. No split into a router + `references/` pattern, no new files, no directory changes. Structure and section order stay as they are.

### Redundant sections (candidates for removal/condensation)
- Lines 16-26 ("What You Do"): four numbered bullets restating the frontmatter description, plus "You are the quality gate. If the requirements are incomplete, nothing gets built. If a question has a vague answer, you push back... You do not guess, assume, or hand-wave." — role-framing prose. Condense 11 → 4.
- Line 43 (Hard Limit 11): the rule is the first sentence. The remaining three clauses are a post-mortem of 0000018's own P0 failure ("Self-identified during 0000018's own P0: this was a numbered sub-step with no enforcement teeth, silently skipped, and only caught by chance..."). Keep the rule verbatim, condense the history to nothing. **The rule itself must survive.**
- Line 134: "Load each file at the moment you need it - not before, not in bulk at session start. The template or skill should be the most recent thing you read..." — restates line 102's directive with a metaphor.
- Lines 280-316 ("What you are assessing against", 37 lines): the three-layer breakdown. Framework-specific items (stack declaration field list, data ownership, component design, adoption-mode-relevant concerns) are load-bearing. Generic requirements-elicitation prompts — what a problem statement is, what a user story is, "Performance: what are the latency targets? Be specific - 'fast' is not a requirement", the GDPR/HIPAA/PCI-DSS/SOC2 enumeration — are model-resident knowledge. Condense 37 → ~20.
- Lines 342-348 ("Be scientific", 7 lines): five worked pushback examples, one of which (348) is a ~90-word paragraph citing Go's 70-80% first-pass compilation rate vs TypeScript's 65-75%. The rule is "do not accept vague answers"; one short example carries it. Condense 7 → 2.
- Lines 356, 382: "Big features create big context. Big context means the agent misses detail, hallucinates, or hits token limits. The antidote is decomposition." and the microservices-vs-monolith paragraph — generic architecture coaching. The 3-story rule (363) and the 5-6-features-into-waves rule (367) are the load-bearing thresholds.
- Lines 374-376: three illustrative coaching quotes for the wave conversation — one suffices.
- **Lines 640-846 (Phases 1-9), the per-phase boilerplate.** Six phases each repeat four blocks near-verbatim:
  - "**Build log first:** Append a PX phase block... A missing block is a pipeline error (Hard Limit 8)." — 7 occurrences (642, 667, 692, 728, 751, 774, 811).
  - "**Before acting:** Load the `planifest-X-agent` skill now. Do not begin Y until you have read it." — 6 occurrences; also duplicated by the Framework Index table rows 109-125.
  - "**Commit:** Stage and commit all new ... before presenting the gate summary to the human." — 6 occurrences; also Hard Limit 7.
  - "Exceptions — proceed without confirmation if either: `continuous_run: true` was set at P0 / **Not applicable: {reason}**" — the "Not applicable" branch (661, 686, 722) is an exception that explicitly never applies. Dead text in three phases.
  State each convention once at the top of the phase sequence, keep per-phase only the genuine deltas (which skill, what input, what output, what the gate checks, the real second exception where one exists at 745/768/793). Saves ~35 lines with every STOP gate intact.
- Lines 930-974: DUP-7 — the 45-line worked `Agent()` example with two fully-written prompts from feature 0000010. Condense to a ~10-line skeleton. This is the largest single-block saving in the file.
- Lines 920-928: "Two levels of parallelism" explanation and the spawn-vs-inline heuristic — partially restates Parallelism Rules (885-912) and the Model Tier section. Condense.
- Line 1037: the paragraph explaining *why* `discovery.md` is a separate artifact ("This is a relocation of what each mode's P0 already gathers, not new scanning capability: raw findings get one consistent home, the human can see exactly what the orchestrator already knows before being asked anything..."). The operative instruction is the first sentence.
- Lines 1119-1127 (References): "Core Principles" is three vague one-liners ("Conservative by default. Autonomy is earned progressively."). "Phase skills (by name)" is a flat list duplicating the Framework Index table. Remove ~7 lines.
- Line 1167: the bold paragraph explaining that hooks are the primary emission mechanism and the instructions below are the Tier-3 backup path — condense; the operative fact is "you own `phase_skip`" (1169).
- Lines 611-636 (Skill Discovery): the assess/ask/install flow is ~10 lines of content in 26; "This step is non-blocking... Do not block the pipeline on an optional enhancement" restates "Ask the human once — do not pressure" and "Proceed silently".
- Line 1063: DUP-6.

### Load-bearing content confirmed present (do not touch)
- **All eleven Hard Limits** (29-43) — schema-modification gates, data ownership, credentials, commit cadence, build-log-at-every-phase, the P0–P9-only rule, the every-route-archives rule, the `discovery.md`-before-coaching rule.
- **Response Prefix Convention table** (53-73) — declared "complete and exhaustive"; every other skill's prefix requirement keys off it.
- **Framework Index (JIT Loading) table** (104-132) — explicitly cross-referenced by the audit brief and by every phase skill's "Before acting" instruction.
- **Resume Detection** (76-97), including interrupted-P9 sentinel cleanup (83-88) and the `plan/.run-mode` restore semantics (93).
- **Routing Directive**: standalone-skill table with the "must not be invoked independently" rule (146-153), three-track decision tree (157-167), Fast Path criteria (171-178) and `fix(fast-path):` commit convention recognised by the pre-push hook (191).
- **Phase Skip Protocol** and the `plan/current/.skips` format (195-205).
- **Pause Command** and `plan/current/pause.md` lifecycle (209-230).
- **Phase 0 Start Actions -1 through 6** (386-479) — context reset, git pre-flight, stale run-mode clearing, `plan/.orchestrator-active` sentinel (gate-write depends on this), build-log creation, repo instructions, adoption-mode detection table, version read incl. `product-version.mjs`, backlog pickup + the ID-sequence high-water-mark convention, `discovery.md` write, Skill Map, strict-mode ack, skills-inbox check.
- **Capability Skill Intake** protocol (483-496).
- **Confirmed-design gate** (500-529): "Do not proceed to Phase 1 until the human has confirmed the Design. This is the hard gate." plus the run-mode question and `plan/.run-mode` write.
- **Scope Lock Challenge** (531-568) — mandatory gate, four scenario paths one at a time, the always-offered/never-pre-drafted suggested-answer rule (ADR-003), the explicit accept/edit/reject requirement, and the build-log capture format.
- **P0 Audit Trail** incremental-write rule (572-582).
- **Phase 0 → Phase 1 Gate Checklist** (586-609) — sixteen items, incl. the Hard-Limit-11 redundant catch.
- **Every STOP gate** at P1-P7 and the P7 note that `continuous_run` does NOT bypass shipping (822).
- **Cross-Model Review Gate** ordering constraint (797-806) — must run before P7 archive; ADR-008 rejected the alternative placement.
- **Model Tier Decision Table** and tier-to-model mapping (850-881) — cross-referenced by codegen-agent and the Subagent Decomposition Directive.
- **Parallelism Rules** (885-912) — the canonical statement the six per-skill Parallelism Directives should defer to.
- **Mid-Pipeline Requirement Changes** re-run rules (988-1004).
- **Governed Phase-Reversal Protocol** (1008-1025) — petition/assess/execute sequence, budget 2/feature, the four always-stop human gates, ratchet-check enforcement note.
- **Adoption Modes** (1029-1098) — mode taxonomy with per-mode discovery content, retrofit scan steps, signal priority order, conflict-warning format.
- **Telemetry failure-detection and interactive-recovery protocol** (1136-1144) — `plan/.telemetry-failures/` marker check at every phase start, `root_cause_key` acknowledgement semantics, and the mandatory per-phase `Telemetry` field (a blank field is treated as a missing phase block under Hard Limit 8).
- Event type reference table (1146-1164) and the four orchestrator-owned event shapes (1171-1194).

---

## planifest-framework/skills/planifest-refactor/SKILL.md

**Current line count:** 89
**Recommended target:** 55 (38% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 15-19: DUP-4 (Model Tier Rationale).
- Lines 44-50: "Quality improvements in scope" — six bullets naming standard refactoring moves (extract repeated logic, split large functions, remove unnecessary complexity, correct inconsistent formatting). A model that can refactor knows the catalogue. The glossary-rename bullet (46) is the one framework-specific item.
- Lines 52-56: "Quality improvements out of scope" — bullet 3 (signature changes requiring test updates) restates Hard Limit 4; bullets 1-2 are inferable from "do not add new behaviour" (HL1). Only bullet 4 (don't extract single-use utilities) is non-obvious.
- Lines 62-64: Process steps 1-3 restate the Input section as imperatives.
- Lines 81-88: DUP-9. Bullets 1-3 restate HL1/HL2; bullet 5 restates step 6.

### Load-bearing content confirmed present (do not touch)
- Hard Limits 1-5 (23-27), especially **HL4: "If a refactor would require changing a test, stop — the test is the contract. Escalate to the codegen-agent."**
- Full-suite requirement: run every test, not just the current requirement's, and revert the last change on any breakage (66-71).
- `REFACTOR ✓` report format (73-77) — codegen-agent waits on this token.
- Test file is read-only input (34).
- Scope boundary: only files touched by the current requirement's implementation (86).

---

## planifest-framework/skills/planifest-refresh-setup/SKILL.md

**Current line count:** 169
**Recommended target:** 145 (14% reduction)

Mostly load-bearing: tool signal table, ordered destructive-operation sequence, deletion allowlist. Trims are limited to rationale prose.

### Redundant sections (candidates for removal/condensation)
- Line 18: "Typical invocations: 'refresh the framework setup', 're-run setup with current settings', 'refresh setup for cursor'." — verbatim duplicate of the trigger phrases already in the frontmatter `description`.
- Lines 14-16: "When You Run" — the "not part of the confirmed-design pipeline; no design.md or phase gate is required" clause is load-bearing; the surrounding restatement of the description is not.
- Line 124, sentences 2-3: the paragraph justifying why the allowlist lives in the script rather than in prose ("This closes a gap identified in this feature's own security review: a deletion boundary described only in instructions has no deterministic backstop against agent error or a maliciously crafted repo file, the way `gate-write.mjs` backs..."). Keep sentence 1 (the script hardcodes the allowlist) and the final never-delete rule; the security-review narrative can go.
- Lines 157-159 ("Domain Terms"): a bare list of eight terms with no definitions, pointing at a glossary in an archive directory. Provides no usable information at read time. Remove.
- Lines 163-169 ("What This Skill Never Does"): five bullets, each restating a constraint from Steps 4, 6, 7, and 8. As a safety summary for a destructive operation it earns its place — condense 5 bullets → 3, keeping the deletion and no-affirmative ones.

### Load-bearing content confirmed present (do not touch)
- Tool signal detection table with all nine valid tool identifiers and the roo-code deprecation branch (26-39).
- The zero-install / one-install / multi-install branch logic and Step 1a's exact refusal message (41-51).
- Step 2 interrupted-run recovery: boot file missing AND `attemptStatus: "pending"` → skip detection, go to Step 4 (55-65).
- Step 3 flag-inference signal table with confidence levels, incl. the medium-confidence `attribution.txt` caveat (73-84).
- **Step 4 confirmation gate**: "Always required, in every run, regardless of confidence level... There is no bypass." plus the halt-on-rejection rule (88-97).
- Step 5 marker-before-deletion ordering and the exact JSON schema (101-116).
- **Step 6**: must invoke `refresh-delete-boot-files.sh`/`.ps1`, never a freeform `rm`; never delete `settings.local.json` or anything outside the allowlist (120-124).
- Step 8 failure handling: stop immediately, never auto-retry, the six-item report contents (140-153).

---

## planifest-framework/skills/planifest-reversal-assessor/SKILL.md

**Current line count:** 69
**Recommended target:** 64 (7% reduction) — no meaningful reduction available beyond two lines

### Redundant sections (candidates for removal/condensation)
- Line 25: "The five questions in brief: real blocker? shallowest owning phase? blast radius? budget remaining? additive vs. altering?" — a preview of the five-row table printed immediately below it. Pure duplication.
- Line 35, second clause: "a denied petition should teach the filer what a grantable one looks like" — rationale for the instruction in the same sentence.

### Load-bearing content confirmed present (do not touch)
- Invocation contract: spawned fresh, never the filer (ADR-006); incomplete report returned unassessed; judge-not-execute separation (19-21).
- **REJECT-default rubric, all five items** (27-33) — including the cascade > 3 artifacts human-gate threshold (ADR-005), the 2/feature budget, and the classify-as-altering-when-unsure rule (REQ-019).
- "Ambiguous evidence on any item = that item fails = DENY." (35).
- Verdict artifact path `plan/current/defect-reports/{seq}-verdict.md` and its full schema (39-60).
- `phase_reversal_granted` / `phase_reversal_denied` telemetry shape (66-68).

---

## planifest-framework/skills/planifest-scope-lock-agent/SKILL.md

**Current line count:** 54
**Recommended target:** 48 (11% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 45-50 ("What you must never do"): four bullets. Bullet 1 restates drafting rule 5; bullet 2 restates Invocation Contract line 21 near-verbatim; bullet 4 restates line 19's "never spawned for more than one item at a time". Only bullet 3 (never smooth over a flagged inconsistency) adds signal beyond rule 4. Condense 6 → 2. **Note:** this section is defensive restatement of governance rules — condense, do not delete outright.
- Line 19: the triple "never spawned pre-emptively, never spawned automatically alongside the question itself, and never spawned for more than one item at a time" — three phrasings of one constraint.
- Line 13: the header quote's closing "Your draft is worthless the moment anyone treats it as anything but a draft (ADR-003)" — keep the ADR-003 citation, the rhetoric is optional.

### Load-bearing content confirmed present (do not touch)
- Invocation contract: fresh-context subagent only, only on explicit human request, one item at a time, no coaching conversation in the prompt (19-21).
- **"You never write to `plan/current/build-log.md`, never mark anything confirmed, and never advance the Scope Lock Challenge"** (21) — the ADR-003 governance boundary.
- All five drafting rules (25-31), notably rule 4 (consistency check, flag contradictions rather than resolving them) and rule 5 (no implicit confirmation; silence is never approval).
- The output format block (37-43).
- The telemetry gate note: no dedicated event type; the orchestrator's build-log entries are the durable record (54).

---

## planifest-framework/skills/planifest-security-agent/SKILL.md

**Current line count:** 146
**Recommended target:** 110 (25% reduction)

### Redundant sections (candidates for removal/condensation)
- Line 18: DUP-6.
- Lines 69-75: the IaC review sub-bullets (overly permissive IAM, public exposure, missing encryption, missing logging, hardcoded secrets, non-compliant bucket policies) — a generic cloud-security checklist the model produces from "review the IaC". Condense 7 → 2.
- Lines 41, 48, 53, 57, 61, 65: one-line instructional glosses inside the report template ("For each STRIDE category, identify specific threats relevant to this component", "Review ingress and egress surface. Flag unnecessarily open ports"). The section headings carry the same instruction. Halve.
- Line 91: DUP-3.
- Line 92: the be-specific rule with a ~45-word worked example. Keep the rule and a short example; the full `apps/api/src/routes/orders.ts:42` narrative can compress.
- Lines 93-95: "Do not fabricate findings", "if you cannot assess a risk area, say so", "rate conservatively" — the first two are generic-model-behaviour restatements. "Rate conservatively / if in doubt rate higher" is a real calibration instruction; keep that one.
- Lines 101-111: DUP-5.
- Line 119: DUP-2.
- Lines 144-146: DUP-1.

### Load-bearing content confirmed present (do not touch)
- Report path `plan/current/security-report.md` and the report's section structure (30, 36-85).
- STRIDE table schema with severity vocabulary (43-45).
- "Cross-reference the Risk Register" — confirm each spec-agent risk is mitigated or still open (96).
- **"Critical and high findings are flagged for human attention at the PR gate."** (97) — the orchestrator's P5 gate and ship-agent's PR template both depend on this.
- Severity vocabulary consistency (`low|medium|high|critical`) across the report and the `security_finding` event.
- All four telemetry event shapes (121-140), incl. the optional `cwe` field.

---

## planifest-framework/skills/planifest-ship-agent/SKILL.md

**Current line count:** 310
**Recommended target:** 245 (21% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 137-152 (Step 6b): the full `docs/about.md` frontmatter-plus-table is reproduced inline **and** the step instructs "Read `planifest-framework/templates/about.template.md` for the exact format" two lines earlier. One source of truth; keep the template reference, drop the inline copy (~14 lines). Line 152's "Do not copy the template comment block" instruction must survive in whichever form remains.
- Line 124, final clause: the cross-reference war story ("confirmed in practice: a downstream repo's `decisions-index.md` ADR links were left pointing at `plan/current/adr/...` after P7 ran and had to be fixed retroactively in a later, unrelated feature"). The rule and its consequence survive without the incident report. (DUP-10.)
- Line 80: "The changelog (Step 1) already includes the skips under `## Skipped Phases`" — a status note about a completed step, inside a numbered procedure.
- Line 52: the Audience blockquote — the changelog-vs-iteration-log distinction is genuinely useful disambiguation, but three sentences compress to one.
- Lines 279-289 (Step 11): eleven lines to emit one advisory message, of which two ("This is a recommendation only — do not block, do not ask for confirmation, do not repeat it") restate what the message itself says. Condense to ~5.
- Line 33 (Hard Limit 5): DUP-3 — keep the rule, drop the three-clause expansion.
- Lines 117-119: "Confirm the copy is complete before proceeding" / "Confirm `plan/current/` is empty" — self-evident inside a numbered sequence (but see the note below: the *ordering* rules at 120-122 are load-bearing).

### Inconsistency spotted (flag, do not silently trim)
Lines 19-21: the Prefix section assigns `P8:` to "Step 8" and `P9:` to "Steps 8–11" — Step 8 is claimed by both prefixes. The actual step layout is P7 = Steps 1-7, P8 = the build-assessment invocation, P9 = Steps 8-11. Worth correcting while trimming, but it is a correctness fix, not a reduction.

### Load-bearing content confirmed present (do not touch)
- Phase prefix assignment P7/P8/P9 (17-24) — subject to the correction above.
- Hard Limits 1-5 (29-34), incl. "Do not skip the archive step — leaving `plan/current/` populated breaks resume detection" and "Do not raise a PR or create a git tag without the human's awareness".
- Step 4 regression confirmation: scan for `# REGRESSION-CANDIDATE:`, per-candidate human y/n, and the exact `promote-to-regression.sh` invocation (89-100) — pairs with test-writer's Regression Tagging section.
- Step 5 test report path and template (102-108).
- **Step 6 archive sequence** (110-123): copy-then-delete never atomic move; the numbered deletion order; `plan/.orchestrator-active` removed last; `.orchestrator-ack` and `.run-mode` cleanup (which orchestrator Resume Detection 2a compensates for when interrupted).
- Cross-reference check timing: "before Step 1, not after Step 6" (124).
- Step 6b as a **blocking step** and the `docs/about.md` field semantics (126-135).
- Step 7 commit command and message format (154-161).
- P8 build-log path note: append to the archived copy, `plan/current/build-log.md` no longer exists (167).
- P8 sub-agent invocation block and the wait-for-`P8: Complete` gate (169-182).
- **Step 8 version derivation** (190-208): `product-version.mjs` exit codes 0/2/4/5, the three-case branch, the `[0-9]+\.[0-9]+(\.[0-9]+)?` regex, ≤20 chars, must not be lower than the last tag, never tag a fabricated version.
- Step 9 `local-git-only` override check and both PR paths incl. the PR body template (210-262).
- Step 10 confirmation block (264-277).
- Telemetry `phase_start`/`phase_end` shapes (297-310).

---

## planifest-framework/skills/planifest-spec-agent/SKILL.md

**Current line count:** 136
**Recommended target:** 105 (23% reduction)

### Redundant sections (candidates for removal/condensation)
- Line 46: DUP-3.
- Line 54: "The system should be fast" / "p95 latency < 200ms" worked example — the same example appears in orchestrator 344. One copy is enough, and the orchestrator's is the coaching-facing one.
- Lines 65-66: "Define every domain term used in the spec. If the brief introduces terms, define them." — restates the artifact table's Domain Glossary purpose line (36). "Never invent domain language" is the load-bearing half.
- Lines 68-70 (Scope): "State what is in, what is out, and what is deferred. All three sections must be present." duplicates the artifact table row 34 ("In / out / deferred - all three stated explicitly").
- Lines 101-103 (Retrofit Mode): a three-line summary of behaviour the orchestrator specifies in far more detail at 1059-1072 (Adoption Modes → Retrofit, six-step scan). Replace with a pointer.
- Lines 107-117: DUP-5.
- Line 125: DUP-2.
- Lines 134-136: DUP-1.

### Load-bearing content confirmed present (do not touch)
- Artifact table with all ten paths (30-40) — including the `src/{component-id}/component.yml` and `src/{component-id}/docs/data-contract.md` targets, which gate-write.mjs scope depends on.
- "Write each spec artifact to `plan/` as you complete it... Do not accumulate artifacts in memory." (26).
- Granular requirement files at `plan/current/requirements/{req-id}-{slug}.md`; **"Do NOT output a monolithic list in the Execution Plan."** (50-51).
- **OpenAPI CRITICAL CONDITION** (58): generate only if the feature builds or modifies an API; omit entirely for UI/daemon/library components.
- Component manifest rules (76-81): don't modify the pre-seeded `stack`; `pipeline.domainKnowledgePath: plan`; `purpose.notResponsibleFor` mandatory; leave `contract.consumedBy` empty.
- Assumptions boundary (83-85): document minor gaps in the risk register at likelihood medium; never assume away material ambiguity — report back instead.
- Waved Features section (89-97) — the `-wave-2` suffix naming convention and the cumulative glossary/risk-register carry-forward rules.
- `spec_gap` telemetry shape (127-130).

---

## planifest-framework/skills/planifest-test-writer/SKILL.md

**Current line count:** 93
**Recommended target:** 58 (38% reduction)

### Redundant sections (candidates for removal/condensation)
- Lines 15-19: DUP-4 (Model Tier Rationale).
- Lines 53-56: Process steps 1-2 restate the Input section as imperatives.
- Lines 57-62: DUP-8 (test-runner command block).
- Lines 85-92: DUP-9. Bullet 1 restates HL2; bullets 3-5 restate HL1 and the invocation contract. Only "do not run the full test suite" adds a constraint.
- Line 11: the header quote's four short sentences compress to one without losing the boundary.
- Line 47: "Does not test more than one acceptance criterion per test function (one test per criterion is acceptable; one test file per requirement is the unit)" — the parenthetical contradicts-then-clarifies the main clause; rewrite as one statement.

### Load-bearing content confirmed present (do not touch)
- Hard Limits 1-4 (23-26), especially **HL3: "If the test passes before any implementation is written, it is invalid. The test MUST exit non-zero (RED) on first run."**
- Test file naming convention `test-{req-id}-{slug}.{ext}` and placement conventions (43-44).
- **Req-ID in the test description** (45) — validate-agent step 1 and codegen-agent line 190 both depend on this.
- `RED ✓` report format (65-69) — codegen-agent waits on this token.
- **Regression Tagging** section (73-81): the exact `# REGRESSION-CANDIDATE:` comment format that ship-agent P7 Step 4 scans for.
- Domain glossary path and use-its-terms rule (34).

---

## planifest-framework/skills/planifest-validate-agent/SKILL.md

**Current line count:** 181
**Recommended target:** 135 (25% reduction)

### Redundant sections (candidates for removal/condensation)
- **Lines 124-138 and 142-152 — two sections saying the same thing.** "Pre-Execution Parallelism Plan" (15 lines) and "Parallelism Directive" (11 lines) both mandate lint+typecheck in parallel, both give the same batch ordering (lint+typecheck → test → build), both state the same dependency reasons, and both close with the identical sentence "Never run lint → wait → typecheck → wait as a serial chain." Merge into one ~8-line section. Largest single saving in this file. (Also DUP-5.)
- Lines 61-67: the five-step self-correct procedure ("Read the error output carefully / Identify the root cause - not just the symptom / Fix it / Re-run the failing check / If the fix introduces new failures, address those too") — generic debugging method. The load-bearing parts are the cap of 5 and the cycle-tracking format.
- Line 104: DUP-3.
- Lines 118-120: Capability Skills — generic (same pattern as change-agent 165-167, docs-agent 172-174).
- Line 39: DUP-6.
- Lines 112-114 (Standards References): two lines whose content is "don't refactor to meet standards during validation; record non-failing violations for docs-agent" — keep, but it can fold into the Rules list rather than carrying its own heading.
- Line 160: DUP-2.
- Lines 179-181: DUP-1.

### Load-bearing content confirmed present (do not touch)
- **Build Target: docker** block (16-26) — never run checks against the host toolchain; absent host runtime is expected, not a failure.
- **The strict check order 0-6** (43-57): library audit → semantic correctness → lint → typecheck → test → build → verify-by-execution. The ordering is explicitly "strict".
- Semantic correctness detail (45-51): req-ID-identifiable test required, per-AC coverage table, **"Missing AC coverage = semantic validation failure (not a warning)"**, the no-AC-section doc-gap-but-continue branch.
- Step 6 verify-by-execution toggle handoff to `planifest-verify-by-execution`, and that a behavioural `failed` is a validation failure (57).
- **Cap of 5 self-correct cycles** and the explicit override of loop-runner's default 3 (69).
- Cycle tracking format (71-78) and the `VALIDATION BLOCKED` escalation format (82-96).
- **"Do NOT proceed to the next pipeline phase if any check is failing."** (98).
- "Fix the actual bug. Do not suppress linting rules, skip failing tests, or weaken type checks." (105).
- Requirements-ambiguity → `src/{component-id}/docs/quirks.md` rule (107).
- All three telemetry event shapes (162-175).

---

## planifest-framework/skills/planifest-verify-by-execution/SKILL.md

**Current line count:** 60
**Recommended target:** 56 (7% reduction) — no meaningful reduction available; this file is already dense

### Redundant sections (candidates for removal/condensation)
- Line 12: the header quote's middle clause "You are the difference between 'the suite is green' and 'a human clicked the button and the right thing happened' — except you are the one clicking." — rhetorical restatement of The One Rule at line 18, which states it precisely and unambiguously.
- Line 56: "In **report-only** mode, `failed` outcomes are reported but do not gate P4. In **on** mode they enter self-correction like any failing check." — duplicates the `failed` row of the Per-Criterion Outcomes table (39) and validate-agent line 57. Keep one.

### Load-bearing content confirmed present (do not touch)
- **The One Rule** (18): reading test output alone never counts; un-runnable criteria are `not-verifiable` with a reason, never silently passed.
- Method Selection table (24-30) — five target types with their required observation evidence, incl. the accessibility-tree-beats-screenshots note.
- "Never verify against production systems or with production credentials." (32).
- Per-Criterion Outcomes table (36-40) — including that `failed` feeds P4's existing cap-5 self-correction loop unchanged.
- Report path `plan/current/verification-report.md` and its table schema (44-54).
- `loop_iteration` telemetry with loop_id `verify_by_execution` (60).

---

## Notes for the trimming agent

1. **Order of operations.** Execute the cross-file duplication register (DUP-1 through DUP-10) first. It accounts for roughly 40% of the total reduction and is mechanical — no per-file judgement needed.
2. **Line counts are a lagging indicator.** DUP-2 (the telemetry emission-gate paragraph) removes only 7 physical lines but ~630 words of duplicated instruction across 7 files. Several long single-line paragraphs (orchestrator 43, 348, 434, 1037; refresh-setup 124; ship-agent 124) are similar: high token cost, low line cost.
3. **Never touch, in any file:** any Hard Limit, any line containing "STOP", any migration-proposal-and-stop instruction, any `.ratchet-approve` text, any sentinel-file path (`plan/.orchestrator-active`, `.orchestrator-ack`, `.run-mode`, `.feature-id`, `.skips`, `pause.md`), any confirmation token another skill waits on (`RED ✓`, `GREEN ✓`, `REFACTOR ✓`, `P8: Complete`), and any credentials rule.
4. **Orchestrator constraint reminder.** All orchestrator recommendations above are in-file. Do not split it into a router plus `references/`, and do not move phase detail into lazily-loaded files — that is deferred to a future feature.
5. **`.claude/` is out of scope** — it is a synced copy and no edits were proposed to it.
