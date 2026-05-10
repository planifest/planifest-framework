---
name: product-discovery
description: Discovery process — hypothesis generation, experiment design, and learning velocity; use when exploring problem/solution space before committing to build.
---

# Product Discovery

You run discovery as a disciplined process of generating and rapidly invalidating hypotheses — designing the smallest possible experiments that produce the clearest learning before committing engineering capacity to build.

## When to Use

- Before writing a spec for a significant new feature or product area
- When there is genuine uncertainty about whether the problem is real, the solution will work, or users will adopt it
- When a previous initiative underperformed and root-cause analysis points to assumptions that were never validated

## Core Principles

**Discovery is risk reduction.** The goal is to identify and kill bad ideas cheaply before they consume months of engineering time. Every discovery activity should be measured by how much risk it eliminates.

**Separate problem validation from solution validation.** First confirm the problem is real and worth solving. Then, and only then, explore whether your solution approach works. Mixing these produces premature commitment to solutions.

**Hypotheses before experiments.** Write the hypothesis before designing the experiment: "We believe [assumption]. We'll know this is true if [observable evidence] within [time period]." This prevents post-hoc rationalisation of ambiguous results.

**The fastest invalidation wins.** A fake door test that takes 2 days is better than a prototype that takes 2 weeks if it produces the same signal. Default to the smallest, cheapest experiment that will give you a confident answer.

**Discovery never stops.** Discovery is not a phase before development; it runs continuously alongside delivery. Allocate dedicated capacity (the "dual-track" model: one track builds, one track discovers what to build next).

## Approach

**Risk taxonomy:** Before designing experiments, identify the riskiest assumptions. Marty Cagan's four risk types: (1) value risk (will users want this?), (2) usability risk (can users figure it out?), (3) feasibility risk (can we build it?), (4) business viability risk (does it work for our business model?). The highest-risk assumption gets tested first.

**Assumption mapping:** List all the beliefs embedded in your initiative. Example: "Users experience X problem" (do they?), "They experience it frequently enough to justify a new tool" (do they?), "They would be willing to pay $Y for a solution" (would they?). Stack-rank by risk (how wrong we'd be if false × how confident we currently are). Test the lowest-confidence, highest-impact assumptions first.

**Experiment types by speed and fidelity:** Fastest: analytics (existing data), customer interview (1-2 days), fake door/404 test (2-3 days, measure click-through on a feature that doesn't exist yet). Medium: landing page with signup, Wizard of Oz test (human fulfils the backend manually while user interacts with a UI), paper prototype. Slower but higher fidelity: clickable prototype, concierge MVP (manually do the service to learn before automating), technical spike (for feasibility). Match the experiment type to the question.

**Story mapping for solution validation:** Before building, map the user's journey step by step. Identify the minimum slice that delivers value (the "walking skeleton"). Prototype just that slice. Test: do users understand it, complete it, and find it valuable? Discover usability issues before code exists.

**Learning documentation:** For each experiment: hypothesis → method → results → confidence level → decision (build / iterate / kill / more research needed). Log these in a shared discovery board. This creates institutional memory and prevents teams from running the same experiment twice.

**Dual-track cadence:** Discovery (typically PM + designer) runs 2-4 weeks ahead of delivery (engineering). Weekly discovery review shares findings with the engineering team — engineers should see what was learned, not just what to build next. This catches feasibility issues early and builds team investment in the discovery process.

## Common Mistakes to Avoid

- "Discovering" only to validate a solution you've already committed to — this is confirmation-seeking, not discovery
- Running experiments too long: a fake door test should run for days, not weeks; ambiguous results after the planned period mean you need a different experiment
- Discovery outputs that never connect to delivery: if insights sit in a research report and don't influence the spec or roadmap, the discovery process is broken

## Output

Discovery produces: (1) an assumption map with risk ranking, (2) an experiment log with hypothesis, method, results, and decision for each experiment, (3) a validated (or invalidated) problem statement, and (4) a solution direction brief with enough confidence to justify spec-writing. Not a final spec — that comes after discovery.
