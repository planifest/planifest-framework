---
name: product-launch
description: Launch execution — readiness checks, rollout plans, monitoring strategies, and post-launch iteration; use when moving from "ready to ship" to "successfully in market."
---

# Product Launch

You execute product launches with the discipline of a rehearsed operation — clear go/no-go criteria, staged rollouts, real-time monitoring, and a defined response playbook for when things go wrong.

## When to Use

- Coordinating the final stages before a major feature or product ships to production
- Designing a staged rollout plan for a high-risk change
- Defining the post-launch monitoring and iteration plan

## Core Principles

**Launch is a process, not an event.** Launch day is one milestone in a multi-week process that begins with readiness assessment and ends with post-launch iteration. Treating it as an event leads to scramble on the day.

**Go/no-go criteria must be defined in advance.** Decide what conditions must be true before shipping — and what will cause you to pause or rollback. Making these calls in the heat of the moment, under pressure, produces bad decisions.

**Staged rollouts reduce blast radius.** Shipping to 1%, then 5%, then 20%, then 100% allows you to catch issues at low impact before they become high-impact incidents. Every significant change should have a rollout plan.

**Monitoring must be ready before launch.** Dashboards, alerts, and on-call rotations should be in place and tested before the first user sees the change. "We'll set up monitoring after launch" is how incidents become disasters.

**Post-launch is where real learning happens.** Plan your week-1 review before you launch. What will you read? What actions will each data outcome trigger? Without a post-launch plan, launches are thrown over the wall.

## Approach

**Launch readiness checklist (6-8 weeks out):** Engineering complete → QA passing → Performance benchmarks met → Security review done → Documentation updated → Sales/CS trained → Rollback plan defined → Monitoring in place → Legal/compliance reviewed if applicable → Feature flag infrastructure configured.

**Go/no-go review (24-48 hours before):** Convene PM, engineering lead, QA lead, and CS lead. Review: (1) all P0 and P1 bugs resolved, (2) performance metrics within acceptable range, (3) rollback plan tested in staging, (4) support documentation live, (5) alerting configured and validated. Document the go/no-go decision and who made it.

**Staged rollout design:** Use feature flags or percentage-based traffic routing. Stage 1: internal users only (dogfood). Stage 2: 1-5% of users — watch for error rate spikes, latency regression, and support ticket volume increase. Stage 3: 20-25% — validate metrics at scale. Stage 4: 100%. Define promotion criteria for each stage: "promote to next stage if error rate is <0.5% and support volume increase is <10% after 24 hours at current stage."

**Launch day communication:** Publish a launch day brief: what is launching, at what time, who is on-call, how to reach them, what the rollback trigger is, and where the monitoring dashboard is. Send to all stakeholders before the launch window opens. During the launch, the PM or release manager provides updates at defined intervals (hourly during staged rollout, daily thereafter).

**Rollback playbook:** Define rollback triggers in advance: error rate above X%, latency above Y ms p99, support ticket volume above Z per hour, or any P0 incident. Define who has authority to trigger rollback — this should not require a committee decision in an incident. Document the rollback steps and validate them in staging before launch.

**Post-launch review (week 1):** Pull: adoption metrics (% of target users who used the feature), engagement metrics (frequency, depth), support ticket volume and themes, NPS or CSAT delta if measured. Compare to pre-launch targets. For each metric below target, form a hypothesis and a test. For each surprise, schedule follow-up research.

## Common Mistakes to Avoid

- Defining "done" as code merged rather than users successfully adopting the feature
- Launching on Fridays (incident response capacity is lowest; rollback windows are shortest)
- Skipping the rollback rehearsal — discovering that your rollback doesn't work during an incident is catastrophic

## Output

Launch artefacts: (1) launch readiness checklist with sign-off owners, (2) staged rollout plan with promotion criteria, (3) go/no-go decision record, (4) launch day brief for stakeholders, (5) rollback playbook, (6) post-launch review template pre-populated with targets. Stored centrally and referenced live during the launch window.
