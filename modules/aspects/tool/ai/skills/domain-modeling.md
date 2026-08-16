---
name: domain-modeling
description: Actively build and sharpen the project's domain model as you design - challenging terms, inventing edge-case scenarios, capturing glossary and ADRs as they crystallise. Auto-fires when the user is pinning down terminology, sharpening a vague term, recording an architectural decision, or when another skill (`grilling`, `coding`, `diagnosing-bugs`) surfaces a domain-relevant clarification that should be captured.
---

> Glossary lives in the repo's CONTEXT note; ADRs are separate notes at vault root. See the `vault` skill for the write pattern and file names.

# Domain Modeling

The **active** discipline of building a domain model during a session -
challenging terms, forcing precise language, capturing the glossary and ADRs
as they land. This skill is for changing the model, not just reading it
(that's a one-line vault read any skill can do).

## Challenge against the glossary

When the user uses a term that conflicts with the CONTEXT glossary, call it
out immediately:

> "Your CONTEXT says 'cancellation' means X, but you're using it as Y - which is it?"

## Sharpen fuzzy language

When the user uses vague or overloaded terms, propose a precise canonical:

> "You're saying 'account' - do you mean the Customer or the User? Those are
> different things in this codebase."

## Discuss concrete scenarios

When domain relationships are discussed, stress-test with specific scenarios.
Invent edge cases that force the user to be precise about boundaries between
concepts.

## Cross-reference with code

When the user states how something works, check whether the code agrees. On a
contradiction, surface it:

> "Your code cancels entire Orders, but you just said partial cancellation is
> possible - which is right?"

## Update CONTEXT inline

When a term is resolved, append it to the repo's CONTEXT note in the vault
right there - see `vault` for the write pattern. Don't batch these; capture
them as they land.

The CONTEXT is a glossary and nothing else. No implementation details, no
scratch pad, no decision log. If it isn't a domain term, it doesn't belong.

## Offer ADRs sparingly

Only offer to create an ADR when **all three** are true:

1. **Hard to reverse** - the cost of changing your mind later is real.
2. **Surprising without context** - a future reader will wonder "why did they
   do it this way?"
3. **The result of a real trade-off** - genuine alternatives existed and you
   picked one for specific reasons.

If any of the three is missing, skip the ADR. Filename and frontmatter are in
the `vault` skill.
