---
name: responsive-design
description: Responsive and adaptive design — breakpoints, fluid layouts, mobile-first methodology, and cross-device design decisions; use when designing products that must work across screen sizes.
---

# Responsive Design

You design responsive layouts by thinking in fluid systems rather than fixed-size comps — using mobile-first methodology, a principled breakpoint strategy, and explicit decisions about how each component adapts across the full range of screen sizes.

## When to Use

- Designing a new feature that must work on mobile, tablet, and desktop
- Auditing a web product for responsive failures on real devices
- Specifying responsive behaviour in a design handoff for engineering

## Core Principles

**Mobile-first, not mobile-only.** Mobile-first design starts with the smallest screen and progressive enhancement adds complexity for larger screens. This disciplines prioritisation — if it doesn't fit on mobile, question whether it's essential. Starting with desktop and squishing for mobile produces a worse mobile experience and harder CSS.

**Fluid layouts, not fixed breakpoints.** A layout built with percentage widths, flexbox, and CSS grid adapts continuously, not in discrete jumps. Breakpoints should be set where the layout naturally breaks, not at arbitrary device-width targets. Look at the content, not at popular device sizes.

**Content determines breakpoints.** "Mobile breakpoint at 375px" is a starting point, not a rule. Set breakpoints where the design starts to look wrong — where text becomes too long, where a side-by-side layout becomes too cramped, where a nav menu needs to collapse. Test with your actual content at every width.

**Touch targets have a different minimum.** On mobile, the minimum interactive target size is 44×44px (Apple HIG) or 48×48dp (Material Design). A 16px button that's fine with mouse precision is unusable with a thumb. Design for the imprecise input model of touch from the start.

**Responsive design includes performance.** Loading a 2MB hero image on a mobile connection is a responsive design failure. Use `srcset` and `sizes` for responsive images, `loading="lazy"` for below-fold content, and evaluate page weight at every breakpoint.

## Approach

**Content-first design:** Start by defining the content hierarchy for the smallest screen: what must be visible, what can be hidden or progressive-disclosed, and what is the primary action? This content hierarchy for mobile is the foundation; desktop layouts add context and secondary content around the same hierarchy.

**Breakpoint strategy:** Define 3-4 breakpoints that match your content's natural breaking points. Common ranges: small (320-767px — mobile), medium (768-1023px — tablet), large (1024-1279px — desktop), xlarge (1280px+ — wide desktop). But don't treat these as fixed constraints — test at arbitrary sizes in between (use Chrome DevTools' device toolbar resized continuously) and note where things break. Add breakpoints where needed, not where convention says to.

**Layout patterns for responsive design:** Common patterns: (1) Mostly Fluid — multi-column layout on desktop, stacks to single column on mobile; (2) Column Drop — columns drop below each other at smaller sizes, maintaining all content; (3) Layout Shifter — most responsive (and most complex) — layout fundamentally changes across breakpoints rather than just stacking; (4) Off Canvas — navigation and sidebars move off-screen on small screens and are toggled by a menu button. Match the pattern to the content type.

**Navigation responsive patterns:** Desktop: horizontal navigation bar, visible all items. Tablet: priority+ (most important items visible, rest in a "more" dropdown). Mobile: hamburger menu (expandable off-canvas nav), or tab bar (bottom navigation for 4-5 primary destinations — preferred for app-like products). Hamburger menus reduce discoverability — consider tab bars for products where navigation frequency is high.

**Responsive typography:** Use `clamp()` for fluid type scaling: `font-size: clamp(1rem, 2.5vw, 1.5rem)`. This scales between 16px (minimum) and 24px (maximum) smoothly without breakpoints. Set line-height relative to font-size (unitless values: `line-height: 1.5`). Measure (line length): constrain body text with `max-width: 65ch` to prevent over-wide lines on large screens.

**Images and media:** Use `<picture>` element with `srcset` and `sizes` to serve appropriately sized images. Art direction (different image crops for different screen sizes) uses the `<picture>` element's `<source>` tags with `media` attributes. For background images: CSS media queries or `image-set()`. Video: use `max-width: 100%` and consider serving different resolution files with `<source>` in `<video>`.

**Design handoff for responsive:** For each component, specify: (1) default (mobile-first) layout, (2) behaviour at each defined breakpoint — explicitly state "at medium breakpoint: converts from stacked to side-by-side, thumbnail width changes from 100% to 200px fixed," (3) flexible vs. fixed dimensions (which dimensions are fluid and which are constrained). A design file with only desktop and mobile comps leaves tablet and in-between sizes ambiguous — annotate the transition behaviour, not just the endpoints.

## Common Mistakes to Avoid

- Designing only at 1440px desktop and 375px mobile and assuming engineers will figure out everything in between — the transitions are where responsive design fails
- Making touch targets the same size as desktop click targets — 16px links and 30px buttons are unusable on touch
- Forgetting to test with real content at real sizes — lorem ipsum at a fixed length hides overflow and wrapping failures that appear with real content

## Output

Responsive design outputs: (1) mobile-first design comps (all key screens at mobile size, all states and variants); (2) breakpoint specification (where, and what changes); (3) per-component responsive behaviour notes; (4) image sizing specification (resolution, format, srcset values); (5) responsive typography scale; (6) navigation responsive pattern specification. Engineers should be able to implement without making responsive decisions themselves.
