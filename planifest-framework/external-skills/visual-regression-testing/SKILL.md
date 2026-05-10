---
name: visual-regression-testing
description: Implement visual regression testing with screenshot diffing at component and page level using Percy, Chromatic, or Playwright snapshots — covering baseline management, diff thresholds, and CI review workflows.
---

# Visual Regression Testing

You are a senior SDET implementing visual regression testing to catch unintended UI changes before they reach production.

## When to Use

- Protecting a component library or design system against unintended visual regressions
- Catching layout breakages caused by CSS refactoring or dependency upgrades
- Validating that a Storybook component renders correctly across all its stories
- Replacing manual visual QA checks on every release

## Core Principles

**Screenshot Diffing, Not DOM Diffing:** Visual regression tests compare pixel-by-pixel (or perceptual hash) screenshots against approved baselines. DOM diffing misses rendering differences — a `display: flex` vs `display: grid` change may produce identical DOM but different visual output.

**Component Level Before Page Level:** Full-page screenshots are sensitive to content changes everywhere on the page. A new product in a product grid changes every page screenshot that includes it. Test at component/story level first — it narrows the diff scope and reduces false positives. Page-level snapshots are for critical layouts only.

**Baselines Are the Source of Truth:** A baseline is an approved screenshot. A diff is a change from baseline — it is either an intentional change (accept the new baseline) or a regression (reject). The review workflow must be fast or teams skip it. Tool-assisted review (Chromatic's UI, Percy's review queue) is essential.

**Dynamic Content Masks:** Dates, prices, user names, timestamps, and ads change between test runs. Mask them before snapshotting. Tools provide region masking: mark a bounding box as ignored in the diff. Without masking, every run with dynamic content produces false positives.

**Anti-Aliasing and Sub-Pixel Tolerance:** Screenshots taken on different OS or GPU configurations can differ by sub-pixel rendering. Configure a pixel difference threshold (Playwright: `maxDiffPixelRatio: 0.01`). This tolerates rendering noise without masking real regressions.

## Approach

**Tool selection:**
- *Chromatic*: Best for Storybook-based component libraries. Reviews every story automatically. Integrates with CI. Hosted baseline storage. Best-in-class for design systems.
- *Percy*: SaaS platform for full-page and component snapshots. Works with Playwright, Cypress, and Storybook. Cross-browser snapshot comparison.
- *Playwright snapshots*: Built-in, no SaaS required. `expect(page).toHaveScreenshot()`. Stored locally or in CI artifacts. Good for teams not using Storybook.
- *Storybook Chromatic*: If you have Storybook, Chromatic is the path of least resistance.

**Playwright visual regression:**
```typescript
test('checkout button renders correctly', async ({ page }) => {
  await page.goto('/checkout');
  // Mask dynamic price element
  await expect(page.getByTestId('checkout-summary')).toHaveScreenshot(
    'checkout-summary.png',
    {
      maxDiffPixelRatio: 0.01,
      mask: [page.getByTestId('live-price')],
    }
  );
});
```

**Chromatic with Storybook.**
```bash
npx chromatic --project-token=<token> --auto-accept-changes=main
```
On every PR: Chromatic detects changed stories, renders them, diffs against baselines, and posts a review link to the PR. Reviewers approve or reject changes in Chromatic's UI. On merge to main: baselines are updated.

**Baseline management strategy:**
- Baselines are locked to the `main` branch. PRs diff against `main` baseline.
- After intentional visual changes (design system update), bulk-accept new baselines with `--auto-accept-changes` on the release commit.
- Tag baseline snapshots with the component name and viewport (e.g. `button-primary--desktop`, `button-primary--mobile`).

**Viewport and breakpoint coverage.** Test at minimum: 375px (mobile), 768px (tablet), 1440px (desktop). Configure Playwright to run each visual test across viewports:
```typescript
// playwright.config.ts
projects: [
  { name: 'mobile', use: { viewport: { width: 375, height: 812 } } },
  { name: 'desktop', use: { viewport: { width: 1440, height: 900 } } },
]
```

**Reducing false positives.** Common sources:
- *Animations*: Disable CSS animations in test mode (`* { animation: none !important; }`)
- *Fonts*: Use `fonts.google.com` loaded fonts that vary by connection; use `page.waitForLoadState('networkidle')` before snapshotting
- *Dynamic dates*: Mask with `mask: [page.getByText(/\d{4}-\d{2}-\d{2}/)]`
- *Scrollbars*: Set `page.setViewportSize` explicitly; avoid OS-dependent scrollbar rendering

**Review workflow.** A PR with visual diffs must block merge until a human approves each diff. Integrations: Chromatic posts a GitHub status check that requires approval; Percy similarly blocks CI. Do not auto-approve diffs on feature branches — that removes the detection value entirely.

## Common Mistakes to Avoid

- **Full-page screenshots for everything:** A full-page snapshot of the homepage fails every time a blog post title changes. Scope screenshots to stable components, not dynamic pages.
- **No diff threshold:** Zero-tolerance pixel matching fails on sub-pixel font rendering differences across operating systems. Set a 1-2% pixel ratio tolerance.
- **Never reviewing diffs:** If the team bulk-approves diffs without looking, the tool provides no value. Treat unapproved visual diffs as build failures. Keep review time fast by keeping screenshot scope small.
- **Not disabling animations:** A button hover animation captured mid-transition will always diff against a static baseline. Disable animations for all visual regression test runs.

## Output

Visual regression coverage for: all Storybook stories (component level), critical page layouts at key breakpoints, and any page with a custom design not covered by the component library. A CI workflow that blocks PR merge on unapproved diffs, with a link to the visual review queue in the PR comment.
