---
name: create-pr
description: Create a pull request for the current branch. Use when the user says 'create a PR', 'open a PR', 'make a pull request', or 'create pr'.
---

Create a PR for the current branch using `gh pr create`.

## Before opening

```bash
git log main..HEAD --oneline   # commits going in
gh pr list                     # confirm no open PR for this branch
```

Read the diff. If there's a vault note for this project, check it for context.

## Title

One line, conventional-commit style: `type: what changed`. No period.

## Body

Keep it short. Omit anything obvious from the diff.

```markdown
## What

One or two sentences. What changed and why — not how.

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
