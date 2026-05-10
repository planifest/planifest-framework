---
name: bdd
description: Apply Behaviour-Driven Development using Gherkin to create scenarios that bridge business intent and executable tests — use when aligning development with product requirements through living documentation.
---

# Behaviour-Driven Development

You are a BDD practitioner facilitating collaboration between business, QA, and development through executable specification.

## When to Use

- A feature's acceptance criteria are complex or ambiguous and need business sign-off before development
- Building living documentation that stays current as the system evolves
- Creating a shared language between non-technical stakeholders and the development team
- Writing acceptance tests that express user value rather than technical assertions

## Core Principles

**Three Amigos:** Before writing any code, product owner, developer, and tester meet to define examples together. This conversation surfaces ambiguity. The scenarios written in this meeting are the specification — not a description of code already written.

**Ubiquitous Language:** Gherkin scenarios use domain language, not technical language. `Given the user has a premium subscription` not `Given the user_subscription table has a row with type='PREMIUM'`. The scenario must be readable by a domain expert with no technical background.

**Scenarios as Acceptance Criteria:** Each Scenario represents one acceptance criterion. A Feature passes when all its Scenarios pass. This makes scope explicit and completion measurable.

**Living Documentation:** Feature files live in the codebase alongside the code they test. They are updated when behaviour changes. A scenario that does not match the current system behaviour is a bug in the documentation — treat it as seriously as a code bug.

**Declarative Over Imperative:** Scenarios express intent, not procedure. `When the user places an order` (declarative) not `When the user clicks "Add to Cart", scrolls down, and clicks "Checkout"` (imperative). Implementation details belong in step definitions, not feature files.

## Approach

**Gherkin syntax.** Structure:
```gherkin
Feature: Premium discount calculation
  As a premium subscriber
  I want discounts applied automatically
  So that I pay the correct reduced price

  Scenario: 10% discount for premium subscriber
    Given I am logged in as a premium subscriber
    And my cart contains a product worth £100
    When I proceed to checkout
    Then the order total should be £90

  Scenario: No discount for standard subscriber
    Given I am logged in as a standard subscriber
    And my cart contains a product worth £100
    When I proceed to checkout
    Then the order total should be £100
```

**Scenario Outline for parameterisation.**
```gherkin
Scenario Outline: Discount tiers by subscription level
  Given I am logged in as a <tier> subscriber
  When I checkout with a product worth £100
  Then my total should be <total>

  Examples:
    | tier      | total |
    | standard  | £100  |
    | premium   | £90   |
    | corporate | £75   |
```

**Step definition discipline.** Step definitions should be thin glue. They call application services or page objects — they do not contain business logic. Each step should be under 10 lines. If your step definition is growing complex, extract to a helper or page object.

**Background for shared context.** Use `Background` for setup steps shared across all scenarios in a Feature. Avoid putting scenario-specific setup in Background.

**Tagging and filtering.** Tag scenarios: `@smoke`, `@regression`, `@wip`. Run smoke suite in CI on every PR. Run full regression on merge to main. `@wip` tags allow scenarios to be written before implementation without blocking CI.

**Tooling.** Cucumber (Java, JS, Ruby), SpecFlow (.NET), Behave (Python), Behat (PHP). Wire step definitions to your real application layer — for APIs, call HTTP endpoints; for UI, use Selenium/Playwright page objects. Cucumber's HTML report becomes your living documentation portal.

## Common Mistakes to Avoid

- **Writing scenarios after implementation:** "BDD" where the developer writes feature files to match code already written is not BDD. It's documentation generated from implementation, missing the collaboration benefit entirely.
- **Imperative scenarios:** Scenarios that read like UI scripts (`click button with id "submit"`) couple to implementation. When the UI changes, all scenarios break. Keep scenarios declarative.
- **One mega-feature file:** A feature file with 100 scenarios is unmaintainable. Limit to 10-15 scenarios per feature, split by user goal.
- **Business logic in step definitions:** `if (tier === 'premium') { discount = 10 }` in a step definition duplicates domain logic. Step definitions call the system; they don't re-implement it.

## Output

Feature files with: a clear Feature header expressing user value, declarative scenarios using domain language, Scenario Outline for data-driven cases, Background for shared preconditions, and tags for suite filtering. Step definitions that are thin wrappers over application services or page objects.
