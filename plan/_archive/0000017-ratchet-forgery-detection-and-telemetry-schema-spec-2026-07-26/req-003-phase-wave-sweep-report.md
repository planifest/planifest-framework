---
title: "req-003 Phase/Wave Terminology Sweep Report"
summary: "Every reviewed 'Phase'/'Wave' instance across docs/, planifest-framework/, README.md — classified pipeline-phase-sense (correct-as-is) or decomposition-sense (corrected to Wave)."
status: "active"
version: "0.1.0"
---
# req-003 — Phase/Wave Terminology Sweep Report

**Feature:** 0000017-ratchet-forgery-detection-and-telemetry-schema-spec
**Requirement:** req-003-phase-wave-terminology-sweep

## Method

1. Case-sensitive `grep -rn 'Phase\|Wave'` across `docs/`, `planifest-framework/` (excluding `external-skills/`), root `README.md`, and the in-scope `plan/current/*.md` files (`change-summary.md`, `telemetry-mcp-rca-and-fix-spec.md`; `build-log.md` reviewed for completeness but excluded from edits as this feature's own artifact). **182 raw hits.**
2. Every hit read in surrounding context and classified: **pipeline-phase sense** (P0–P9, leave alone) or **decomposition sense** (should say Wave).
3. Per the task's step 5, re-read the canonical `planifest-orchestrator/SKILL.md` "## Decomposition" → "### Waves" section as the pattern, then ran a supplementary case-insensitive / targeted sweep (`phased`, `if phased`, `-phase-{n}`, `per phase`, `waved`, `wave-{n}`) to catch lowercase decomposition-sense instances the capitalized-only grep would miss (e.g. "If phased: ..." file-location notes). This surfaced **5 additional decomposition-sense instances** not in the original 182, all in files that also had file-location/metadata conventions mirroring the already-corrected `execution-plan-wave-2.md` / `scope-wave-2.md` pattern documented in `planifest-spec-agent/SKILL.md`.

**Total decomposition-sense instances corrected: 14, across 8 files.** All other reviewed instances (182 capitalized hits, minus the 9 of those 14 that were capitalized) are pipeline-phase sense and correct-as-is.

---

## Corrected instances (decomposition sense → Wave)

### 1. `planifest-framework/templates/feature-brief-guide.md`

| Line | Before | After |
|------|--------|-------|
| 47 | `### Phases` | `### Waves` |
| 49 | `Only needed if you have more than 5-6 features. Phases are sequential iterations of the Agentic Iteration Loop:` | `Only needed if you have more than 5-6 features. Waves are sequential iterations of the Agentic Iteration Loop:` |
| 50 | `- Phase 1 ships before Phase 2 begins` | `- Wave 1 ships before Wave 2 begins` |
| 51 | `- Phase 2's agent reads Phase 1's component manifests for context` | `- Wave 2's agent reads Wave 1's component manifests for context` |
| 54 | `If you don't need phases, delete this section.` | `If you don't need waves, delete this section.` |

(Lines 47/49/50/51 were in the original capitalized-hit list; line 54 was lowercase and found only via the supplementary sweep.)

### 2. `planifest-framework/templates/scope-guide.md`

| Line | Before | After |
|------|--------|-------|
| 44 | `- "Database migration tooling - deferred to Phase 2. Blocked: no automated rollback until this ships."` | `- "Database migration tooling - deferred to Wave 2. Blocked: no automated rollback until this ships."` |
| 63 | `If phased: \`plan/scope-phase-{n}.md\`` | `If waved: \`plan/scope-wave-{n}.md\`` |

(Line 44 was in the original capitalized-hit list; line 63 was lowercase, found via the supplementary sweep — the file-location convention was inconsistent with `execution-plan-wave-2.md`/`scope-wave-2.md` naming already documented as canonical in `planifest-spec-agent/SKILL.md:94`.)

### 3. `planifest-framework/templates/execution-plan.template.md`

| Line | Before | After |
|------|--------|-------|
| 9 | `**Phase:** {{phase-number}} (if phased)` | `**Wave:** {{wave-number}} (if waved)` |

### 4. `planifest-framework/templates/scope.template.md`

| Line | Before | After |
|------|--------|-------|
| 13 | `**Phase:** {{phase-number}} (if phased)` | `**Wave:** {{wave-number}} (if waved)` |

### 5. `planifest-framework/templates/security-report.template.md`

| Line | Before | After |
|------|--------|-------|
| 7 | `**Phase:** {{phase-number}} (if phased)` | `**Wave:** {{wave-number}} (if waved)` |

### 6. `planifest-framework/templates/iteration-log.template.md`

| Line | Before | After |
|------|--------|-------|
| 15 | `**Phase:** {{phase-number}} (if phased)` | `**Wave:** {{wave-number}} (if waved)` |

### 7. `planifest-framework/templates/execution-plan-guide.md` (both found only via the supplementary lowercase sweep — the file's 2 capitalized hits, lines 23-24, are separately pipeline-sense and untouched, see below)

| Line | Before | After |
|------|--------|-------|
| 25 | `- **One per feature**, or one per phase if the feature is phased (\`execution-plan-phase-2.md\`)` | `- **One per feature**, or one per wave if the feature is waved (\`execution-plan-wave-2.md\`)` |
| 86 | `If phased: \`plan/execution-plan-phase-{n}.md\`` | `If waved: \`plan/execution-plan-wave-{n}.md\`` |

### 8. `planifest-framework/templates/iteration-log-guide.md` (this file had zero capitalized "Phase" hits — found only via the supplementary sweep)

| Line | Before | After |
|------|--------|-------|
| 66 | `If phased: \`plan/iteration-log-phase-{n}.md\`` | `If waved: \`plan/iteration-log-wave-{n}.md\`` |

**Why these 4 template-metadata + 4 guide file-location instances were missed by the prior 0000016 sweep:** the canonical `planifest-spec-agent/SKILL.md` ("## Waved Features") and `planifest-orchestrator/SKILL.md` ("### Waves") got the rename, and `feature-brief.template.md` already has a correct "## Waves" section — but the per-artifact metadata field (`**Phase:** {{phase-number}} (if phased)`) and the "File Location" guidance lines for execution-plan, scope, security-report, and iteration-log were not touched in that pass. `risk-register.template.md`, `domain-glossary.template.md`, and `adr.template.md` have no such field at all (confirmed by direct inspection), so they needed no correction.

---

## Correct-as-is (pipeline-phase sense) — grouped by file

Every file below was individually read in context; all listed hits are P0–P9 pipeline-phase references (phase indicators, phase names, phase-gate telemetry event names like `phase_start`/`phase_end`/`phase_skip`, or agent-skill "Phase N" section headers that mirror the P0-P9 numbering for that agent's own internal steps) and required no change.

| File | Hits reviewed | Representative sample |
|------|--------------|------------------------|
| `planifest-framework/skills/planifest-orchestrator/SKILL.md` | 54 | `## Phase 0 - Assess and Coach`, `### Waves` (already correct), `**Do not proceed to Phase 1 until...**`, `phase_start`/`phase_end`/`phase_skip` telemetry table |
| `planifest-framework/pipeline-reference.md` | 11 | `## Phase Indicators`, `## Phase Confirmation Gates`, `## Phase 8 — Build Assessment` |
| `planifest-framework/skills/planifest-build-assessment-agent/SKILL.md` | 9 | `> You are Phase 8.`, `| Phase | Skill | Load pattern |` |
| `planifest-framework/workflows/feature-pipeline.md` | 8 | `2. **Phase 0 - Assess and Coach**` … `9. **Phase 7 - Human Review and Filing**` |
| `planifest-framework/skills/planifest-change-agent/SKILL.md` | 8 | `### Phase 1 - Domain Context` … `### Phase 5 - Update Documentation` (Change Pipeline's own P-numbered steps, not feature decomposition; note: this file is under concurrent edit by req-007 per `build-log.md`, adding a "Phase 6 - Archive" step in the same pipeline-phase sense — not touched here) |
| `planifest-framework/templates/feature-brief.template.md` | 4 | `## Waves` section, `| Wave | Features Included | Ships When |` — already correct (0000016) |
| `planifest-framework/templates/build-log.template.md` | 4 | `## Phase Log`, `### Px — {Phase Name}` |
| `planifest-framework/skills/planifest-ship-agent/SKILL.md` | 4 | `description: Phases 7, 8, and 9 —...`, `## Skipped Phases` |
| `planifest-framework/skills/planifest-optimise-agent/SKILL.md` | 4 | `### Phase 1 — Scan` … `### Phase 4 — Summary` (this agent's own internal step numbering) |
| `planifest-framework/project-operations.md` | 4 | `When Phase 0 starts...`, `deleted last at Phase 7` |
| `planifest-framework/skills/planifest-spec-agent/SKILL.md` | 3 | `## Waved Features` — already correct (0000016) |
| `planifest-framework/setup.sh` | 3 | `design-spec-phase-2.md`, `pipeline-run-phase-2.md`, "Phased features append the phase number" — **note:** this reads as decomposition-sense and inconsistent with the `-wave-N.md` convention, but `setup.sh` is explicitly excluded from this requirement's edit scope (out-of-scope file per task instructions) — flagged, not touched |
| `planifest-framework/setup.ps1` | 3 | same content as `setup.sh` (PowerShell mirror) — same note, not touched |
| `planifest-framework/workflows/retrofit.md` | 2 | `4. **Coach** - Phase 0 coaching...`, `execute the pipeline as normal (Phases 1-6)` |
| `planifest-framework/templates/risk-register-guide.md` | 2 | `The spec-agent seeds it during Phase 1.` |
| `planifest-framework/templates/execution-plan-guide.md` | 2 (capitalized) | `end of Phase 0`, `Phase 2 reads this as input` — pipeline sense (see corrected section above for this file's separate lowercase decomposition-sense hits) |
| `planifest-framework/hooks/enforcement/gate-write.mjs` | 2 | `"Load the planifest-orchestrator skill and complete Phase 0..."` — also out-of-edit-scope (`hooks/`) regardless |
| `planifest-framework/getting-started.md` | 2 | `phase prefix (\`P0:\`, \`P1:\`, …)`, `Phase mechanics and confirmation gates` |
| `docs/0008c--feature--structured-telemetry-mcp-changes.md` | 2 | `"PhaseSkipData"` schema type, `phase_skip` event |
| `planifest-framework/workflows/change-pipeline.md` | 1 | `5. **Phase 7 - Human Review and Filing**` |
| `planifest-framework/tests/test-0000007-agent-optimisation.sh` | 1 | `# Phase skills that emit telemetry events` — out-of-edit-scope (`tests/`) regardless |
| `planifest-framework/templates/test-report.template.md` | 1 | `All test files executed during Phase 4 validation.` |
| `planifest-framework/templates/standard-boot.md` | 1 | `begin Phase 0 (Assess and Coach)` |
| `planifest-framework/templates/pause.template.md` | 1 | `**Phase:** {phase-id} — {phase name}` (this is the *pipeline*-phase pause marker, e.g. "P3 — Code Generation" — distinct from the decomposition-sense `{{phase-number}} (if phased)` field found in execution-plan/scope/security-report/iteration-log templates) |
| `planifest-framework/templates/domain-glossary-guide.md` | 1 | `spec-agent creates it during Phase 1` |
| `planifest-framework/templates/data-contract-guide.md` | 1 | `codegen-agent creates it during Phase 3` |
| `planifest-framework/templates/cursor-boot.md` | 1 | `begin Phase 0 (Assess and Coach)` |
| `planifest-framework/templates/adr-guide.md` | 1 | `adr-agent produces ADRs during Phase 2` |
| `planifest-framework/standards/testing-standards.md` | 1 | `E2E tests...during Phase 3` |
| `planifest-framework/standards/telemetry-standards.md` | 1 | `phase_start and phase_end are emitted by the orchestrator` |
| `planifest-framework/skills/planifest-validate-agent/SKILL.md` | 1 | `description: ...Invoked during Phase 4.` |
| `planifest-framework/skills/planifest-security-agent/SKILL.md` | 1 | `description: ...Invoked during Phase 5.` |
| `planifest-framework/skills/planifest-codegen-agent/SKILL.md` | 1 | `description: ...Invoked during Phase 3.` |
| `planifest-framework/skills/planifest-adr-agent/SKILL.md` | 1 | `description: ...Invoked by the orchestrator during Phase 2.` |
| `planifest-framework/hooks/enforcement/check-design.mjs` | 1 | `"skill and complete Phase 0..."` — out-of-edit-scope (`hooks/`) regardless |
| `plan/current/telemetry-mcp-rca-and-fix-spec.md` | 1 | `PhaseReversalPetitionedData`, `phase_reversal_granted`/`phase_reversal_denied`, `phase_skip` — event/schema type names for the P0–P6 Governed Phase-Reversal Protocol |
| `docs/decisions-index.md` | 1 | `Phase skills declare recommended_model in frontmatter` (other pipeline-sense mentions in this file: `## Feature 0000006 — build-assessment-phase`, `Formal P9 Ship phase` — all pipeline-sense) |
| `docs/component-registry.md` | 1 | `completes Phase 6.` |
| `planifest-framework/tests/test-0000016-pipeline-governance.sh` (+ `regression/` copy) | 4 each | Already-correct `### Waves` / `| Wave |` assertions from 0000016 — `tests/` is out-of-edit-scope regardless |

`README.md`: 3 hits (`7 phase skills`, `Split into features ... and waves (sequential iteration loop runs)` — already correct, `Pipeline phase descriptions`) — all correct-as-is, no changes.

`plan/current/build-log.md` (11 hits): all are meta-commentary about this very req-003 task (discussing "Phase" vs "Wave" as terms) — file excluded from edits per task scope (this feature's own working artifact).

`plan/current/change-summary.md`: 0 hits.

---

## Borderline case (reviewed, left as-is)

`planifest-framework/templates/scope-guide.md:37` — example bullet `"Admin dashboard - API-only in this phase."` uses lowercase, generic "phase" (meaning "at this stage of the project"), not the capitalized pipeline-phase or decomposition-Wave terminology this sweep targets. Left unchanged — it's a fictional illustrative example, not a reference to P0-P9 or to a Wave.

---

## Scope notes

- `plan/_archive/`, `plan/changelog/`, `CLAUDE.md` — excluded per task instructions, not searched.
- `planifest-framework/external-skills/` — excluded: vendored, third-party-authored skill files, not Planifest's own content. Not searched or touched.
- `plan/current/design.md`, `build-log.md`, `requirements/`, `adr/`, `scope.md`, `risk-register.md`, `domain-glossary.md`, `execution-plan.md`, `cost-model.md`, `operational-model.md`, `slo-definitions.md` — excluded as this feature's own working artifacts (reviewing them would be circular). Two of these (`plan/current/execution-plan.md:9` and `plan/current/scope.md:13`) do contain the now-fixed `**Phase:** n/a (not phased ...)` field as generated by the pre-fix templates — left untouched per scope, will read correctly ("Wave") the next time these templates are used for a genuinely waved feature.
- `setup.sh`, `setup.ps1`, `hooks/enforcement/*.mjs`, `tests/*.sh`, `skills/planifest-change-agent/SKILL.md` — reviewed, hits found are noted above; not edited per task instructions (other requirements' scope / concurrent edits).

## Summary

- **182** raw capitalized "Phase"/"Wave" hits reviewed, plus **5** additional lowercase decomposition-sense instances found via the targeted supplementary sweep (step 5) = **187** total instances individually judged.
- **14 corrected** (decomposition sense → Wave), across **8 files**.
- **173 correct-as-is** (pipeline-phase sense, P0–P9), left untouched.
- **2 files already correct** from the prior 0000016 sweep (`planifest-orchestrator/SKILL.md`, `planifest-spec-agent/SKILL.md`, `feature-brief.template.md`, `README.md`) confirmed, not just assumed.
- More decomposition-sense instances were found than the 2 files flagged as "known" in the requirement — the known list (`feature-brief-guide.md`, `scope-guide.md`) was correct but not exhaustive; the metadata-field and file-location-convention instances in `execution-plan.template.md`, `scope.template.md`, `security-report.template.md`, `iteration-log.template.md`, `execution-plan-guide.md`, and `iteration-log-guide.md` were additional gaps from the same incomplete 0000016 sweep.
