---
title: "Risk Register - framework-governance"
status: "draft"
version: "0.1.0"
---
# Risk Register - 0000005-framework-governance

**Feature:** 0000005-framework-governance
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Version:** 0.1.0
**Overall Risk Level:** medium

---

## Risks

| ID | Category | Description | Likelihood | Impact | Mitigation | Status |
|----|----------|------------|------------|--------|-----------|--------|
| R-001 | technical | Sentinel false positive: gate-write blocks plan/current/ writes if `.orchestrator-active` is stale or missing after clean checkout, branch switch, or failed P7 | medium | high — blocks session | Sentinel check must be keyed to feature-id; ship-agent clears it at P7; regression test covers clean-checkout scenario | open |
| R-002 | technical | Sentinel false negative: plan/current/feature-brief.md must always be writable — any path-matching error could block it | low | high — prevents P0 from starting | Explicit allowlist for feature-brief.md in gate-write; covered by NFR-003 regression test | open |
| R-003 | technical | Hook performance regression: existsSync on every Write/Edit call adds latency across all sessions | low | low — sub-millisecond in practice | Benchmark before and after; NFR-001 target < 5ms | open |
| R-004 | technical | Setup sync gap: developer edits `planifest-framework/hooks/` but forgets to re-run setup.ps1/sh — `.claude/hooks/` becomes stale | medium | medium — enforcement silently does not apply | Document re-run requirement; setup should be idempotent and fast enough to run habitually | open |
| R-005 | technical | British English regex in 0002-british-english.md incorrectly flags code identifiers (e.g. `color` in CSS variables, `initialize` in Ruby method names) | medium | medium — spurious corrections damage working code | Migration must check file type and skip lines that are code; human confirmation before each change provides safety net | open |
| R-006 | technical | Avoid list over-reach: a listed avoid-library is the only viable option for a specific language/requirement combination | low | medium — codegen-agent blocks unnecessarily | quirks.md escape hatch allows documented exception | open |
| R-007 | technical | Copilot Agent Hooks (Preview 2025) API differs from the Claude Code PreToolUse/UserPromptSubmit model — copilot.mjs adapter requires redesign | medium | medium — Copilot enforcement not applied until fixed | Adapter degrades gracefully (exits 0) rather than blocking; flag in tool-setup-reference.md | open |
| R-008 | operational | skills-inbox not cleared after processing: stale SKILL.md is re-processed on every phase transition | low | low — orchestrator re-asks classification question | Orchestrator must clear inbox atomically after moving skill | open |
| R-009 | compliance | library-standards content becomes stale as ecosystem evolves — prefer/avoid lists reflect 02 May 2026 state | medium | medium — agents follow outdated guidance | Version-policy doc notes review cadence; `planifest-overrides/library-standards/` allows human correction without a framework release | open |

---

## Assumptions Logged as Risks

| ID | Assumption | Impact if Wrong | Status |
|----|-----------|----------------|--------|
| A-001 | Node.js `fs.existsSync` is available in the hook runtime (consistent with existing gate-write.mjs) | sentinel check fails silently; enforcement not applied | open |
| A-002 | Copilot Agent Hooks accept the same event model as Claude Code PreToolUse/UserPromptSubmit | copilot adapter requires redesign | open |
| A-003 | American→British English corrections in prose do not affect code identifiers or machine-readable fields | unintended identifier renames break tests | open |
