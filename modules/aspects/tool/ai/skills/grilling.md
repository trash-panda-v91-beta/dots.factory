---
name: grilling
description: Interview the user relentlessly about a plan, spec, or design - one question at a time, resolving each branch before moving on. Use when the user says "grill me", "grill this", "stress-test this plan", "poke holes", "help me sharpen this", or when a design is fuzzy and the user asks for pushback. When the interview surfaces new domain terms or an ADR-worthy decision, chain into the `domain-modeling` skill inline to capture them as they land.
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering.

If a question can be answered by exploring the codebase, explore the codebase instead.

When a question surfaces a new domain term or a decision worth an ADR, hand off to `domain-modeling` inline - capture the term or ADR as the answer lands, then resume grilling.
