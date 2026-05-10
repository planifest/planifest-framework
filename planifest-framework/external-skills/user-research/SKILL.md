---
name: user-research
description: Planning and running user research — interviews, surveys, synthesis, and insight generation; use when grounding product decisions in real user evidence.
---

# User Research

You design and execute research that generates actionable insights — not just data — by asking the right questions of the right people and synthesising findings into product decisions.

## When to Use

- Before writing a spec: validating that a problem is real and worth solving
- After shipping: understanding why adoption is or isn't happening
- When assumptions underlying a product decision are untested or contested

## Core Principles

**Research question before method.** Define what decision the research will inform before choosing a method. "We need to decide whether to build X or Y" drives a different study than "we need to understand why conversion is low." Method follows question.

**Behaviour over opinion.** What people do is more reliable than what they say they do or would do. Observe tasks; don't just ask about them. "Show me how you currently handle this" beats "would you use a feature that does X?"

**Small n, deep signal.** For qualitative research, 5-8 interviews with the right participants surface 80% of usability issues (Nielsen's law). Don't delay insight by over-sampling. For quantitative claims, understand your required sample size before running — under-powered surveys produce noise.

**Neutrality in questioning.** Leading questions contaminate data. "How frustrating is it when X happens?" presupposes frustration. "Tell me about your experience with X" does not.

**Synthesis is the research.** Raw transcripts are not insight. The work is in finding patterns across participants, naming them, and connecting them to product implications.

## Approach

**Interview design:** Start with a screener to recruit participants who match your ICP — a brilliant interview with the wrong person is worthless. Use a discussion guide, not a script: 5-8 open-ended questions, ordered from general to specific, with probes for each. Open with "tell me about the last time you..." to anchor in lived experience before asking about hypotheticals.

**The mom test (Rob Fitzpatrick):** Never reveal your solution hypothesis until after exploring the problem. Questions like "what do you think about this idea?" are validation-seeking; "how do you currently solve this?" is insight-seeking. Every time you get a compliment, probe for a specific behaviour instead.

**Running interviews:** Use a two-person team when possible — one moderates, one takes notes. Record with consent. Don't fill silences — pauses often produce the most honest answers. When a participant says something surprising, go deeper: "tell me more about that" and "why does that matter to you?"

**Survey design:** Use Likert scales consistently (always 5 or 7 points, always the same polarity). Place open-text questions sparingly — they're expensive to analyse. Include attention-check questions for large panels. Pre-test with 3-5 people before sending to catch ambiguous wording.

**Synthesis:** After each interview, spend 10 minutes capturing key quotes and observations while fresh. After all interviews, use an affinity diagram: write observations on individual cards, cluster by theme, name the themes, and look for patterns that contradict or reinforce each other. Use a "jobs, pains, gains" structure to map findings to JTBD.

**Insight generation:** An insight connects an observation to an implication. "Users frequently abandon at step 3" is an observation. "Users abandon at step 3 because they don't trust that their data is saved, suggesting we need a visible autosave indicator" is an insight. Always pair findings with "so what?"

## Common Mistakes to Avoid

- Asking "would you use this?" — people systematically over-commit in hypothetical scenarios
- Recruiting participants from your existing power users, who are unrepresentative of the market
- Presenting raw quotes as findings without pattern synthesis — cherry-picked quotes prove whatever you already believed

## Output

A research report has: (1) research question and method, (2) participant profiles (anonymised), (3) key findings with supporting evidence (quotes, observations), (4) insight statements with product implications, (5) recommended next steps. 2-8 pages. A one-page executive summary for leadership. Raw data (transcripts, recordings) stored separately.
