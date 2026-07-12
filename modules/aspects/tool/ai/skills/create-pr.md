---
name: create-pr
description: Create a pull request for the current branch. Use when the user says 'create a PR', 'open a PR', 'make a pull request', or 'create pr'.
---

Create a PR for the current branch using `gh pr create`.

## Before opening

### 1. Branch and working tree

```bash
git branch --show-current      # current branch
git status --porcelain         # uncommitted changes?
```

If on `main` / `master` / `trunk`:

1. Derive a branch name from the intended PR title (kebab-case, conventional-commit
   prefix optional - e.g. `fix-vault-leak`, `feat-add-aspect`). Ask the user if unsure.
2. `git checkout -b <branch>`
3. If there are uncommitted changes, stage and commit them with a conventional-commit
   message that matches the PR title. Show the user the staged diff first if it's
   non-trivial.

If already on a feature branch with uncommitted changes: ask whether to commit them
into this PR or leave them out. Don't silently `git add -A`.

### 2. Sanity checks

```bash
git log main..HEAD --oneline   # commits going in
gh pr list                     # confirm no open PR for this branch
```

Read the diff. If there's a vault note for this project, read it for **background
understanding only**.

### Privacy fence (hard rule)

Vault content - CONTEXT notes, ADRs, scratchpad, ticket notes, any file under
`$VAULTS_DIR/*` - is local context. It must not appear in the PR title, body, commit
messages, or any other outbound text. No references to ADR numbers, vault paths,
"design rationale captured in X ADR", "verification notes in Y", etc. If a reader
needs the detail, write it directly into the PR body in your own words - never point
at a path they cannot open.

## Title

One line, conventional-commit style: `type: what changed`. No period.

## Body

Keep it short. Omit anything obvious from the diff.

```markdown
## Changes

One or two sentences. What changed and why - not how.

## Notes

Optional. Only include if something non-obvious needs calling out
(migration step, known limitation, follow-up ticket).
```

Leave out sections that have nothing to say.

## Style

- Plain language. No flowery adjectives, no unnecessary adverbs.
- Use `-` (hyphen-minus) not en dashes or em dashes.
- No "This PR…" opener.

## Open it

```bash
gh pr create --title "<title>" --body "<body>"
```

Add `--draft` if it's not ready for review.
