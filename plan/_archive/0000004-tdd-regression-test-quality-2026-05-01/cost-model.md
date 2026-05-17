---
title: "Cost Model - 0000004-tdd-regression-test-quality"
status: "active"
version: "0.1.0"
---
# Cost Model - 0000004-tdd-regression-test-quality

**Feature:** 0000004-tdd-regression-test-quality

---

## Infrastructure Cost

None. No cloud infrastructure is introduced. All components are local bash scripts and Markdown skill files.

---

## Token Cost (LLM)

The primary cost driver for this feature is the TDD sub-loop: 3 sub-agent invocations per requirement.

| Component | Model tier | Cost impact |
|-----------|-----------|-------------|
| codegen-agent (orchestrator) | Full model | 1× invocation per feature (unchanged from current) |
| planifest-test-writer | haiku-class (cheaper) | 1× per requirement |
| planifest-implementer | haiku-class (cheaper) | 1× per requirement (up to 3× on retry) |
| planifest-refactor | haiku-class (cheaper) | 1× per requirement |

**Estimated cost ratio vs. current (no TDD loop):**
- A feature with N requirements adds ~3N haiku-class sub-agent invocations.
- Haiku-class tokens are roughly 10–20× cheaper per token than full-model (Claude Sonnet/Opus tier).
- Net additional cost per feature: low to medium depending on requirement count.

**Cost boundary:** No hard budget constraint. Cost mitigation is achieved through the cheaper model tier for sub-agents. Operators should monitor token spend on large features (>10 requirements) where the 3× multiplier is most significant.

---

## Storage Cost

Negligible. New files are Markdown skill files, a JSON manifest, and bash scripts. No binary or large data files.
