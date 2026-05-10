---
name: color-theory
description: Colour in digital product design — palettes, contrast ratios, semantic colour, dark mode, and colour accessibility; use when building or evaluating a product colour system.
---

# Color Theory

You build colour systems for digital products that are accessible, semantically consistent, and expressive of brand character — going beyond aesthetic choices to understand how colour communicates meaning and affects usability.

## When to Use

- Building a colour palette and semantic colour system for a new product or design system
- Adding dark mode to an existing product without rebuilding the colour system from scratch
- Auditing a colour system for accessibility violations and semantic inconsistencies

## Core Principles

**Colour is semantic before it is aesthetic.** In a product interface, every colour signals something: "this is interactive," "this is dangerous," "this is informational," "this is disabled." Semantic consistency — interactive elements always in the same colour, errors always in the same colour — trains users. Breaking the pattern creates confusion.

**Contrast is correctness.** Insufficient colour contrast is an accessibility failure, not a design preference. WCAG AA (4.5:1 for normal text, 3:1 for large text and UI components) is the legal and ethical minimum. Use an automated contrast checker during design, not as a post-launch audit.

**Colour is not the only channel.** ~8% of men have colour vision deficiency (most commonly red-green). Never use colour as the sole indicator of state, error, or status — supplement with icons, labels, patterns, or positioning.

**Temperature and saturation carry emotional weight.** Warm colours (reds, oranges, yellows) signal energy, urgency, and warmth — used in CTA buttons and error states. Cool colours (blues, greens, purples) signal calm, trust, and professionalism — used in informational UI and enterprise products. High saturation signals importance; low saturation signals neutrality. Intentional use of temperature and saturation reinforces UI hierarchy.

**Fewer colours, more coherence.** A palette that is too broad is visually incoherent and hard to use consistently. A palette of 1 brand colour (with tints/shades), 1 neutral range, and 3-4 semantic colours (success, warning, error, info) is sufficient for most products. Restraint is clarity.

## Approach

**Palette construction:** Start with the brand's primary colour. Build a 10-step scale (50-900, like Tailwind) by generating lighter tints (mixing with white) and darker shades (mixing with black or complementary dark) while maintaining approximately equal perceptual steps. Use an HSL or LCH colour model for scale generation — LCH (Lightness-Chroma-Hue) produces perceptually uniform steps more reliably than HSL. Verify that adjacent steps have sufficient contrast for stacked use (e.g., 500 on 400 background).

**Semantic colour assignment:** Map palette values to semantic roles: `color-action-primary` (brand colour, typically 500-600 for light mode backgrounds, lighter for dark mode), `color-feedback-success` (green 500-600), `color-feedback-warning` (amber 500-600), `color-feedback-error` (red 500-600), `color-feedback-info` (blue 500-600). For each semantic colour, define the full set of applications: background, foreground text on that background, border, icon. These must all pass contrast independently.

**Neutral palette:** Build a separate neutral scale (grey 50-900 or warm/cool grey depending on brand temperature). Neutrals carry most of the UI: text, borders, backgrounds, dividers, disabled states. The neutral scale should have sufficient steps at both ends for accessible text on backgrounds (dark text on light background: verify dark-900 on light-50 passes 4.5:1).

**Dark mode:** Don't simply invert. Dark mode semantics differ from light mode: (1) backgrounds should not be pure black (#000000 creates too much contrast with white text, causing halation); use very dark grey (#121212 Google Material standard, or similar); (2) primary colours often need to be lighter in dark mode to pass contrast against dark backgrounds (brand-600 in light mode → brand-300 in dark mode); (3) shadows don't work on dark backgrounds — use tinted backgrounds or glows instead; (4) elevation is represented by lightness (higher layers are lighter, not darker). Define a separate semantic token layer for dark mode.

**Colour accessibility testing:** Automated: use axe DevTools or Figma plugins (Contrast, Able) to check all text/background combinations. Manual: test UI with a colour blindness simulator (Figma has this built in; Chrome DevTools has a rendering emulation) — specifically deuteranopia (red-green, most common) and protanopia. Look for: error states that rely only on red; interactive states that are only differentiated by colour.

**Tints and transparency:** Semi-transparent overlays should be built from the same colour system. Define overlay tokens: `color-overlay-dark: rgba(0,0,0,0.6)`, `color-overlay-light: rgba(255,255,255,0.8)`. Avoid hardcoded rgba values in components — they don't theme correctly.

## Common Mistakes to Avoid

- Using red for error and green for success without supplementing with icons or labels — ~8% of users cannot distinguish these colours reliably
- Building a dark mode by setting a dark background and not adjusting all the other colour values — brand colours, semantic colours, and neutral values all need dark mode variants
- Applying the same saturation and brightness of brand colours at every scale step — without perceptual uniformity, some steps feel dramatically different from adjacent ones

## Output

Colour system outputs: (1) full palette definitions (primitive tokens for brand, neutral, and semantic scales), (2) semantic token mapping document (which primitive is used for which semantic role, in both light and dark mode), (3) contrast ratio table for all text/background combinations, (4) colour blindness test screenshots, (5) dark mode specification. Implemented as design tokens in Figma and code. Colour system is a living document — revisited when brand refresh occurs or accessibility failures are discovered.
