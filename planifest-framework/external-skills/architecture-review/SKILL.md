---
name: architecture-review
description: Architecture review skill — conduct structured reviews using quality attribute scenarios, ATAM-derived techniques, fitness functions, and risk identification to produce actionable findings; use when a design needs independent validation before build commitment.
---

# Architecture Review

You conduct structured architectural reviews that identify risks, validate quality attribute satisfaction, and surface trade-offs — producing prioritised, actionable findings rather than generic observations.

## When to Use

- Reviewing a proposed architecture before significant build investment is committed
- Evaluating a system for a specific quality attribute that is at risk (performance under load, security model, availability under failure)
- Conducting a periodic fitness review of an existing system against evolved requirements
- Validating that an architectural decision record's stated trade-offs reflect reality
- Reviewing a vendor or third-party architecture for a procurement decision

## Core Principles

**Quality Attribute Scenarios Drive the Review.** A review without specific, measurable quality attribute scenarios (QAS) produces only generic observations. Before reviewing, elicit and agree on the QASs that matter: "The checkout flow responds in under 300 ms at p99 under 5,000 concurrent users during peak." Every finding in the review should trace to a QAS. Findings not traceable to a scenario are opinions, not risks.

**ATAM Elicits Sensitivity Points, Trade-off Points, and Risks.** The Architecture Tradeoff Analysis Method (ATAM) provides a structured vocabulary for review findings. A sensitivity point is an element of the architecture that, if changed, significantly affects one quality attribute. A trade-off point affects two or more quality attributes in opposite directions. A risk is an architectural decision that may not satisfy a quality attribute scenario under plausible conditions. Non-risks are decisions that have been analysed and found acceptable. Using this vocabulary produces shareable, comparable findings across reviews.

**Fitness Functions Enable Continuous Review.** A fitness function is an automated test or metric that verifies an architectural property continuously. Examples: a ArchUnit test that fails if the dependency rule is violated; a SLO alert that fires when p99 latency exceeds the QAS threshold; a mutation coverage threshold that prevents test erosion. The goal of a review is not only to identify current risks — it is to leave behind fitness functions that prevent regression.

**Risk Priority Must Account for Probability and Impact.** A finding is high-priority only when both probability of failure and impact of failure are high. A risk with catastrophic impact but negligible probability (a one-in-a-million load pattern) may be deferred. A risk with moderate impact and near-certain probability under forecast conditions is high priority. Risk prioritisation that ignores probability produces a backlog of unfixable hypotheticals.

**Reviews Are Point-in-Time; Requirements Drift.** An architecture reviewed six months ago against requirements that have since changed is not reviewed — it is stale. Specify the requirements context at which the review was conducted. When requirements change materially, trigger a re-review of affected areas. Architecture fitness degrades continuously; reviews confirm a state at a moment in time, not forever.

## Approach

Before the review, collect artefacts: architecture documents, ADRs, component diagrams (ideally C4), deployment topology, data flow diagrams, and performance/availability requirements. Without these, the review is a conversation, not an analysis. Request that the architecture team prepare a 15-minute walkthrough covering system context, key architectural decisions, and known risks. This surfaces the architecture team's own assessment, which the review then validates or challenges.

Elicit quality attribute scenarios in a structured workshop. Use the format: source of stimulus → stimulus → environment → artifact → response → response measure. For each stakeholder group (end users, operators, developers, security team), identify the top three quality attributes they care about most. Combine into a prioritised QAS list. If the list exceeds 10 scenarios, stack-rank and focus the review on the top five.

Walk each QAS through the architecture. For each scenario, ask: which architectural elements are involved when this stimulus occurs? How does data flow through those elements? What are the latency, error, and resource contributions at each step? Can the architecture satisfy the response measure, and under what conditions does it fail to do so? Identify the elements that are most sensitive to the scenario's requirements — these are sensitivity points.

Map trade-offs explicitly. For each significant architectural decision (synchronous vs async communication, shared vs isolated databases, monolith vs services), enumerate: which quality attribute does this decision favour, and which does it compromise? Present the trade-off table to stakeholders. Trade-offs that stakeholders are unaware of are unvalidated risks — the stakeholder may have prioritised differently if they had known.

Produce a prioritised risk register. For each identified risk: description, affected QAS, probability (Low/Medium/High), impact (Low/Medium/High), priority (product of probability and impact), and recommended mitigation. Group risks by architectural area. Provide specific, actionable mitigations — not "consider improving performance" but "add a Redis cache in front of the product catalog service; implement cache-aside with a 60-second TTL to reduce database load from the catalog read QAS."

Leave behind fitness functions for each high-priority risk. A risk without a fitness function will recur. Define the automated check, who owns it, where it runs, and what failure threshold triggers an alert.

## Common Mistakes to Avoid

- **Reviewing without scenarios.** A review that produces findings like "the system may have scaling issues" without a specific scenario and measurable threshold is not actionable. Every finding must name a specific QAS it threatens.
- **Consensus-seeking review panels.** A review where participants avoid naming findings to preserve relationships produces a false-clean result. Designate an independent reviewer with no stake in the design. Findings are about the architecture, not the architect.
- **Focusing only on the happy path.** Reviews that validate only nominal operation miss the failure modes that cause incidents. Walk through: What happens when the database is unavailable? When the message queue is at capacity? When a downstream service returns 503? When a malicious actor submits a valid but malformed payload?
- **Findings without prioritisation.** A list of 40 findings of equal weight is useless to a team deciding what to fix this sprint. Prioritise by probability × impact; present the top five with recommended mitigations.
- **No follow-up mechanism.** A review without a scheduled follow-up to verify mitigations have been implemented is advisory with no accountability. Set a checkpoint date at which high-priority findings must be resolved or formally accepted.

## Output

Architecture review output includes: quality attribute scenario list (prioritised); sensitivity points per QAS; trade-off analysis table (decision, quality attributes affected, direction of trade-off); risk register (risk, QAS, probability, impact, priority, mitigation); non-risks (decisions analysed and accepted); fitness function specifications for high-priority risks; and a follow-up checkpoint plan with risk owners.
