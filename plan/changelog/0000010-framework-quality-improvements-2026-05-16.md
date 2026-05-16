# Changelog — 0000010-framework-quality-improvements — 16 May 2026

**Feature:** framework-quality-improvements
**Pipeline run:** P0–P8 complete
**Patches:** 0000010b (attribution normalisation), 0000010c (CI workflow fix)

---

## What Was Built

### 0000010 — Framework Quality Improvements (14 May 2026)

- **REQ-001** — `requirement.template.md`: added conditional `## Input Validation` section after `## Dependencies`; instructs spec-agent to include only when requirement reads untrusted external content into model-visible output; fields: input source, allowed character pattern, max length, failure behaviour, logging policy
- **REQ-002** — Agent tool in `allowedTools`: `setup.sh` + `setup.ps1` now idempotently add `"Agent"` to `.claude/settings.json`; fixes root cause of zero Agent spawning (per-use confirmation was never confirmed); orchestrator SKILL.md gains `## Agent Dispatch Template` (two levels of parallelism, self-contained prompt rule, model-tier guidance); codegen-agent SKILL.md gains `## Parallel Dispatch Checklist`; validate-agent SKILL.md gains `## Pre-Execution Parallelism Plan`
- **REQ-003** — Skill directory name normalisation: 134 external-skill dirs renamed to match `name:` field in SKILL.md (kebab-case canonical form); 23 duplicate dirs deleted
- **REQ-004** — Additional external skills: 196 new skills extracted from sw-agent-skills (152), marketingskills (40), garden-skills (4); external-skills README regenerated as 2-column table, 372 rows alphabetically sorted

**Test suite:** 20/20 acceptance tests pass.

### 0000010b — Attribution normalisation (14 May 2026)

All 372 `external-skills/*/attribution.txt` files normalised to the structured key-value format required by `test-attribution-validation.sh`.

- `LICENSE (MIT):` → `LICENSE:` across 164 pre-existing files
- `Source URL: (original work)` → `https://github.com/coreyhaines/marketingskills` in 52 marketingskills files
- Old comment-format headers (`# Source URL:`, `# Licence:`) converted to structured fields in remaining pre-existing skills

**Test suite:** `test-attribution-validation.sh` 2605/0 pass/fail.

### 0000010c — CI workflow secrets context fix (16 May 2026)

- `.github/workflows/planifest.yml`: removed invalid `if: ${{ secrets.PLANIFEST_TELEMETRY_URL != '' }}` job-level condition (GitHub Actions does not permit `secrets` context there); replaced with `if [ -z "$PLANIFEST_TELEMETRY_URL" ]; then exit 0; fi` guard inside the step run block. Job now always appears in CI run log; exits 0 silently when secret is absent.

---

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Design | `plan/archive/0000010-framework-quality-improvements/design.md` |
| Requirements (4 files) | `plan/archive/0000010-framework-quality-improvements/requirements/` |
| ADRs (3 files) | `plan/archive/0000010-framework-quality-improvements/adr/` |
| Execution plan | `plan/archive/0000010-framework-quality-improvements/execution-plan.md` |
| Scope | `plan/archive/0000010-framework-quality-improvements/scope.md` |
| Risk register | `plan/archive/0000010-framework-quality-improvements/risk-register.md` |
| Domain glossary | `plan/archive/0000010-framework-quality-improvements/domain-glossary.md` |
| Build report | `plan/archive/0000010-framework-quality-improvements/build-report.md` |

---

## Decisions

| ADR | Decision |
|-----|----------|
| ADR-001 | `"Agent"` in project allowedTools — removes per-use confirmation |
| ADR-002 | `name` field in SKILL.md is canonical identifier; dirs renamed to match |
| ADR-003 | Input Validation section conditional — only when untrusted input present |

---

## Security

No security findings.

---

## Skipped Phases

None.
