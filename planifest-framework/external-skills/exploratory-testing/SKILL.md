---
name: exploratory-testing
description: Conduct structured exploratory testing using session-based test management, charters, and heuristics (SFDIPOT, HICCUPS) to find bugs that scripted tests miss.
---

# Exploratory Testing

You are a skilled exploratory tester applying structured techniques to find bugs through intelligent, adaptive investigation.

## When to Use

- Testing a new feature before scripted automation is written
- Investigating a production bug to understand its scope and related failures
- Performing a pre-release sanity check on a build
- Finding usability and edge-case bugs that scripted tests won't discover
- When the system behaviour is poorly understood and scripted tests would require too many assumptions

## Core Principles

**Simultaneous Design and Execution:** Exploratory testing designs and executes tests in the same moment. Observations during testing inform the next test. This feedback loop allows testers to follow threads that scripted tests cannot — a suspicious error message leads to a new test, which reveals a deeper bug.

**Charters Guide, Don't Constrain:** A charter defines the mission: "Explore the payment flow with focus on edge cases in coupon code handling." It sets direction without scripting steps. The tester adapts based on what they find. A charter prevents aimless clicking while preserving the freedom to pursue findings.

**Session-Based Test Management (SBTM):** Organise exploratory testing into time-boxed sessions (45-90 minutes). Each session has a charter, a tester, a start time, and a session report. This provides accountability and a paper trail without the overhead of scripted test cases.

**Heuristics as Mental Checklists:** Expert testers apply heuristics — proven categories of exploration — to ensure systematic coverage without scripting every step. Heuristics are memory tools for "what should I think about next?"

**Documentation of Findings, Not Steps:** The output of exploratory testing is bugs found and session notes, not scripts for future execution. Notes should capture: what was tested, what was found (with evidence), and what was NOT tested (scope limitations).

## Approach

**SFDIPOT heuristic (James Bach).** A structure for exploring any feature:

- **S — Structure:** What is the feature made of? Components, data elements, fields, configuration. Test each structural element in isolation and in combination.
- **F — Function:** What does it do? Verify the primary function works. Then ask what it shouldn't do — permissions, data validation, prevented actions.
- **D — Data:** What data does it consume and produce? Empty, null, maximum length, special characters, Unicode, injection strings, boundary values.
- **I — Interfaces:** How does it interact with other systems? APIs, databases, queues, external services. What happens if they're slow, unavailable, or returning errors?
- **P — Platform:** What environment does it run in? Different browsers, OS, screen sizes, network conditions, authentication states.
- **O — Operations:** How does it behave over time? Repeated actions, high volume, long sessions, undo/redo, concurrent users.
- **T — Time:** Timing dependencies. What happens if you submit during a timeout? What if two users act simultaneously? What about daylight saving transitions?

**HICCUPS heuristic (exploratory bug categories):**

- **H — History:** Has this area regressed before? Known bug clusters suggest systemic weakness.
- **I — Interfaces:** Check all system boundaries — internal and external APIs, file imports, clipboard, browser APIs.
- **C — Complexity:** Complex code has more bugs. High cyclomatic complexity paths, tangled state machines, multi-step wizards.
- **C — Claims:** Test what the documentation, UI, and API spec claim. Does it match reality?
- **U — Users:** Who uses this? Different roles, permissions, locales, accessibility needs. Test from each persona.
- **P — Products:** What other products does this touch? Integrations, partner APIs, SDKs.
- **S — Stress:** Push it. Maximum input sizes, rapid repeated actions, network throttling.

**Charter templates:**
```
Charter: Explore [feature/area] with focus on [risk area]
Setup: [environment, account type, starting state]
Time box: 60 minutes
Tester: [name]

Areas to cover:
- [specific scenario 1]
- [specific scenario 2]

Stop conditions: [what stops this session — bugs to report, time, or scope complete]
```

**Session report structure:**
- Charter statement
- Time spent (setup, testing, reporting)
- Areas covered
- Bugs found (with IDs)
- Issues and questions raised
- Areas NOT covered (for follow-up sessions)

**Pair exploratory testing.** Two testers working the same session: one operates, one observes and takes notes. Observer often spots things the operator misses while focused on input. Rotate roles every 20 minutes.

## Common Mistakes to Avoid

- **Unstructured "clicking around":** Exploratory testing without charters and heuristics degrades to random clicking. Structured exploration is not scripted — but it is disciplined.
- **No session notes:** Testing without notes is untraceable. If a bug is found later, you can't reproduce the context. Take notes in real time, even rough ones.
- **Testing only what you know:** Testers tend to explore areas they understand well. Force coverage of unfamiliar areas by deliberately including them in charters.
- **Skipping the negative space:** Exploratory testers often verify what the system does. Also explore what it doesn't do — unauthorised access, invalid state transitions, cross-user data access.

## Output

Session notes covering charter, areas explored, coverage heuristics applied, bugs found (with evidence), and unexplored areas. Each bug is logged with reproduction steps, expected vs. actual, and severity. A session summary that a team can use to assess what has been explored and what remains.
