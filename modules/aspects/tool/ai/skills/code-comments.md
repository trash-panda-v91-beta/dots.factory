---
name: code-comments
description: Rules for writing and pruning code comments - only explain *why*, never *what*. Use when writing any code (functions, classes, modules, config), reviewing comments, trimming docstrings, or when the user says "clean up comments", "are these comments necessary", or asks to remove inline explanations. Not for PR review comments (use review-comments for that).
---

Comments earn their place by explaining **why** — intent, trade-off, non-obvious constraint. Names
carry the **what**. Deletion is the default.

## The test

For each comment, ask: "If I delete this, what does the reader lose that isn't already in the code
five seconds away?" Nothing? Delete.

## Rules

1. **Never restate the filename or symbol.** `"""Settings for ecr-push."""` on a `Settings` class in
   `ecr-push/config.py` is zero information. Delete.
2. **Never restate a literal that lives in the code.** A docstring saying "14 (Time) + UTF-8 bytes
   of string fields" next to `size = 14 + ...` duplicates the source of truth. Name the constant
   (`_TIME_OVERHEAD_BYTES = 14`) and, if the number needs a *why*, put a one-line inline comment on
   the constant — not a docstring on the function.
3. **Cross-boundary contracts get docstrings.** Event models, public APIs, wire-format types — the
   docstring *is* the spec. Keep, keep terse.
4. **Config-file section headers: one line of intent, not decorated boxes.** ASCII `# ─────` bars in
   YAML/HCL are decoration, not information. One `# Reactive path: X -> Y` beats an eight-line ASCII
   box.
5. **Wire-flow module docstrings are fair.**
   `"""ecr-push Lambda: ECR Image Action (via SQS) -> image.collected."""` gives a reader the ends
   of the pipe in one line. `"""Settings for ecr-push."""` doesn't.
6. **TODOs stay only if they name *what next* and *when*.** `# TODO: fix this` is noise.
   `# TODO: move to shared cat/models once it ships` is a plan.

## Anti-patterns

- **Filename echo** — `"""ECR repo listing for repo-discovery."""` on `repo_discovery/ecr.py`.
- **Symbol echo** — `"""Yield tagged images pushed within the retention window."""` on
  `def _describe_tagged_images_in_retention_window(...)`. Rename or delete, don't do both.
- **Literal echo** — any comment or docstring that quotes a value that appears on the next line.
- **Ceremonial dividers** — `# ─────`, `# =========`, `# ***`.
- **Restated types** — `"""Returns a list of dicts."""` under `-> list[dict]`.
- **AI-slop preamble** — "This function handles the case where..." Cut straight to the *why*.

## Python mechanics

- Inline comments: 2 spaces before `#`, 1 space after — `x = x + 1  # compensate for fence-post`
- Block comments: align with the code they describe, full sentences, period optional on short ones
- Suppression comments (`# type: ignore`, `# pylint: disable=...`) require an inline reason — the
  suppression earns its place by naming *why* the rule doesn't apply here
- Source attribution: when using copied code or a non-obvious algorithm, link the source — one URL
  beats a vague `# from stackoverflow`; also satisfies Creative Commons attribution requirements
- Bug-fix comments: note *why* the fix is needed when it's non-obvious, especially browser quirks,
  race conditions, or workarounds — future readers need to know whether to remove it

## Review process

1. `grep -nE '^\s*#|"""' <files>` — pull every comment and docstring into view.
2. For each, run the test above in one sentence.
3. Delete restatements. Trim verbosity. Name constants that carry meaning. Keep genuine *why*.
4. Re-run lint + tests. Check the project's docstring rules (e.g. `ruff.toml` D-selectors) don't
   require what you removed.

## Signal vs noise

| Comment content | Default action |
|---|---|
| Restates filename or symbol | Delete |
| Restates a literal in the code | Name the constant, move *why* inline on it |
| Says *why* a value or choice was made | Keep, trim |
| Contract for another service / caller | Keep as docstring |
| ASCII decoration around a section | Replace with one-line intent |
| TODO with a plan | Keep |
| TODO without a plan | Delete or file an issue |
| Suppression comment without reason | Add inline reason or remove suppression |
| Source attribution for copied code | Keep - one URL is enough |
| Module docstring giving wire-flow | Keep, one line |
| Module docstring restating filename | Delete |
