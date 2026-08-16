---
name: coding
description: The coding discipline - red / green / refactor as the inner cycle, tight feedback loop (typecheck + single-file test on every cycle, full suite once at the end), commit at cycle boundaries, self-review before opening a PR. Auto-fires when the user wants to implement a feature, add or build something new, fix a bug, write a function/method/class, or says "start coding" / "let's code this" / "add integration tests" / "red-green-refactor" / "test-first". Skip for trivial edits (typos, renames, comment tweaks, config bumps).
---

> **Per-repo context lives in the Obsidian vault, not the repo.** See the `vault` skill for reading CONTEXT and ADRs. Run `/setup-skills` on a repo with no CONTEXT note yet.

# Test-Driven Development

## Philosophy

**Core principle**: Tests should verify behavior through public interfaces, not implementation details. Code can change entirely; tests shouldn't.

**Good tests** are integration-style: they exercise real code paths through public APIs. They describe _what_ the system does, not _how_ it does it. A good test reads like a specification - "user can checkout with valid cart" tells you exactly what capability exists. These tests survive refactors because they don't care about internal structure.

**Bad tests** are coupled to implementation. They mock internal collaborators, test private methods, or verify through external means (like querying a database directly instead of using the interface). The warning sign: your test breaks when you refactor, but behavior hasn't changed. If you rename an internal function and tests fail, those tests were testing implementation, not behavior.

See [tests.md](tests.md) for examples and [mocking.md](mocking.md) for mocking guidelines.

## Anti-Pattern: Horizontal Slices

**DO NOT write all tests first, then all implementation.** This is "horizontal slicing" - treating RED as "write all tests" and GREEN as "write all code."

This produces **crap tests**:

- Tests written in bulk test _imagined_ behavior, not _actual_ behavior
- You end up testing the _shape_ of things (data structures, function signatures) rather than user-facing behavior
- Tests become insensitive to real changes - they pass when behavior breaks, fail when behavior is fine
- You outrun your headlights, committing to test structure before understanding the implementation

**Correct approach**: Vertical slices via tracer bullets. One test → one implementation → repeat. Each test responds to what you learned from the previous cycle. Because you just wrote the code, you know exactly what behavior matters and how to verify it.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
  ...
```

## Workflow

### 1. Planning

When exploring the codebase, read `CONTEXT.md` (if it exists) so that test names and interface vocabulary match the project's domain language, and respect ADRs in the area you're touching.

Before writing any code:

- [ ] Confirm with user what interface changes are needed
- [ ] Confirm with user which behaviors to test (prioritize)
- [ ] Identify opportunities for deep modules (small interface, deep implementation) - run the `/codebase-design` skill for the vocabulary and the testability checks
- [ ] List the behaviors to test (not implementation steps)
- [ ] Get user approval on the plan

Ask: "What should the public interface look like? Which behaviors are most important to test?"

**You can't test everything.** Confirm with the user exactly which behaviors matter most. Focus testing effort on critical paths and complex logic, not every possible edge case.

### 2. Tracer Bullet

Write ONE test that confirms ONE thing about the system:

```
RED:   Write test for first behavior → test fails
GREEN: Write minimal code to pass → test passes
```

This is your tracer bullet - proves the path works end-to-end.

### 3. Incremental Loop

For each remaining behavior:

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:

- One test at a time
- Only enough code to pass current test
- Don't anticipate future tests
- Keep tests focused on observable behavior

### 4. Refactor

After all tests pass, look for [refactor candidates](refactoring.md):

- [ ] Extract duplication
- [ ] Deepen modules (move complexity behind simple interfaces)
- [ ] Apply SOLID principles where natural
- [ ] Consider what new code reveals about existing code
- [ ] Run tests after each refactor step

**Never refactor while RED.** Get to GREEN first.

## Checklist Per Cycle

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Code is minimal for this test
[ ] No speculative features added
```

## Loop discipline

During an implementation session, keep the feedback loop tight:

- **Typecheck often.** After each cycle if the language has one - not just at the end.
- **Run the single test file** on every cycle. Instant.
- **Run the full test suite once** before considering the session done, and again after any
  cross-cutting refactor. On cat/* repos and dots.factory that's `mise run test`.
- **Typecheck / lint before PR** with the repo's pre-PR check task (`mise run check` on
  cat/* and dots.factory; see repo AGENTS.md elsewhere).
- **Commit at cycle boundaries** to the current branch. One passing cycle per commit is fine.
  Small commits beat one heroic diff.
- **Self-review before opening a PR.** Run the `review` skill - it walks the diff for
  correctness, dead code, missing tests, and over-engineering.
- **After the PR is out**, `review-comments` handles bot / human feedback rounds.

## Checking library APIs

Before implementing against a library or framework - reaching for a specific method,
prop, config option, or a recent version's syntax - use `context7-docs` to verify the
current API. Do not rely on training data. Library APIs churn faster than the model's
training cutoff.
