---
title: "Build Report - 0000010-framework-quality-improvements"
date: "2026-05-14"
status: "shipped"
---
# Build Report — 0000010-framework-quality-improvements

## Outcome: ✅ Shipped

All 4 requirements delivered and verified. 20/20 acceptance tests pass.

---

## Delivery Summary

| REQ | Title | Status |
|-----|-------|--------|
| REQ-001 | Input Validation AC section in requirement template | ✅ |
| REQ-002 | Agent tool in allowedTools + parallelism directives | ✅ |
| REQ-003 | Skill directory name normalisation | ✅ |
| REQ-004 | Additional external skills from high-signal repos | ✅ |

---

## Health Metrics

| Metric | Value |
|--------|-------|
| External skills total | 372 |
| Skills added this feature | 196 (sw-agent-skills: 152, marketingskills: 40, garden-skills: 4) |
| Dir name mismatches | 0 |
| Missing attribution.txt | 0 |
| New-repo attributions | 199 |
| Test suite | 20/20 pass |
| Self-corrections in P4 | 3 |

---

## What Changed

### `planifest-framework/templates/requirement.template.md`
Added conditional `## Input Validation` section after `## Dependencies`. Instructs spec-agent to include this section only when the requirement reads untrusted external content into model-visible output. Includes: input source, allowed character pattern, maximum length, failure behaviour, logging policy.

### `planifest-framework/setup.sh` + `setup.ps1`
New `merge_allowed_tools` / `Merge-AllowedTools` function: idempotently adds `"Agent"` to `allowedTools` in `.claude/settings.json` when setting up for Claude Code. Runs after enforcement hook installation. Fixes the root cause of zero Agent spawning: without this, every Agent tool call required per-use confirmation and was never confirmed.

### `planifest-framework/skills/planifest-orchestrator/SKILL.md`
Added `## Agent Dispatch Template` section: explains two levels of parallelism (native tool calls vs Agent spawning), when to spawn vs inline, concrete two-Agent parallel dispatch example with full syntax, self-contained prompt rule, model tier guidance.

### `planifest-framework/skills/planifest-codegen-agent/SKILL.md`
Added `## Parallel Dispatch Checklist`: 6-step pre-implementation checklist forcing the agent to map dependencies and dispatch leaf requirements in parallel before writing any code.

### `planifest-framework/skills/planifest-validate-agent/SKILL.md`
Added `## Pre-Execution Parallelism Plan`: forces the agent to identify independent CI checks and dispatch lint+typecheck in parallel before running tests.

### `planifest-framework/external-skills/`
- 196 new skills extracted from 4 repos (sw-agent-skills, marketingskills, garden-skills)
- 23 duplicate dirs deleted (correctly-named counterpart already existed)
- 134 dirs renamed to match `name:` field in SKILL.md (kebab-case canonical form)
- README regenerated: 2-column skill/description table, 372 rows, sorted alphabetically

---

## ADRs Produced

| ADR | Decision |
|-----|----------|
| ADR-001 | Agent in allowedTools — project-scoped; removes per-use confirmation |
| ADR-002 | name field as canonical skill identifier; dirs renamed to match |
| ADR-003 | Input Validation section conditional — only when untrusted input present |

---

## Recommendations for Next Feature

1. **wondelai-skills repo**: `_temp/wondelai-skills/` returned empty during extraction — verify the repo was cloned correctly before the next skill library sweep.
2. **pricing-strategy / social-content naming collision**: the `marketingskills` repo contains a `pricing-strategy` skill; the existing `pricing-strategy` dir had a different name field. Verify the surviving skill is the better one.
3. **allowedTools scope**: `"Agent"` is now in project allowedTools. If any project needs to restrict Agent use, the human must manually remove it — there is no setup flag to opt out. Consider adding `--no-agent-tool` flag to setup.sh in a future feature.
4. **README auto-generation**: the external-skills README is now manually maintained. Consider a script that regenerates it from SKILL.md files to keep it current as skills change.
