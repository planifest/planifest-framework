---
title: "ADR-007: Derived Scope Lock Scenarios over Fixed Checklist"
summary: "The Scope Lock Challenge derives happy/sad/bad path scenarios from the specific feature being built rather than using a generic fixed checklist."
status: "accepted"
version: "0.1.0"
---
# ADR-007 - Derived Scope Lock Scenarios over Fixed Checklist

**Skill:** planifest-adr-agent
**Tool:** Claude Code
**Model:** claude-sonnet-4-6
**Feature:** 0000014-improve-adoption-mode-selection
**Component:** planifest-framework
**Status:** accepted
**Date:** 2026-05-19

---

## Context

Analysis of prior pipeline runs showed that scope creep consistently entered the pipeline at P3 (codegen), not at P0. The root cause: the current P0 coaching asks gap-filling questions (what's missing from the brief?) but not scenario-probing questions (what happens when X fails?). The 0000009 feature added REQ-008 mid-P3 because nobody asked "what happens if the session resets mid-pipeline?" at P0.

To address this, a Scope Lock Challenge was designed to run at P0 before design confirmation. Two approaches were considered for generating the scenarios: a fixed checklist of category prompts (first-run, cross-session, error states, upgrade) applied to every feature, or agent-derived scenarios that are specific to what is being built.

---

## Decision

**The Scope Lock Challenge uses agent-derived scenarios.** The orchestrator reads the confirmed requirements and generates scenario questions specific to the feature — not a generic list. For example, a migration feature gets questions about partial failure and archive ordering; a skill file feature gets questions about what happens when the human doesn't load the skill.

A fixed checklist is provided as a fallback guide for the agent (ensuring scenario categories are not systematically skipped) but is not presented verbatim to the human. The agent synthesises the relevant scenarios from that guide and the feature context.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Fixed checklist (same 4 questions every feature) | Zero agent reasoning required; consistent coverage | Becomes a checkbox exercise; humans learn to answer quickly without thinking; irrelevant questions for some features | Rejected — predictable questions invite predictable dismissal |
| Agent-derived scenarios (this decision) | Feature-specific; harder to dismiss; surfaces real gaps | Agent may miss a scenario category; derivation quality varies | Chosen — probing questions are more effective than generic ones |
| Human-authored scenarios only (Feature Brief template) | Human already knows the feature best | Humans often don't know what they don't know; same gap that caused 0000009's REQ-008 | Not sufficient alone — REQ-017 adds this as a complement, not a replacement |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| planifest-orchestrator skill | Scope Lock Challenge step added with derivation protocol |
| feature-brief.template.md | Scenario Paths section added as complement (REQ-017) |

---

## Consequences

**Positive:**
- Scenario questions are harder to dismiss because they are specific to the feature
- Agent demonstrates understanding of the feature by asking relevant questions
- More scope gaps caught at P0 where they are cheapest to address

**Negative:**
- Agent scenario derivation may miss categories if the feature is novel or unfamiliar
- Quality of the challenge depends on agent reasoning quality

**Risks:**
- The Feature Brief Scenario Paths section (REQ-017) and the Scope Lock Challenge are complementary; if the Feature Brief is skipped, the Scope Lock Challenge is the only gate — its quality becomes more critical

---

## Related ADRs

- ADR-008 — related-to (one-question rule applies throughout the challenge)

---

## Supersedes

- None

## Superseded By

- None
