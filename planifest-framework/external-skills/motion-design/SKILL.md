---
name: motion-design
description: Motion and animation in digital products — timing, easing, purposeful motion, and performance constraints; use when designing or specifying animations and transitions.
---

# Motion Design

You design motion with purpose — every animation earns its existence by aiding comprehension, signalling state, or reinforcing spatial relationships — and you specify it with enough precision for engineering to implement exactly what you intended.

## When to Use

- Designing transitions between screens or states in a complex user flow
- Specifying micro-interactions (button feedback, form validation, loading states) for an engineering handoff
- Evaluating whether existing animations are aiding or hindering the user experience

## Core Principles

**Motion has a job.** Every animation should do one of: communicate state change, establish spatial relationships, provide feedback, or guide attention. Animation that does none of these is decoration — it adds cognitive load and slows users down. Cut it.

**Duration and easing are the grammar of motion.** Duration controls perceived speed and weight. Easing (the acceleration curve) communicates physicality — ease-out feels like something arriving; ease-in feels like something departing; ease-in-out feels like something moving through space. These choices communicate as much as the motion itself.

**Never animate for animation's sake.** Complex, choreographed animations in functional UI convey a sense of the designer showing off, not serving the user. Reserve expressive motion for moments of delight (onboarding, achievement, empty states) — and keep it brief.

**Respect the vestibular system.** Large-scale parallax effects, excessive bounce, and rapid-flashing motion cause vestibular disturbance (motion sickness, disorientation) for a significant percentage of users. The `prefers-reduced-motion` media query is not optional — it's an accessibility requirement.

**Performance is a constraint, not a concern.** A beautiful animation that janks at 24fps is worse than no animation. Constrain yourself to GPU-composited properties: `transform` and `opacity`. Animating `width`, `height`, `top`, `left`, or `background-color` triggers layout and paint, producing jank on mid-range devices.

## Approach

**Animation vocabulary for a product:** Define at the start of a design system the motion vocabulary: (1) duration scale (instant: 0-100ms for immediate feedback; fast: 100-200ms for micro-interactions; normal: 200-300ms for screen elements entering/exiting; slow: 300-500ms for larger, more complex transitions; never exceed 500ms for functional UI), (2) easing library (ease-out for elements entering from off-screen, ease-in for elements leaving, ease-in-out for elements moving within the viewport, spring physics for interactive elements that feel physical), (3) motion tokens (same as design tokens — brand-motion-fast: 150ms ease-out).

**State transitions:** For every state change in a component, define: what changes (position? opacity? size? colour?), how it changes (which easing?), how long it takes, and whether it's interruptible. State changes under 100ms feel instantaneous (button press feedback). State changes 100-300ms feel responsive (dropdown opening). State changes 300-500ms feel deliberate (modal entering). State changes over 500ms feel slow (use only for dramatic reveals or first-run experiences).

**Screen transitions:** Establish a spatial model for your app — does navigating "into" a detail screen move content right-to-left (implying depth)? Do modals slide up from the bottom (implying they float above content) or fade in (implying they overlay)? Consistent spatial metaphors help users build mental models of app structure. Inconsistent transitions (some screens slide, others fade, others zoom) create spatial confusion.

**Micro-interaction specification:** For engineering handoff, specify each animation: property, start value, end value, duration, easing curve (cubic-bezier values, not named curves — not all browsers interpret named curves identically), and whether it's triggered automatically or on user interaction. For complex choreography, provide a timing diagram: a grid of elements on the Y axis and time on the X axis, with bars showing when each element starts and ends its animation. This makes dependencies explicit.

**Illustrative motion (Lottie / SVG):** For onboarding animations, empty states, and success moments, use Lottie (JSON animation format from After Effects) rather than GIF or video — it's scalable, small, and controllable via code (play, pause, speed). Define in the spec: when the animation plays (on enter, on loop, on trigger), whether it loops, and whether it can be interrupted. Keep Lottie files under 100KB; large files degrade scroll and render performance.

**Testing motion:** Test animations on real mid-range devices (a 2019 Android phone), not on your M2 MacBook Pro. Test with `prefers-reduced-motion` enabled — does the design still work without animation? Test with CPU throttling (Chrome DevTools) at 4× slowdown. If the animation janks under throttling, it will jank for some users in production.

## Common Mistakes to Avoid

- Specifying animations only for the "happy path" — what happens to the animation if the user interrupts it halfway through? Define interruptibility behaviour explicitly
- Using spring animations (bouncy physics) for functional UI — spring is appropriate for draggable elements and playful empty states; it's jarring for form validation and navigation
- Animating everything simultaneously in a complex screen transition — staggered animation (each element animates in sequence with a small offset) reads more fluidly and directs attention, but must be brief (total stagger duration under 400ms)

## Output

Motion design outputs: (1) motion vocabulary document (duration scale, easing library, usage guidelines), (2) state transition specifications for all interactive components, (3) screen transition map with spatial model, (4) Lottie files for illustrative moments, (5) timing diagrams for complex choreography. All animations specified with exact cubic-bezier curves, duration values, and trigger conditions. `prefers-reduced-motion` behaviour defined for each animation.
