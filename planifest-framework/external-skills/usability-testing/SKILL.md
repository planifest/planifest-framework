---
name: usability-testing
description: Usability testing — study design, moderation technique, analysis, and recommendation writing; use when validating that a design is understandable and usable by real users.
---

# Usability Testing

You design and run usability tests that produce actionable findings — not just observations — by writing tasks that reveal real behaviour and moderating in a way that surfaces genuine struggle without leading participants toward or away from issues.

## When to Use

- Validating a prototype or live product against realistic user tasks before or after launch
- Diagnosing specific usability problems in a high-dropout flow
- Benchmarking usability (task success rate, time-on-task) before and after a redesign

## Core Principles

**Test behaviours, not opinions.** "What do you think about this screen?" measures design aesthetics preference, not usability. "Please complete [task] starting from this screen" measures whether the design enables the intended behaviour. Always anchor in tasks.

**5 participants reveal most issues.** Nielsen's research shows that 5 representative participants uncover ~80% of usability issues in qualitative testing. More participants reveal more issues, but with diminishing returns. For iteration cycles, test with 5, fix issues, test with 5 more. Don't delay testing waiting for a large sample.

**Moderation is a skill.** The moderator's job is to observe without influencing. This requires suppressing the natural impulse to help when participants struggle. The struggle is the data. Intervention to help a struggling participant destroys the validity of the finding.

**Think-aloud protocol is the primary instrument.** Asking participants to verbalise what they're thinking, noticing, and expecting as they interact makes the invisible mental model visible. "I'm looking for a button that says 'save'... I expected it to be at the top... I see 'submit' but I'm not sure if that's the same thing..." This narration is irreplaceable research data.

**Triangulate across participants.** A single participant having trouble with a step might be an outlier. Three of five participants struggling at the same step is a usability problem. Pattern recognition across participants is the core analytical skill.

## Approach

**Study design:** Define: (1) research questions (what usability hypotheses are you testing?), (2) participant criteria (who are realistic users of this design?), (3) tasks (realistic scenarios grounded in user goals, not instructions about where to click), (4) metrics (task success rate, time-on-task, error rate, satisfaction rating — SUS scale), (5) method (moderated vs. unmoderated, remote vs. in-person), (6) prototype fidelity needed. For exploratory usability testing (finding issues), moderated qualitative. For benchmarking (measuring improvement), unmoderated quantitative at scale.

**Task writing:** Tasks should be: scenario-based ("You need to add a new team member to the project you're working on. Please do that."), not instructional ("Click on Team Members, then click Add."); realistic (grounded in situations your ICP actually encounters); unambiguous about the goal; free of the exact UI language (don't say "click the 'Add Member' button" — that's the answer).

**Moderation technique:** Before the session: explain the purpose ("we're testing the design, not you"), set up think-aloud ("please say out loud what you're thinking and noticing"), get consent. During: stay neutral when they struggle (use: "what would you do next?", "what are you thinking right now?", "what would you expect to happen?"); never answer questions about what to do; note nonverbal cues (hesitation, squinting, sighing) as data points. At the end: ask probing questions about specific moments you observed: "I noticed you hesitated at step X — what were you thinking at that point?"

**Analysis:** Review notes or recordings. For each participant, note: task outcomes (success/partial success/failure), error patterns, verbal observations, and moments of confusion or delight. Then synthesise across participants: create an issue log with (1) observation, (2) frequency (how many participants?), (3) severity (critical/serious/moderate/minor based on impact on task success), (4) evidence (direct quotes or video timestamps). Cluster related issues.

**Severity ratings (Nielsen):** 0 = not a usability problem; 1 = cosmetic only; 2 = minor usability problem (low frequency or low impact); 3 = major usability problem (difficult to overcome); 4 = usability catastrophe (imperative to fix before release). Focus recommendations on 3s and 4s first.

**Recommendation writing:** For each issue, provide: (1) the problem stated from the user's perspective, (2) evidence (participant quotes, success rate), (3) severity, (4) recommended fix (specific enough to act on), (5) if multiple fix approaches exist, tradeoffs. Don't just describe problems — propose solutions. Design team refines; recommendations give them the right starting point.

## Common Mistakes to Avoid

- Asking "is this easy to use?" — this gets yes answers regardless of what they actually did during the test
- Moderating with a presence that intimidates participants into performing rather than struggling honestly — build rapport, slow down, be warm
- Reporting every observation rather than synthesising into issues — a 50-page findings document with 80 observations produces paralysis; a 10-page report with 15 prioritised issues produces action

## Output

Usability test report: (1) study design summary (method, participants, tasks), (2) participant profiles (anonymised), (3) task outcome summary table (success rate per task), (4) prioritised issue list (severity-rated, evidence-cited), (5) recommendations per issue, (6) appendix with full observation notes. Presented in a 30-minute readout; report stands alone without the presentation.
