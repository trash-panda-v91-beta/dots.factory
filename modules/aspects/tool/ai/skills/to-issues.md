---
name: to-issues
description: Break a plan into independently-grabbable tickets on the project issue tracker using tracer-bullet vertical slices. Auto-fires when the user says "break this into issues", "break this into tickets", "file the tickets", "plan the work", or "split into subtasks". Files each slice through the `task-new` skill (which on nil creates real tracker issues via the Jira adapter).
---

# To Issues

Break a plan into independently-grabbable tickets using vertical slices
(tracer bullets). Files the tickets via `task-new` per slice - which means the
adapter (nil = Jira) creates real tracker issues in the same pass.

## When to reach for me

Only when the work is bigger than one task. For single tasks, `task-new` fires
directly. Not sure of the shape yet? Go through `grilling` first.

If the plan needs a **parent narrative** (problem statement, user stories,
rationale), put it in the **parent ticket's description** - do not write a
separate PRD document. The parent ticket body is your PRD.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes an issue reference (issue number, URL, or path) as an argument, fetch it from the issue tracker and read its full body and comments.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Issue titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the plan into **tracer bullet** issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

<vertical-slice-rules>

- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Any prefactoring should be done first

</vertical-slice-rules>

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?

Iterate until the user approves the breakdown.

### 5. Publish the issues

For each approved slice, call `task-new`. That skill writes the vault note
and, on nil, creates the tracker ticket via the Jira adapter. Publish in
dependency order so real tracker IDs can go into each successor's `blockedBy`
field.

Use this ticket body when `task-new` interviews you for the description:

<issue-template>
## Parent

A reference to the parent issue on the issue tracker (if the source was an existing issue, otherwise omit this section).

## What to build

A concise description of this vertical slice. Describe the end-to-end behavior, not layer-by-layer implementation.

Avoid specific file paths or code snippets - they go stale fast. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it here and note briefly that it came from a prototype. Trim to the decision-rich parts - not a working demo, just the important bits.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Blocked by

- A reference to the blocking ticket (if any)

Or "None - can start immediately" if no blockers.

</issue-template>

Do NOT close or modify any parent issue.
