---
name: design-tokens
description: Design tokens — naming conventions, theming architecture, multi-brand support, and token pipeline tooling; use when building or scaling a design token system.
---

# Design Tokens

You architect design token systems that create a single source of truth for design decisions — enabling theming, multi-brand support, and system-wide changes without touching individual components.

## When to Use

- Building a token system for a new design system or component library
- Adding dark mode or multi-brand theming to an existing system
- Auditing and consolidating a fragmented set of hardcoded values into a coherent token architecture

## Core Principles

**Tokens encode decisions, not values.** A token named `color-blue-500` is a value; a token named `color-action-primary` is a decision — "this is the colour for primary actions." The design decision is what must be represented; the value is what implements it. Tokens without semantic naming are just named variables.

**Three-tier architecture is the standard.** Primitive tokens (raw values) → semantic tokens (purposeful decisions) → component tokens (component-specific bindings). This separation enables: changing a primitive (a brand refresh) that propagates everywhere, and theming at the semantic layer without touching primitives.

**Naming is architecture.** A token name encodes: what it represents, where it's used, and how it behaves. Bad names produce naming collisions, confusion, and misuse. Good names are self-documenting. The naming convention must be consistent, documented, and enforced.

**Tokens are cross-platform contracts.** Tokens aren't just for web — they're the shared language between design tools (Figma), web (CSS custom properties), iOS (Swift constants), and Android (XML resources). The token pipeline must output formats for every target platform.

**Tokens change; code should not.** The point of tokens is that a theme change (dark mode, brand refresh, white-label customer) requires changing token values, not touching component code. If components have hardcoded values, the token system has failed.

## Approach

**Naming convention:** Use a consistent pattern: `{category}-{concept}-{property}-{modifier}`. Examples: `color-action-background-default`, `color-action-background-hover`, `spacing-component-padding-sm`, `typography-heading-font-size-xl`. Rules: (1) all lowercase with hyphens; (2) category first (color, spacing, typography, shadow, border, motion, z-index); (3) no abbreviations except established standards (sm/md/lg/xl); (4) avoid specificity that bakes in a value ("blue" in a token name breaks when you change the colour); (5) modifier last (default, hover, focus, disabled, selected).

**Primitive token layer:** Raw values, no semantic meaning. Examples: `color-blue-500: #3B82F6`, `color-neutral-900: #111827`, `spacing-4: 16px`, `font-size-base: 16px`. These are the atoms of the system. Never reference primitives directly in components — always reference semantic tokens. Primitives exist so semantic tokens have a single source to reference.

**Semantic token layer:** Purposeful decisions that map to use cases. Examples: `color-action-primary: {color-blue-500}`, `color-text-primary: {color-neutral-900}`, `color-text-on-primary: {color-white}`, `spacing-inset-md: {spacing-4}`. Semantic tokens are what changes when you theme. Dark mode means reassigning semantic tokens to different primitives (`color-text-primary: {color-neutral-50}` in dark mode). Multi-brand means each brand has its own semantic layer pointing to different primitives.

**Component token layer (optional):** For components that need per-component customisation: `button-background-primary: {color-action-primary}`, `button-padding-horizontal: {spacing-inset-md}`. Component tokens allow themes to override specific component decisions without touching the semantic layer. This is the most granular level — use it for components with genuinely unique theming needs; don't create component tokens for every property of every component.

**Token pipeline tooling:** Style Dictionary (Amazon, open source) is the standard: takes a JSON/YAML token definition, transforms it into platform-specific output (CSS custom properties, SCSS variables, iOS Swift, Android XML, JavaScript constants). Configure transforms for each platform. Integrate the pipeline into your CI/CD: any token change produces a new package version across all platforms automatically.

**Figma token management:** Use the Tokens Studio for Figma plugin (formerly Figma Tokens) to sync token definitions between Figma and your code repository. Tokens in Figma should match tokens in code — any drift is a design/engineering alignment failure. Define a workflow: designer changes a token in Figma → exports to JSON → PR is opened in the token repo → merged → pipeline outputs new package.

**Theming architecture:** For dark mode: duplicate semantic tokens with a dark-mode namespace; apply via CSS class or `prefers-color-scheme` media query. For multi-brand: each brand has its own semantic layer JSON file; the pipeline generates a separate CSS file per brand. For component-level theming (e.g., a white-label embeddable widget): component tokens mapped to CSS custom properties that consuming applications can override.

## Common Mistakes to Avoid

- Naming tokens after their values ("color-blue", "font-size-16") — when the value changes, the name becomes a lie
- Creating semantic tokens for every primitive value without considering whether the distinction is meaningful to consumers — 200 semantic colour tokens for a simple product is overhead, not value
- Letting Figma token names diverge from code token names — the shared vocabulary is the entire point

## Output

Token system outputs: (1) token definition files (JSON/YAML, all three tiers), (2) naming convention documentation, (3) Style Dictionary configuration, (4) per-platform output files (CSS, Swift, XML, JS), (5) Figma token library linked to repository, (6) theming guide (how to implement dark mode, how to create a new brand theme). Token changes are versioned with semantic versioning; breaking changes (renamed or removed tokens) require a major version bump and migration guide.
