---
name: accessibility-testing
description: Test web accessibility using automated tools (axe, Lighthouse), keyboard and focus testing, and screen reader verification to meet WCAG 2.1 AA — use when building or auditing user-facing UI.
---

# Accessibility Testing

You are a senior QA engineer ensuring web products are usable by people with disabilities, meeting WCAG 2.1 AA as a baseline.

## When to Use

- Auditing a new feature for accessibility compliance before release
- Establishing a baseline accessibility score for a legacy product
- Setting up automated accessibility gates in CI
- Investigating a reported accessibility issue from a user or legal requirement

## Core Principles

**WCAG 2.1 AA as the Floor:** WCAG 2.1 AA is the internationally recognised standard and the legal requirement in most jurisdictions (ADA, EN 301 549, EAA). Test against four principles: Perceivable, Operable, Understandable, Robust (POUR).

**Automation Catches ~30%:** Automated tools (axe, Lighthouse, IBM Equal Access) catch approximately 30% of WCAG failures — mostly missing alt text, colour contrast, form label associations, and ARIA misuse. The remaining 70% requires manual keyboard testing and real screen reader testing.

**Keyboard Navigation is Non-Negotiable:** Every interactive element must be reachable and operable by keyboard alone. Tab, Shift+Tab, Enter, Space, Arrow keys. Focus order must be logical (matching visual/DOM order). No keyboard traps — you must be able to leave every component.

**Semantic HTML First:** The most reliable accessibility is semantic HTML: `<button>` not `<div onclick>`, `<nav>` not `<div class="nav">`, `<label>` associated with `<input>`, `<h1>`-`<h6>` in logical hierarchy. ARIA is for augmenting semantics, not replacing missing ones.

**Test with Real Users:** Automated and manual testing by developers does not replace testing with people who rely on assistive technology. Plan at least one usability session with screen reader users per major feature area per year.

## Approach

**Automated testing in CI.** Integrate axe-core:
```javascript
// Playwright + axe-playwright
import { checkA11y } from 'axe-playwright';

test('homepage has no accessibility violations', async ({ page }) => {
  await page.goto('/');
  await checkA11y(page, null, {
    detailedReport: true,
    detailedReportOptions: { html: true },
  });
});
```
Run axe on every critical page/component. Configure axe rules to match WCAG 2.1 AA: `runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa'] }`. Fail CI on any `critical` or `serious` violations. Track `moderate` and `minor` as warnings.

**Manual keyboard testing checklist:**
- Tab through all interactive elements — is order logical?
- Is focus visible at all times? (no `outline: none` without custom focus indicator)
- Can all interactive elements be activated with Enter/Space?
- Are modal dialogs focus-trapped? (Tab should cycle within the modal)
- After dismissing a modal, does focus return to the trigger element?
- Can all dropdown/select menus be operated with arrow keys?
- Are date pickers keyboard operable?

**Screen reader testing.** Screen reader / browser combinations:
- NVDA + Firefox (Windows) — most common among screen reader users
- JAWS + Chrome (Windows) — corporate standard
- VoiceOver + Safari (macOS/iOS) — critical for Apple users
- TalkBack + Chrome (Android)

Test with real screen readers: navigate by headings (H key in NVDA/JAWS), navigate form fields (F key), navigate landmark regions (R key). Verify: page title is meaningful, headings create a logical document outline, images have meaningful alt text, form fields have labels announced correctly, error messages are announced, live regions announce dynamic updates.

**Colour contrast.** WCAG 2.1 AA requires: 4.5:1 for normal text, 3:1 for large text (18pt or 14pt bold), 3:1 for UI components and graphical objects. Use the WebAIM Contrast Checker or browser DevTools colour picker. Do not rely on design-time colour values — measure rendered pixels.

**Common component patterns to test:** Modal dialogs (focus management, aria-modal, aria-labelledby), Tooltips (triggered on focus, not just hover), Carousels (pause button, keyboard navigation), Accordions (aria-expanded state announced), Toast notifications (live region, appropriate politeness level).

## Common Mistakes to Avoid

- **Only running Lighthouse:** Lighthouse uses axe under the hood but only audits the initial page load. Dynamic content, modal dialogs opened mid-session, and form validation errors are not caught. Use axe in test automation with realistic user flows.
- **Adding ARIA without understanding it:** `aria-label` on a `<button>` that already has text creates a mismatch between visual and announced label. The first rule of ARIA is: if you can use a native HTML element, do so.
- **Testing only with mouse:** A product can have perfect axe scores and fail completely on keyboard alone. Manual keyboard testing is mandatory.
- **Colour contrast for default state only:** Interactive states (hover, focus, pressed, disabled) also require contrast compliance. Disabled states have different contrast requirements (3:1 is not required, but 4.5:1 is still the target for legibility).

## Output

An accessibility audit covering: automated axe scan results with severity breakdown, keyboard testing outcomes for all critical flows, screen reader test results for at least NVDA+Firefox, colour contrast audit for text and UI components, and a prioritised remediation list with WCAG criterion references.
