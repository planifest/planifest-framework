---
title: "Requirement: req-001 - Ship-agent PR footer"
summary: "Detailed requirements for this specific functional feature."
status: "draft"
version: "0.1.0"
---
# Requirement: req-001 - Ship-agent PR footer

**Skill:** [spec-agent](../skills/planifest-spec-agent/SKILL.md)
**Feature:** 0000025-pipeline-gate-and-config-fixes-and-ship-agent-fixes
**Source:** US-001
**Priority:** should-have

## User Story

> One requirement doc = one user story.

As a human on the loop, I want the ship-agent's PR description template to omit the AI-attribution footer by default, so that I don't have to manually strip it from every PR.

## Functional Requirements
- Step 10's Option [2] ("Human pushes") PR description template must not include the hardcoded AI-attribution line `🤖 Generated with [Planifest](https://github.com/planifest/framework) + Claude`, or any equivalent, by default.
- Step 10's Option [1] ("Agent pushes") `gh pr create --body` construction, which shares the same "PR description — see template below" body, must produce the same footer-free output by default.
- Before rendering the PR description (either option), Step 10 checks `planifest-overrides/instructions/` for a repo instruction that opts back into attribution, mirroring the existing local-git-only check already performed at the top of Step 10, and includes the footer only when such an instruction is present. The exact instruction file/keyword this checks for is a P2 ADR decision (see Dependencies); absent any such instruction, the default is no footer.
- All other PR description template sections (Summary, Key Decisions, Security, Skipped Phases, Test Plan) are unchanged in content and order.

## Acceptance Criteria
- [ ] `planifest-ship-agent/SKILL.md` Step 10 Option [2]'s markdown template (currently the line `🤖 Generated with [Planifest](https://github.com/planifest/framework) + Claude`) has the footer removed or made conditional — not unconditionally present.
- [ ] Step 10 Option [1]'s `gh pr create --body` path shares the updated template, so a PR opened directly by the agent also has no unconditional footer.
- [ ] With no matching repo instruction present in `planifest-overrides/instructions/`, a PR description generated via either option contains no AI-attribution line.
- [ ] SKILL.md documents where a future repo instruction could opt back into the footer, with the exact trigger condition left to the P2 ADR for this feature.
- [ ] No other Step 10 template section (Summary, Key Decisions, Security, Skipped Phases, Test Plan) changes in content or order.

## Dependencies
- P2 ADR decision on the exact opt-in override mechanism/keyword for restoring the attribution footer (design.md Scope > Deferred: "PR-footer toggle mechanism (hardcoded removal vs. `planifest-overrides/instructions/`-gated)").
- Shares `planifest-ship-agent/SKILL.md` with the US-002 requirement (P7 archive `git add` fix) — no functional dependency, but both requirements touch the same file and should avoid conflicting edits (Step 10 vs. Step 7).
