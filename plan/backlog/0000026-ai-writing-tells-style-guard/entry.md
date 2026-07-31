---
title: "Backlog Entry: 0000026 - AI writing-tells style guard for Planifest artifacts"
summary: "No mechanism catches em dashes and other AI writing tells in generated Planifest artifacts before a human sees them; make this an enforced style rule, not something re-discovered per session."
status: "open"
---
# Backlog Entry: 0000026 - AI writing-tells style guard for Planifest artifacts

**Source feature:** 0000020-setup-refresh-skill
**Source phase:** P0 (Scope Lock Challenge)
**Date filed:** 2026-07-31

---

## Problem

During 0000020's Scope Lock Challenge, the human on the loop had to manually correct an em-dash-heavy `planifest-scope-lock-agent` draft and called it out as something that "should be core in Planifest" rather than a one-off fix. No skill, template, or hook currently checks generated prose (scope-lock drafts, feature briefs, ADRs, design.md, requirement docs, commit messages) for em dashes or other characteristic AI writing tells (e.g. "it's not just X, it's Y" constructions, excessive hedging, title-case section headers used as filler). This means every session that produces prose risks reintroducing the same pattern, and correction only happens if the human happens to catch it.

## Suggested Action

Add an explicit style rule to the relevant drafting skills (`planifest-scope-lock-agent`, `planifest-spec-agent`, `planifest-adr-agent`, `planifest-docs-agent`, and the orchestrator's own coaching prose) prohibiting em dashes and listing other common AI writing tells to avoid. Consider a lightweight deterministic check (grep for em dash character, similar to how `commit-msg` already blocks AI attribution and affirmatory language) that can run as part of validate-agent or a pre-commit style, rather than relying on every skill's prose instructions being followed correctly every time.

## Why Deferred

Cross-cutting change across multiple skill files and possibly a new enforcement hook; not blocking 0000020 (the immediate instance was corrected inline). Needs its own design decision on which artifacts are in scope and whether enforcement is a hook (deterministic, like `commit-msg`) or instruction-only (like most style guidance today).
