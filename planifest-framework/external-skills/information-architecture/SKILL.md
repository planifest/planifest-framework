---
name: information-architecture
description: Information architecture — taxonomy, navigation design, labelling, findability, and card sorting; use when organising content and navigation for clarity and discoverability.
---

# Information Architecture

You design information architectures that match users' mental models — organising, labelling, and structuring content so that people find what they need without thinking hard about where to look.

## When to Use

- Redesigning navigation for a product that has grown organically into a confusing structure
- Designing the IA for a new product area with many content types and user tasks
- Evaluating findability: how well can users locate content or features in the current structure?

## Core Principles

**Organisation reveals assumptions.** Every IA decision reflects a mental model — of what belongs together, what users are trying to do, and how they think about your domain. Explicit analysis of these assumptions is the first step; implicit assumptions become findability failures.

**Users navigate by recognition, not recall.** Navigation labels must trigger instant recognition of where clicking will lead. Clever, branded, or category-internal labels fail users. Plain, task-oriented labels succeed.

**Multiple classification schemes serve multiple needs.** A library has topical classification, author indexes, and a new-arrivals section. Your product may need similar redundancy: category-based navigation, search, recent items, and contextual related links. Users find things through different paths; provide all the useful ones.

**Findability and browsability are different.** Findability: "I know what I'm looking for and need to find it." Browsability: "I'm exploring; show me what's available." Good IA supports both. Search supports findability; clear hierarchical navigation supports browsability.

**IA is testable before it is buildable.** Card sorting and tree testing validate structure with real users before a line of code is written. Use them.

## Approach

**Content audit:** Inventory all content and features in the existing product or design. For each item: type, user task it supports, current location, usage frequency. Identify: orphaned content (exists but hard to find), duplicated content (same thing in two places), and missing content (users need it but it doesn't exist). The audit is the source material for IA design.

**Card sorting:** Open card sort — participants group items without a predefined structure, then label the groups — reveals how users naturally categorise your content. Run with 15-30 participants for quantitative clustering. Use: Optimal Workshop, Maze, or physical cards + spreadsheet. Analyse: similarity matrix (how often were two items grouped together?), cluster dendrogram, and category label patterns. Card sort results inform your proposed taxonomy.

**Taxonomy design:** Organise content into a hierarchy using card sort data and business logic. Evaluate each level against: (1) exhaustiveness (every item has a home), (2) exclusivity (items don't obviously belong in multiple places — if they do, add a cross-link, not a copy), (3) label clarity (do labels communicate what's inside without clicking?). Optimal taxonomy: 4-7 top-level categories, 2-3 levels deep before reaching content. Deeper hierarchies increase cognitive load.

**Tree testing:** Test the proposed taxonomy by asking users to find specific items in a text-only tree (no visual design). Tools: Optimal Workshop TreeJack, Maze. Measure: success rate, directness (went straight to correct location), and first-click accuracy. Targets: 80%+ success rate for primary tasks. Items with <60% success rate need IA redesign, not better visual design.

**Navigation labelling:** Test labels in isolation — show the label, ask users what they expect to find behind it. Ideal labels are: specific (not "Resources"), task-oriented (where useful — "Manage Account" not "Account"), user-language (use words from user research, not internal product language), and short (1-3 words for primary navigation). Avoid: jargon, clever wordplay, and generic terms that could mean anything.

**Wayfinding:** Beyond navigation labels, users need cues about where they are (breadcrumbs, active states in navigation, page titles) and where they can go (contextual links to related content, "next steps" prompts, search within a section). Design wayfinding as part of IA, not as a CSS detail.

**Search integration:** Define the relationship between navigation and search for your product. When navigation is comprehensive (bounded content), search supplements navigation. When content is vast (knowledge bases, e-commerce), search is the primary findability mechanism and navigation is a fallback. Design both; test which users prefer in which contexts.

## Common Mistakes to Avoid

- Designing navigation around internal team structure rather than user tasks — "Marketing," "Product," "Engineering" makes sense to the company org chart; it makes no sense to users
- Skipping validation (card sort, tree testing) and trusting intuition about what belongs together — intuition is a good starting point, not a sufficient endpoint
- Confusing navigation with IA — navigation is the interface; IA is the underlying structure. Good IA can be navigated in multiple ways; navigation is one expression of it

## Output

IA deliverables: (1) content audit spreadsheet; (2) card sort results with analysis (similarity matrix, clustering); (3) proposed taxonomy with rationale; (4) tree test results with problem areas identified; (5) navigation design with labelling rationale; (6) sitemap (visual hierarchy of all content areas). Delivered before any visual design begins.
