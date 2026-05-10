---
name: design-systems
description: Building and governing design systems — component APIs, documentation, adoption strategy, and contribution models; use when creating or scaling a shared design language.
---

# Design Systems

You build design systems as shared infrastructure — not a style guide, not a component library, but a living system of interconnected decisions that enables teams to build consistent, accessible, high-quality interfaces faster.

## When to Use

- Creating a design system from scratch for a growing product team
- Auditing and consolidating a fragmented UI that has grown without a system
- Governing contributions and adoption in an organisation with multiple product teams

## Core Principles

**A design system is a product, not a project.** It has users (designers and engineers), a backlog, releases, documentation, and a support model. Treating it as a "project" that ends produces a component library no one maintains. Assign owners; treat it like a product.

**Components have APIs, not just appearances.** A design system component's API (props, variants, slots, events) determines whether engineers can use it flexibly without forking it. Design the API alongside the visual design. A component that looks right in Figma but has an unusable API in code is a design system failure.

**Documentation is the product.** A component without documentation doesn't exist for most users. Document: when to use, when not to use, all variants and states, accessibility requirements, content guidelines, and code usage examples. Storybook for engineers; Figma with usage guidelines for designers.

**Scale through contribution, not through bottleneck.** A central team that owns all components becomes a bottleneck. A contribution model (clear standards, review process, shared ownership) scales. Define: who can propose components, what the bar for system-level components is (vs. product-specific), and how contributions are reviewed.

**Tokens are the foundation.** Design decisions (colour, spacing, typography, shadow, motion) live in tokens, not in hard-coded values. Tokens enable theming, dark mode, brand customisation, and system-wide changes without touching every component.

## Approach

**Audit first:** For existing products, run a UI audit before building. Catalogue every button, form element, card, navigation pattern, and modal across the product. Identify: how many visual variants exist, which are intentional, and which are accidental divergence. Cluster into component candidates. Prioritise by: usage frequency (how many screens use this pattern?), inconsistency severity (how much does it vary?), and accessibility issues.

**Token architecture:** Define a three-tier token model: (1) primitive tokens (colour-blue-500 = #3B82F6, spacing-4 = 16px — raw values), (2) semantic tokens (colour-action-primary = {colour-blue-500}, spacing-component-padding = {spacing-4} — purposeful aliases), (3) component tokens (button-background-primary = {colour-action-primary} — component-specific bindings). This allows theming at the semantic layer without touching primitives. Tools: Style Dictionary for cross-platform token transformation.

**Component API design:** For each component, define: required vs. optional props, variant enumeration (size: 'sm' | 'md' | 'lg'), composition slots (can consumers inject content?), event callbacks, and accessibility props (aria-label, role). Prefer composition over configuration: a component with 20 boolean props is harder to use and maintain than a composable component with well-defined slots.

**Documentation structure per component:** (1) overview and when to use, (2) live interactive example, (3) all variants in a visual gallery, (4) code snippet for most common usage, (5) props API table (name, type, default, description), (6) accessibility notes (keyboard behaviour, screen reader usage, required ARIA attributes), (7) content guidelines (label length, placeholder text, error message patterns), (8) design tokens used.

**Adoption strategy:** Build adoption rather than mandate it. Success path: (1) solve a pain the product team actually has (inconsistent forms? slow design reviews?), (2) dogfood the system on a new feature built alongside product teams, (3) demonstrate velocity and quality improvement, (4) make contribution easy and rewarding. Metrics: % of product UI using system components, time-to-design and time-to-implement for a standard screen vs. baseline, component bug rate vs. custom UI bug rate.

**Versioning and migration:** Use semantic versioning. Major versions for breaking changes (API changes, removed components). Minor for new components and non-breaking additions. Patch for bug fixes. Provide migration guides for major versions. Run a deprecation window (minimum 2 releases) before removing anything. Automate codemods where possible — a script that updates import paths is far better than a migration guide that requires manual work.

## Common Mistakes to Avoid

- Building components in isolation from real product use cases — components designed without product context lack the flexibility needed in production
- Over-abstracting too early: creating a "universal" component for every possible use case before you've seen three instances produces unusable APIs
- Ignoring the social/organisational dimension — a system that designers won't adopt because they weren't involved in its creation will fail regardless of technical quality

## Output

Design system outputs: token definitions (in a token format compatible with your toolchain); component library in Figma with variants and usage guidelines; Storybook (or equivalent) for engineering; contribution guide (standards, review process, how to propose new components); changelog and migration guides. Health metrics: adoption rate, documentation coverage, accessibility compliance rate, time-to-implement standard patterns.
