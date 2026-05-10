---
name: content-design
description: Content design — microcopy, error messages, empty states, onboarding copy, and conversational UI; use when writing or evaluating the words inside a product interface.
---

# Content Design

You treat the words inside a product as a design material — every label, error message, and tooltip is designed with the same rigour as a visual component, because the wrong word is a usability failure.

## When to Use

- Writing or reviewing UI copy (labels, buttons, error messages, empty states, tooltips)
- Designing an onboarding flow where the words guide users through unfamiliar territory
- Auditing a product's voice consistency — does it sound like one person or like twelve different teams wrote it?

## Core Principles

**Words are interface.** A button label is not a label — it's a control mechanism. A poorly labelled button causes wrong actions, support tickets, and confusion. Writing UI copy is product design, not copywriting.

**Clarity over cleverness.** Interface copy that requires thought to interpret has failed. A user reading an error message is already frustrated; compound confusion with wordplay and you've compounded failure. Save wit for moments where users have cognitive space to appreciate it.

**Conversation is the model.** Good interface copy sounds like a trusted expert speaking to the user at the right moment. It's direct without being abrupt, helpful without being patronising, and specific without being verbose.

**Error messages are customer service.** The way your product responds when something goes wrong defines the relationship. An error message that says "Error: null" has provided no service. An error message that says "We couldn't save your changes — please check your internet connection and try again" has treated the user like a human.

**Voice consistency builds trust.** Inconsistent voice (formal in settings, casual in onboarding, clinical in errors) signals a fractured product. Consistent voice signals a coherent, trustworthy product. Document the voice and enforce it.

## Approach

**Content design process:** Unlike copywriting (writing to a brief), content design involves: (1) understanding the user's task and context (what are they trying to do? what mental state are they in?), (2) understanding the technical constraints (character limits, dynamic content, localisation requirements), (3) generating multiple options, (4) testing options with users when stakes are high, (5) delivering with annotations explaining the content decisions (not just the final copy).

**Button label formula:** Verb + noun = clear action. "Save changes," "Delete account," "Send report." Avoid: "OK" (ambiguous — confirm what?), "Submit" (bureaucratic), "Click here" (links to what?), "Yes/No" (without context of the question). Exception: single-button dialogs where the context is clear ("Got it," "Done"). The label should complete the sentence "I want to..."

**Error message formula (Nicely Said, Kate Kiefer Lee & Nicole Jones):** (1) what happened (specific, no jargon), (2) why it happened (brief, only if useful), (3) how to fix it (specific, actionable). Example — bad: "Authentication error." Better: "We couldn't sign you in. Check that your email and password are correct, or reset your password." Best adds: "If this keeps happening, contact support." Include a path forward; never leave users stuck.

**Empty states:** Empty states are not failures — they're onboarding moments. A new user's empty dashboard is their first impression. Design empty states to: (1) explain what goes here ("Your saved items will appear here"), (2) set expectations ("Once you create a project, it shows up here"), (3) offer a clear next step ("Create your first project →"). The empty state is a conversion opportunity; treat it as one.

**Onboarding copy:** Progressive disclosure in copy: tell users what they need to know now, not everything they might need to know. Each step should have one primary message. Use second-person ("you") not third-person. Concrete over abstract ("We'll import your contacts" beats "Your data will be synchronised"). Acknowledge the user's investment ("Your setup is complete — here's what's ready for you").

**Voice and tone guide:** Voice is consistent (the personality of the product); tone adapts to context. The guide defines: personality attributes (e.g., "clear, direct, human" — with examples of what this means and doesn't mean), patterns to use ("we" for the product, "you" for the user), patterns to avoid (passive voice, jargon, hedging language), and tone adjustments by context (more formal in legal/security contexts, warmer in onboarding, concise in utility UI). Include a "this not that" section with before/after examples.

**Localisation considerations:** Design copy for translation from the start. Strings that expand significantly in German or contract in Japanese must have flexible containers. Don't embed variable text in the middle of a sentence ("You have [X] messages" can't always be translated as a substring). String IDs and context notes help translators produce natural translations.

## Common Mistakes to Avoid

- Writing placeholder text as instruction ("Enter your email address") — placeholders disappear on focus, are inaccessible to screen readers when field is filled, and should be examples, not instructions
- Using technical or internal terminology that users don't share ("Your API key has been rotated" to a non-technical user)
- Apologising for system errors you can't prevent (undermines trust) vs. taking responsibility for errors you could have prevented (builds trust) — know the difference

## Output

Content design outputs: (1) annotated UI copy in the design file (each string with decision rationale when non-obvious), (2) voice and tone guide, (3) error message library (catalogued by error type with copy for each), (4) empty state designs with copy, (5) content model (what content types exist, their character limits, localisation requirements). Content reviewed by a content designer before any user-facing string ships.
