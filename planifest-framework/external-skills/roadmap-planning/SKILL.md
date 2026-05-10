---
name: roadmap-planning
description: Building and maintaining product roadmaps — sequencing, dependency management, and stakeholder communication; use when turning strategy into a prioritised delivery plan.
---

# Roadmap Planning

You build roadmaps that function as decision frameworks, not Gantt charts — communicating intent and sequencing without over-committing to dates that will change.

## When to Use

- Creating or refreshing a quarterly or annual product roadmap
- Sequencing features with complex technical or go-to-market dependencies
- Communicating delivery plans to engineering, sales, executives, or customers

## Core Principles

**Roadmaps communicate priorities, not promises.** A roadmap is a current best guess at sequencing, not a contract. Communicate this explicitly to avoid trust destruction when plans change.

**Sequencing is a skill.** The order features ship matters — it affects what you learn, what technical foundations are in place, and what the market sees. Ship things that unlock other things first.

**Dependencies are risks.** Every cross-team dependency is a potential slip. Make dependencies visible; don't bury them in a column no one reads.

**Near is precise; far is fuzzy.** Now/next/later (or quarters for near-term, themes for long-term) matches your confidence level to your communication. Fake precision at 12 months is worse than honest fuzziness.

**The roadmap is a living document.** A roadmap that isn't updated quarterly is archaeological evidence, not a plan.

## Approach

**Roadmap format selection:** Choose format based on audience. Internal engineering teams need enough detail to spot dependencies and estimate. Executives need outcomes and strategic themes. Customers and sales need confidence that key problems are addressed, not dates they'll use as commitments. Use a theme-based roadmap (outcome-labelled swim lanes) for external; a feature-level roadmap with owners and status for internal.

**Now/Next/Later framing (Janna Bastow model):** "Now" = actively being built; "Next" = committed for next cycle; "Later" = intention but not committed. This forces honest conversation about what is actually prioritised and prevents the "everything is Q2" trap. Items move right when new priorities displace them — make the trade-off explicit.

**Dependency mapping:** Before finalising sequence, draw a dependency graph. Technical dependencies (A must ship before B can start), team dependencies (platform team must complete API for feature team to use), and go-to-market dependencies (feature needs sales training before launch). Critical path items need buffers. Items with no dependencies are your acceleration levers.

**Buffer and slack:** Build slack into every quarter — 80% planned capacity minimum to absorb discovered complexity, bugs, and urgent requests. Teams that plan to 100% always slip. Communicate this to leadership as a feature, not a failure.

**Roadmap reviews:** Monthly internal sync to update status and re-sequence if needed. Quarterly external update (customers, sales) with a clear narrative about what changed and why. "We moved X to later because we learned Y" is credible; silent disappearance of promised items is not.

**Stakeholder input:** Run a structured "opportunity backlog review" quarterly — collect requests from sales, CS, marketing, and engineering, cluster them by theme, and stack-rank with explicit criteria. Don't let the loudest voice in the room determine the roadmap; use data and strategy to anchor decisions.

## Common Mistakes to Avoid

- Date-locking every item in a 12-month roadmap, then defending dates instead of decisions when reality changes
- Roadmaps that are feature lists without outcome context — sales needs to know "why" as much as "what"
- Ignoring technical debt on the roadmap — it compounds and eventually derails feature work anyway

## Output

A roadmap artefact has: (1) a one-paragraph narrative explaining the period's strategic theme, (2) a visual now/next/later or quarterly grid, (3) outcome labels on each item (what metric it affects), (4) dependency callouts, (5) explicit "not this period" list. Exportable to slide format. Updated in-place, not versioned into oblivion.
