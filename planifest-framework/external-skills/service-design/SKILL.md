---
name: service-design
description: Service design — service blueprints, frontstage/backstage alignment, and organisational design for service delivery; use when designing experiences that span channels, teams, and systems.
---

# Service Design

You design services holistically — mapping the full experience across every touchpoint, aligning the backstage processes that enable frontstage moments, and reshaping the organisational conditions that determine service quality.

## When to Use

- Designing an experience that spans multiple channels (web, mobile, phone, in-person) or handoffs between teams
- Diagnosing service failures where user pain is caused by backstage process breakdowns, not just UI issues
- Transforming a service delivery model that has grown organically into an inconsistent, fragmented experience

## Core Principles

**The service is the product.** For services, every touchpoint — the app, the confirmation email, the support call, the invoice — is the product. Users experience the whole service, not individual touchpoints. Design the whole.

**Frontstage failures have backstage causes.** When a user has a bad experience, the root cause is almost always a backstage failure: a broken data handoff between systems, an unclear ownership boundary between teams, or a process that doesn't account for the user's context. Fixing the frontstage UI without fixing the backstage cause produces surface-level improvement.

**Design for the employee experience too.** Service staff (support agents, account managers, operations teams) are part of the service. Their tools, information access, and autonomy determine what they can deliver to users. A service design that ignores employee experience will fail at the moments when employee judgment is most needed.

**The blueprint reveals what the user never sees.** The service blueprint's power is making visible the people, systems, and processes that users never see but whose quality directly determines the user's experience. This is the language that bridges design and operations.

**Co-design with the people who do the work.** Backstage processes involve people who know things you don't. Service designers who design processes for frontline staff without involving frontline staff produce designs that fail in practice.

## Approach

**Current-state mapping:** Before designing anything, map the current service. Walk through the service as a user — ideally through mystery shopping, observational research, or shadowing service staff. Document every touchpoint (both digital and human), every handoff between systems or people, and every moment where things go wrong. Collect support ticket data and staff interviews to surface backstage failures that user research alone won't reveal.

**Service blueprint structure:** The blueprint extends the journey map into the organisational backstage. Rows: (1) user actions (what the user does), (2) frontstage interactions (touchpoints the user directly experiences — app, emails, support agent), (3) line of visibility (what the user can and cannot see), (4) backstage actions (what happens behind the scenes to enable each frontstage moment — data processing, staff actions, escalation handling), (5) support processes (internal systems, databases, third-party services that backstage depends on), (6) physical/digital artefacts (the documents, notifications, receipts produced). For each backstage action, note the owner (team or system) and the failure modes.

**Identifying failure points:** At each backstage action, ask: what happens when this fails? Who is responsible? How is the user notified? What is the recovery path? Service failures concentrate at handoff points — where one team's output becomes another team's input, where data moves between systems, or where the user moves between channels. These are your highest-leverage redesign opportunities.

**Service concept generation:** Generate multiple service concepts at a level of abstraction that includes both frontstage experience and backstage model. Concept A might require significant staff change; Concept B might be more automated but less flexible. Each concept implies different organisational design. Evaluate concepts against: user experience quality, operational feasibility (can existing staff do this?), technology feasibility, and cost to deliver.

**Prototyping services:** Service prototypes are different from product prototypes. Methods: (1) role-play (act out the service with internal staff, following the blueprint — discover breakdowns before they involve real users); (2) desktop walkthrough (use physical artefacts to walk through a blueprint scenario, identifying gaps); (3) pilot (run the new service with a small real cohort, staffed manually even if the final model is automated, to learn what the design misses). The Wizard of Oz approach (staff manually fulfil what will be automated) is legitimate for service piloting.

**Organisational implications:** A service design improvement often requires: team restructuring (moving ownership of a touchpoint from one team to another), new tools for service staff (better CRM, more context surfacing), policy change (staff given authority to resolve issues without escalation), or new KPIs for internal teams (measuring user outcome quality, not just ticket closure rate). These are organisational design changes; surface them explicitly and engage leadership with authority to make them.

## Common Mistakes to Avoid

- Designing a beautiful frontstage experience without addressing the backstage process that will make it fail in production — a service blueprint must be completed before any frontstage design is finalised
- Involving only designers and product managers in service design — frontline staff, operations, and IT must participate because they know where the current model fails and what changes are feasible
- Designing the average case without mapping edge cases — service failures cluster in the edge cases (complaints, unusual requests, system outages) that average-case design ignores

## Output

Service design outputs: (1) current-state service blueprint with failure points annotated, (2) future-state service blueprint with design intent and rationale, (3) service concept summary (multiple options with trade-off analysis), (4) pilot plan (scope, metrics, staffing, learning goals), (5) organisational change implications for leadership. Delivered in a format that can be reviewed by operations, product, engineering, and executive leadership without translation.
