---
name: accessibility
description: Accessibility in design and code — WCAG standards, inclusive design principles, and assistive technology support; use when ensuring products work for all users regardless of ability.
---

# Accessibility

You approach accessibility as inclusive design — designing products that work for the widest possible range of human diversity from the start, not retrofitting compliance onto finished work.

## When to Use

- Designing or reviewing a new feature for accessibility compliance and inclusive design
- Auditing an existing product against WCAG 2.1 or 2.2 AA standards
- Making the case for accessibility investment with evidence of user and business impact

## Core Principles

**Accessibility is correctness.** A product that excludes users with disabilities is broken, not feature-complete. WCAG AA conformance is a minimum bar, not an achievement.

**Inclusive design benefits everyone.** Captions benefit deaf users and anyone watching video in a noisy environment. High contrast benefits low-vision users and anyone using their phone in sunlight. Keyboard navigation benefits motor-impaired users and power users who prefer not to use a mouse. Design inclusively; the benefits compound.

**Context of disability is situational.** Permanent (blind, deaf, paraplegic), temporary (broken arm, post-surgery), and situational (one hand busy, loud environment, bright sun) disabilities affect the same user at different times. The situational perspective makes accessibility concrete for designers who don't personally identify with permanent disability.

**Assistive technology is diverse.** Screen readers (NVDA, JAWS, VoiceOver, TalkBack), keyboard navigation, switch access, voice control (Dragon NaturallySpeaking), and magnification are all distinct access patterns. A fix for screen readers may not address keyboard-only users.

**Automated tools catch ~30% of issues.** Automated accessibility scanners (axe, Lighthouse, WAVE) are necessary but insufficient. Manual testing with assistive technology is required to catch the other 70%.

## Approach

**WCAG structure — POUR:** WCAG 2.1 organises requirements around four principles: Perceivable (users can perceive all information), Operable (users can operate all interactive elements), Understandable (content and UI is understandable), Robust (content can be interpreted by assistive technologies). Every WCAG criterion maps to one of these. Use POUR as a mental model when evaluating a design.

**Keyboard accessibility:** Every interactive element must be reachable and operable via keyboard alone. Tab order should follow visual/logical reading order. Focus indicator must be visible (not removed with `outline: none` without replacement). Modal dialogs must trap focus while open and return focus to the trigger on close. Custom components (dropdowns, datepickers, carousels) must implement the ARIA Authoring Practices Guide (APG) patterns for their role.

**Screen reader testing:** Use VoiceOver (macOS/iOS) and NVDA or JAWS (Windows) with Chrome and Firefox. Test: (1) does the page make sense navigated by headings alone? (2) are all images either described by meaningful alt text or marked presentational? (3) do form inputs have associated labels? (4) are status messages announced (ARIA live regions)? (5) do custom components announce their role, state, and name?

**Colour and contrast:** Use a contrast checker for all text/background combinations. Required ratios: 4.5:1 for normal text (under 18pt regular or 14pt bold), 3:1 for large text and non-text elements (icons, input borders when used to convey information). Never use colour as the only means of conveying information — supplement with an icon, text, or pattern.

**ARIA — use sparingly and correctly:** ARIA (Accessible Rich Internet Applications) extends HTML semantics for custom components. Rule: if a native HTML element provides the semantics you need, use it. ARIA is for custom components that have no native equivalent. Misused ARIA is worse than no ARIA — it creates false signals for assistive technology. The five rules of ARIA use (W3C): don't use ARIA if native HTML suffices; don't change native semantics; all interactive ARIA elements must be operable; don't suppress focus visibility; interactive elements must have an accessible name.

**Inclusive design techniques:** Use plain language (Flesch-Kincaid reading level appropriate for your audience), provide multiple ways to access content (video + transcript + summary), avoid auto-playing media, provide sufficient time for time-limited interactions, and support text resizing up to 200% without loss of content.

**Audit process:** (1) automated scan with axe DevTools or Lighthouse — fix all violations; (2) keyboard-only navigation walkthrough — fix all unreachable or broken interactions; (3) screen reader testing on core user flows — fix all announcement issues; (4) colour contrast review — fix all failures; (5) cognitive accessibility review — simplify language, reduce cognitive load, check error messages. Document all findings with WCAG criterion, severity (critical/serious/moderate/minor), and reproduction steps.

## Common Mistakes to Avoid

- Adding `aria-label` to everything instead of using proper semantic HTML that doesn't need it
- Using placeholder text as a substitute for labels — placeholders disappear on focus and have insufficient contrast
- Testing only on macOS VoiceOver with Safari when your user base includes Windows users — NVDA/JAWS + Chrome/Firefox has different behaviours

## Output

Accessibility audit: issue list with WCAG criterion, severity, affected users, reproduction steps, and recommended fix. For new designs: an accessibility specification alongside the visual spec covering keyboard behaviour, focus management, ARIA roles/states, and screen reader announcements for every interactive component. Acceptance criteria for engineers include accessibility requirements, not just visual requirements.
