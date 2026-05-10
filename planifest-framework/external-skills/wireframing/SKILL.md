---
name: wireframing
description: Wireframing practice — fidelity choices, annotation, iteration speed, and when to move on; use when rapidly exploring and communicating structure and flow before visual design.
---

# Wireframing

You wireframe as a thinking tool — moving fast at low fidelity to explore many options, annotating to communicate intent, and knowing precisely when wireframes have served their purpose and it's time to move to higher fidelity.

## When to Use

- Exploring multiple structural approaches to a new flow before committing to one
- Communicating the structure and behaviour of a screen to stakeholders without visual design noise
- Rapidly iterating on navigation and layout before detailed design investment

## Core Principles

**Fidelity matches the question.** A sketched wireframe on paper answers "does this navigation structure make sense?" A greyscale Figma wireframe answers "does this information hierarchy work?" A pixel-perfect comp answers "does this feel right?" Match fidelity to the question you're answering — over-investing in fidelity before the question is validated wastes time and creates emotional attachment to premature decisions.

**Wireframes communicate, not just design.** Annotations are as important as the wireframe itself. A wireframe without annotation is an ambiguous picture. Annotations transform a drawing into a specification: they explain behaviour, state transitions, content guidelines, and open questions.

**Speed matters at this stage.** The value of a wireframe is in generating and comparing multiple options cheaply. If it takes a day to wireframe one approach, you can't explore alternatives. A 30-minute sketch session that produces 5 concepts beats a 4-hour Figma session that produces 1.

**Use greyscale and placeholders deliberately.** Real copy and real imagery distract reviewers from structure. Grey boxes, lorem ipsum, and "Image 16:9" labels keep attention on layout, hierarchy, and flow. The moment you introduce colour or real imagery, you've invited a conversation about aesthetics rather than structure.

**Know when wireframes have done their job.** Wireframes answer structural and behavioural questions; they don't answer visual design questions. Stop wireframing when: the structure is validated, the interactions are specified, and the remaining questions are about colour, typography, and visual refinement.

## Approach

**Phase 1 — sketch (day 1):** Use paper, whiteboard, or a simple digital tool (Balsamiq, Whimsical). Focus on exploring multiple structural options — minimum 3 variations. Spend no more than 15-20 minutes per concept. The goal is quantity and divergence. Share with one other person for a quick sanity check before investing further.

**Phase 2 — select and develop:** Choose 1-2 concepts from sketches that show the most promise. Develop into cleaner low-fidelity wireframes (still greyscale, still using placeholder content, but cleaner and more to scale). Define the information hierarchy by controlling size and weight of placeholder elements. At this stage, think about: what's above the fold, what's the primary action, how does the user navigate out of this screen.

**Phase 3 — flow and states:** Wire the flow, not just individual screens. Show how screens connect (navigation, modals, error states, empty states). For each interactive element: what happens when activated? For each piece of dynamic content: what are the states (loading, empty, error, populated)? A wireframe that shows only the happy path is incomplete.

**Annotation method:** Two types of annotation: (1) behavioural notes on the wireframe (callout numbers with a legend), for things like "tap opens modal X"; (2) a notes section below the wireframe for content guidelines ("button label: verb + noun, max 25 characters"), open questions ("TBD: do we show this field for all users or only premium?"), and design decisions made ("chose accordion over tabs because of variable content length"). Both types are mandatory on any wireframe leaving the design team.

**Critique and iteration:** Present wireframes to stakeholders as "work in progress for input," not "work complete for approval." Ask specific questions: "Does this structure match how you would expect to find X?" Run a 5-second test if you want to validate hierarchy without verbal explanation. Iterate the same day; don't let feedback sit. Two rounds of wireframe iteration are typical; more than three suggests you haven't aligned on the problem yet.

## Common Mistakes to Avoid

- Polishing wireframes to the point where stakeholders give visual feedback ("I don't like that grey") rather than structural feedback — if it's too polished, they can't see past the aesthetics
- Wiring only the happy path, leaving all error and empty states for engineering to guess at
- Using wireframes as a deliverable that "gets approved" rather than as a thinking tool — approval-seeking behaviour locks down structure prematurely

## Output

Wireframe deliverable: (1) per-screen wireframes with all key states (default, loading, empty, error), (2) flow diagram showing navigation connections between screens, (3) annotations explaining behaviour and content guidelines, (4) open questions log. Delivered in Figma (or equivalent) with clear naming conventions. Not pixel-perfect; resolution matches the question being answered.
