---
name: review
description: Self-review a diff before opening a PR - walk the change for correctness, missing tests, dead code, over-engineering, and leaks. Auto-fires when the user says "review my changes", "review this diff", "look over the code", "self-review this", "before I open the PR", "check my work", or when `coding` finishes an implementation session. Different from `review-comments` (which triages incoming PR feedback from bots and humans).
---

# review

Walk the diff before it becomes a PR. Correctness first, then everything else.

## 1. Frame the diff

```bash
git status
git diff --stat
git diff --stat main...HEAD    # if branched
```

Read the largest hunks first - that's where the risk is. Skim the rest.

## 2. Correctness pass

For every changed function or block:

- **Does it do what the task said?** Cross-reference against the CONTEXT / task
  scratchpad from `orient`. If the task description doesn't match the diff,
  surface the delta - either the task was under-specified or the diff scope crept.
- **Edge cases named**: empty inputs, nulls, boundary numbers, unicode, timezones.
- **Error paths**: are the failure branches deliberate, or was the happy path
  the only thing tested? If the code can fail silently, that's a red flag.
- **Concurrency / ordering**: any shared state, retries, timeouts, or async
  boundaries? Name what happens if two callers race.

## 3. Test pass

- **Every new public function has a test.** If it doesn't, ask why.
- **The tests test behavior, not shape** - see `coding` skill's philosophy.
- **Run the repo's pre-PR checks**:
  - cat/* repos and dots.factory: `mise run check` and `mise run test`.
  - Repos without mise: run the linter and test command declared in the repo's
    AGENTS.md.
  - Never open a PR with either red.
- **Deleted a test?** Justify it out loud (feature removed vs coverage lost).

## 4. Over-engineering pass

Always chain into `ponytail-review` here - it walks the diff for reinvented
stdlib, speculative abstraction, dead flexibility, and boilerplate nobody
asked for. Apply its findings before moving on.

Delete beats abstract. Boring beats clever.

## 5. Leak pass

- **Secrets / tokens / IDs** committed by accident (`git diff | grep -iE 'secret|token|api[_-]?key'`).
- **Debug prints** (`console.log`, `pp`, `dump()`, `.only()` in tests).
- **Absolute paths** to `$HOME` or a machine-local location.
- **Vault content in outbound** - see `vault` privacy fence. No ADR identifiers,
  scratchpad phrasing, or vault paths in code comments, commit messages, or PR
  descriptions.
- **Corpo terms in personal repos** and vice versa - depends on where you are.

## 6. Comment pass

Run `code-comments` mentally against the diff. Every new comment: does it
explain *why*? If it restates the code, delete it.

## 7. Commit shape

- **One logical change per commit.** If a commit does two things, split it.
- **Commit message describes intent.** "Fix bug" is a no-op; "Guard for empty
  cart in checkout total" is the minimum bar.
- **No `WIP` / `fixup` / `oops` in the final history.** Squash or reword.

## 8. Ready?

If everything above is green, hand off to `create-pr`. If something's yellow,
loop back into `coding` for one more cycle.
