---
name: feature-prioritization
description: Prioritisation frameworks — RICE, MoSCoW, opportunity scoring, and trade-off articulation; use when deciding what to build next from a large backlog.
---

# Feature Prioritization

You bring structured rigor to prioritisation decisions — using frameworks as inputs to judgment, not substitutes for it, and making trade-offs explicit so stakeholders can align.

## When to Use

- Backlog grooming when demand far exceeds capacity
- Quarterly planning where strategic bets must be balanced against maintenance and requests
- Stakeholder disagreements about what matters most — creating a shared basis for the conversation

## Core Principles

**Frameworks score; humans decide.** RICE, MoSCoW, and opportunity scoring are scaffolding. They surface information and create comparability. The final call requires strategic judgment that no formula captures.

**Opportunity cost is the real question.** Every yes is a no to something else. When evaluating a feature, ask: "What are we not building if we build this?" That's the true cost.

**Confidence is a first-class input.** A high-impact initiative with 20% confidence is often worse than a moderate-impact initiative with 90% confidence. Uncertainty should deflate your estimate, not be ignored.

**Separate urgency from importance.** The most urgent requests are often the least important. Build a forcing function: "If we don't do this by date X, consequence Y occurs" — if they can't fill it in, urgency is manufactured.

**Reversibility matters.** Prefer reversible decisions when uncertain. A feature that takes 2 weeks but can be rolled back is lower risk than a 3-month initiative that can't be undone.

## Approach

**RICE scoring:** Reach (how many users per time period) × Impact (0.25/0.5/1/2/3 scale per user) × Confidence (% as decimal) / Effort (person-weeks). RICE is best for comparing features within a similar strategic domain. Beware: RICE scores compress qualitative judgment into a number that looks more objective than it is. Use it to stack-rank, then apply strategic overlay.

**MoSCoW for scope decisions:** Must-have (without this, the release has no value), Should-have (important but not critical for launch), Could-have (nice to have if time allows), Won't-have (explicitly not this release). MoSCoW is most useful for release scoping, not strategic prioritisation — it defines minimum viable scope, not strategic order.

**Opportunity scoring (Ulwick):** For each job-to-be-done, survey customers on importance (1-10) and satisfaction with current solutions (1-10). Opportunity score = importance + max(importance - satisfaction, 0). High-importance, low-satisfaction areas are your best opportunities. This grounds prioritisation in jobs rather than features.

**Kano model:** Classify features as: Basic (expected — absence causes dissatisfaction, presence is neutral), Performance (more is better — linear satisfaction), and Delight (unexpected — absence is neutral, presence causes delight). Basics must be done first; Delight features should be saved for when Basics and Performance features are solid. Asking customers "how would you feel if this feature existed/didn't exist" maps to Kano categories.

**Strategic overlay:** After scoring, apply strategic filters: Does this advance an H2/H3 bet? Does this help win in our target ICP? Does it create a technical foundation that unlocks future work? A lower-scoring item can move up if it's strategically load-bearing.

**Articulating trade-offs:** When recommending a prioritisation, make the trade-offs explicit: "If we choose A over B, we are accepting that [customer segment] will remain underserved for another quarter, and we risk [specific competitive threat]." Named trade-offs produce better decisions than hidden ones.

## Common Mistakes to Avoid

- Running RICE on everything including bugs, tech debt, and strategic initiatives — different categories need different frameworks
- Letting vocal stakeholders override scoring without a documented rationale, which destroys the framework's credibility over time
- Scoring without a defined time horizon — "reach" in RICE means nothing without specifying whether it's per week, month, or quarter

## Output

A prioritisation output has: (1) scored backlog with methodology noted, (2) recommended sequencing with rationale, (3) explicit trade-offs accepted, (4) what's been deferred and why. Fit for a 15-minute leadership review. The reasoning — not just the ranking — is the deliverable.
