---
title: "ADR 004: Hook Script Ownership — Authored in planifest-framework, Contributed Upstream Later"
summary: "Hook scripts are authored and maintained in planifest-framework for this pipeline run. They will be contributed to mksglu/context-mode after the pipeline completes. This is an operational split: planifest-framework owns the wiring; context-mode owns the scripts long-term."
status: "accepted"
version: "0.1.0"
---
# ADR-004 - Hook Script Ownership Split

**Skill:** adr-agent
**Tool:** claude-code
**Model:** claude-sonnet-4-6
**Feature:** 0000001-context-mode-enforcement-hooks
**Component:** context-mode-hooks, setup-hook-integration
**Status:** accepted
**Date:** 2026-04-12

---

## Context

The enforcement hook scripts (`block-grep.sh`, `block-bash.sh`, `block-webfetch.sh`) implement context-mode routing enforcement for Claude Code. Conceptually, these scripts are part of the context-mode project (`mksglu/context-mode`) — they enforce its routing rules. However:

- The context-mode repo is an upstream dependency, not under planifest-framework control
- Contributing to upstream requires a PR and review process that is out of scope for this pipeline
- The scripts must ship with planifest-framework to be installable via `setup.sh`
- If scripts live only in upstream, planifest-framework setup cannot bundle them without an npm/git dependency on context-mode

The question is: where do the scripts live, and who owns them?

---

## Decision

**Scripts are authored in `planifest-framework/hooks/context-mode/` for this pipeline run.** After the pipeline completes, they will be contributed upstream to `mksglu/context-mode` as a separate PR. Long-term, `mksglu/context-mode` is the canonical owner.

During the transition period (before upstream accepts the contribution), planifest-framework is the source of truth. If the scripts diverge after upstream acceptance, planifest-framework's copy takes precedence for planifest users — sync with upstream is a manual operational step tracked in the roadmap.

The `planifest-framework/hooks/context-mode/` directory is the install source. Setup copies scripts from there to `.claude/hooks/context-mode/` in the target project.

---

## Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Author in planifest-framework, contribute upstream later (chosen) | Scripts ship immediately with planifest-framework setup; no external dependency; upstream contribution is decoupled from this pipeline | Two copies exist during the transition period; risk of divergence; upstream may modify the scripts after contribution | Accepted — transition period is bounded; divergence risk is low given small script size |
| Author directly in mksglu/context-mode first, reference via submodule | Canonical ownership from day one; single source of truth | Blocks this pipeline on upstream PR review timeline; submodule adds setup complexity; planifest-framework setup would need to pull from upstream | Rejected — blocks delivery; submodule complexity not justified for 3 small bash scripts |
| Bundle scripts in planifest-framework permanently, never contribute upstream | Full control; no sync dependency | Fragmentation — two independent implementations of context-mode enforcement; context-mode users get no benefit; violates the intended collaboration model | Rejected — planifest-framework does not want to permanently own context-mode enforcement scripts |
| Generate scripts dynamically at setup time (inline in setup.sh) | No separate script files to manage | Inline scripts in setup.sh are unreadable, untestable, and hard to maintain | Rejected — maintainability |

---

## Affected Components

| Component | Impact |
|-----------|--------|
| context-mode-hooks | Source location is `planifest-framework/hooks/context-mode/` — understood to be temporary pending upstream contribution |
| setup-hook-integration | Setup copies from `planifest-framework/hooks/context-mode/` — path is internal to the framework, not a reference to upstream |

---

## Consequences

**Positive:**
- Scripts ship with this pipeline — no external dependency, no blocked delivery
- planifest-framework setup is self-contained; users do not need to separately install context-mode scripts
- Upstream contribution is a clean, bounded follow-up task

**Negative:**
- Two copies exist during the transition: `planifest-framework/hooks/context-mode/` and (eventually) `mksglu/context-mode`. Manual sync required if either diverges after the upstream PR.
- If upstream modifies the scripts (e.g. changes the output schema), planifest-framework users are not automatically updated

**Risks:**
- Upstream rejects or substantially modifies the scripts before accepting the PR — planifest-framework copy becomes the de-facto fork. Impact: low — scripts are small and self-contained; planifest-framework can maintain them indefinitely if needed.
- Upstream contribution is never made — planifest-framework permanently owns scripts that conceptually belong elsewhere. Mitigation: track the contribution in the roadmap with an explicit owner.

---

## Related ADRs

- ADR-001 - related-to (output format must match context-mode's expected hook interface)
- ADR-003 - related-to (blocking strategy should align with context-mode's routing rules philosophy)

---

## Supersedes

- None

## Superseded By

- None

---

*Generated by adr-agent.*
