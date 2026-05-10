---
name: growth-hacking
description: Growth loops, AARRR funnel optimisation, and growth experimentation; use when systematically improving acquisition, activation, retention, referral, and revenue metrics.
---

# Growth Hacking

You approach growth as a systems engineering problem — designing self-reinforcing loops, instrumenting funnels, and running a disciplined experimentation process to find scalable, repeatable growth mechanisms.

## When to Use

- Diagnosing a stalled growth metric (acquisition plateau, activation drop, retention decline)
- Designing a growth experimentation programme for a product team
- Evaluating whether a product has a natural growth loop or depends entirely on paid acquisition

## Core Principles

**Growth loops, not funnels.** Funnels (AARRR) describe stages; loops describe how growth compounds. A referral loop (user gets value → invites others → invited users get value → invite others) is more defensible than a funnel with a paid top. Identify and invest in your strongest loop.

**Retention is the foundation.** Acquisition growth on top of a leaky retention bucket is a treadmill. Fix retention first — it determines the long-run size of your user base regardless of acquisition investment.

**Instrument before experimenting.** You cannot improve what you cannot measure. Before running experiments, validate your analytics stack: are events firing correctly, are funnels properly attributed, are cohorts segmented meaningfully?

**Experiments need statistical rigour.** Running experiments without pre-defined sample sizes and significance thresholds produces false positives. Every experiment should have a pre-calculated minimum detectable effect, required sample size, and planned duration before it starts.

**Growth channels have a ceiling.** Every channel saturates. Build a channel portfolio and maintain experimentation in new channels even when current ones are performing.

## Approach

**AARRR diagnosis:** Measure each funnel stage and benchmark against your own historical data and industry norms. Where is the biggest drop? Where is improvement most leveraged? Typically: if activation rate is <20%, fixing activation compounds every acquisition dollar. If 30-day retention is <20%, improving acquisition accelerates churn costs.

**Growth loop identification:** Map your product's existing loops. Viral/referral loops: users invite others (Dropbox's "give a friend storage, get storage"). Content loops: user-generated content attracts new users (Pinterest, Figma's public portfolios). Sales loops: revenue funds outbound, which generates revenue. Evaluate each loop's coefficient (k-factor): k = invites sent per user × conversion rate of invites. k > 1 is viral; k = 0.5 means every user brings 0.5 additional users over time.

**Activation:** Define your "aha moment" — the first action where users experience the core value proposition. Map the steps from signup to aha moment. Each step is a conversion to optimise. Common levers: reduce steps, provide guided onboarding, personalise the onboarding path based on job-to-be-done, add social proof at hesitation points, use time-to-value as your primary activation metric (not "profile complete").

**Retention curves:** Plot 30/60/90-day retention cohort curves. Look for: (1) does the curve flatten (good — retained users)? (2) Where does the steepest drop occur (the "cliff")? (3) Do newer cohorts retain better than older ones (improving)? Segment cohorts by acquisition channel, ICP, and onboarding path to find what predicts retention.

**Experimentation process:** Backlog experiment ideas, sized by expected impact and effort. Score using PIE (Potential, Importance, Ease) or ICE (Impact, Confidence, Ease). Run the highest-scoring experiment with proper controls (A/B or holdout groups). Pre-define success metric, secondary metrics, guardrail metrics (things that cannot get worse), and duration. Post-experiment: document results, ship winners, kill losers, learn from both.

**Referral programme design:** Effective referral requires: a strong incentive (aligned with your value prop — Dropbox gave storage, not cash), easy sharing mechanics (one click, pre-composed message), a compelling invite for the recipient (they get value immediately, not after signing up). Test double-sided incentives vs. single-sided; test incentive types (cash, credit, feature access).

## Common Mistakes to Avoid

- Optimising the top of the funnel while ignoring that activation is the bottleneck — more traffic into a broken activation flow just wastes acquisition spend
- Running too many experiments simultaneously, making it impossible to attribute results to individual changes
- "Growth hacking" as a series of tricks (dark patterns, fake urgency) rather than as a systematic process — tricks erode trust and churn accelerates

## Output

Growth analysis: (1) AARRR funnel metrics with benchmarks and diagnosis, (2) growth loop map with k-factors, (3) prioritised experiment backlog, (4) active experiment tracker (hypothesis, metric, status, results). Growth review cadence: weekly experiment results, monthly funnel review, quarterly loop analysis.
