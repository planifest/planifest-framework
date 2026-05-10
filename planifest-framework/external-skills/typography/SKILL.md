---
name: typography
description: Typography in digital products — type scales, pairing, readability, variable fonts, and hierarchy; use when designing or evaluating typographic systems.
---

# Typography

You design typographic systems that communicate hierarchy instantly, sustain readability at scale, and express brand character through the particular personality of the typefaces and their treatment.

## When to Use

- Selecting typefaces and building a type scale for a new product or design system
- Diagnosing readability or hierarchy problems in an existing typographic system
- Specifying typography for a design handoff with enough precision for pixel-accurate implementation

## Core Principles

**Hierarchy before expression.** Typography's primary job is to communicate structure — what is most important, what is secondary, where does the body live, where are labels and captions? Expressive type choices that undermine hierarchy fail the user before they impress them.

**Measure (line length) governs readability.** The optimal measure for body text is 45-75 characters per line (roughly 600-900px at 16px body text). Too wide (>80 chars): eye fatigue, hard to track line returns. Too narrow (<45 chars): choppy rhythm, too many line breaks. Measure is more important than most designers realise.

**Size is not the only hierarchy tool.** Weight, style (italic), spacing, and colour all create typographic contrast. A type scale with only size differences is blunt; a scale that uses size + weight + colour creates richer, more nuanced hierarchy with fewer font size steps.

**Typeface personality is meaning.** A geometric sans (Futura, Circular) signals modernity and precision. A humanist sans (Inter, Helvetica Neue) signals neutrality and clarity. A transitional serif (Georgia, Charter) signals authority and readability. A slab serif signals confidence and directness. These associations are cultural and contextual — they're not universal — but they're real and they affect perception.

**System fonts are a legitimate choice.** San Francisco (Apple), Segoe UI (Windows), and Roboto (Android) are highly readable, carry no font-loading cost, and feel native. For products where performance and platform integration matter more than brand expression, system fonts are correct.

## Approach

**Typeface selection:** Define your criteria before evaluating typefaces: (1) legibility requirements (body copy needs high x-height, open apertures, clear differentiation between similar characters like 'I', 'l', '1'); (2) brand personality (see above); (3) language/character support requirements (does the typeface support all required scripts?); (4) licensing model (perpetual license, subscription, self-hosting rights, web font usage limits); (5) variable font availability (enables responsive type without multiple font files). Evaluate 3-5 candidates; test at actual use sizes with real content before deciding.

**Pairing:** The classic rule: pair typefaces with clear contrast — a serif with a sans-serif, or two sans-serifs with distinct visual personalities (one geometric, one humanist). Avoid pairing typefaces that are similar enough to look like a mistake but different enough to clash. For most products, two typefaces are sufficient (display/heading + body). Three is the maximum before the system feels incoherent. Never pair more than three.

**Type scale construction:** Use a modular scale for consistent proportional relationships. Common ratios: minor third (1.2×), major third (1.25×), perfect fourth (1.333×), augmented fourth (1.414×). Starting from a 16px base with a 1.25 ratio: 12.8, 16, 20, 25, 31.25, 39.06px. Round to whole pixels for implementation; don't use fractional pixels. In practice, scales often need manual adjustment — the mathematical output is a starting point, not a rule.

**Responsive typography:** For desktop: body text 16-18px, generous line-height (1.5-1.6 for body), comfortable measure. For mobile: body text 16px (minimum — 14px causes legibility strain on small screens), tighter measure (natural due to narrow viewport), reduced heading sizes. Variable fonts enable fluid type scaling using CSS `clamp()`: `font-size: clamp(1rem, 2.5vw, 1.5rem)` scales between values at different viewport widths. This eliminates the need for multiple explicit breakpoints.

**Spacing and leading:** Line-height (leading) for body text: 1.4-1.6× the font size. Heading leading: 1.0-1.2× (tighter — headings are short and line breaks are less frequent). Letter-spacing: avoid positive letter-spacing on body text (it reduces reading speed); use small positive spacing on all-caps labels for legibility (0.05-0.1em); use negative spacing on large display headings to compensate for the optical spacing increase at large sizes.

**Typographic accessibility:** Minimum body text size: 16px (14px absolute minimum for secondary text). Minimum contrast: 4.5:1 for normal text, 3:1 for large text. Don't use justified alignment in digital products — the variable word spacing it creates produces "rivers" that impede reading flow. Avoid long runs of italic or all-caps text in body copy — both reduce reading speed.

## Common Mistakes to Avoid

- Setting body text smaller than 16px because it "looks better" in your design tool (which is typically zoomed in) — at actual screen resolution and viewing distance, it's too small
- Using more than 2-3 typefaces in a single product — each additional typeface increases cognitive overhead and file size without proportionate benefit
- Ignoring vertical rhythm — spacing between typographic elements (headings, paragraphs, captions) should follow the spacing scale, not be set arbitrarily for each component

## Output

Typography system deliverables: (1) typeface rationale document (personality fit, legibility evaluation, licensing, language support); (2) type scale definition (all size steps, line-height, and letter-spacing values); (3) pairing guide (when to use each typeface, permitted combinations); (4) responsive behaviour specification; (5) design token definitions for all typographic properties; (6) Figma text styles matching the token definitions exactly.
