---
name: create-pr
description: >
  Create a pull request for the current branch. Use when the user says 'create a PR',
  'open a PR', 'make a pull request', 'create pr', 'raise a PR', 'submit a PR', 'ship
  this', 'push this up', 'let\'s PR this', or when they otherwise indicate the current
  work is ready for review. Also use when finishing a branch of work that has commits
  and no open PR yet.
---

Create a PR with `gh pr create`. Write it like a note to a teammate, not like documentation.

## Before Opening

```bash
git branch --show-current
git status --porcelain
git fetch origin                          # always - base may have moved
git log <base>..HEAD --oneline            # what is going in
gh pr list --head "$(git branch --show-current)"  # already open?
```

If on `main` / `master` / `trunk`: `git pull --ff-only` first, then cut the feature branch from
the fresh tip. Derive the name from the intended title (kebab-case, optional conventional-commit
prefix). If there are uncommitted changes, ask whether to include them - don't silently `git add -A`.

If the branch already exists but was cut from a stale base (`git log <base>..HEAD` shows the base
has moved on since), rebase onto the up-to-date remote base before pushing:

```bash
git rebase origin/main    # or origin/master, origin/trunk
```

Read the diff before writing the body. If a vault note gives you background, use it for your own
understanding only.

### Privacy Fence (Hard Rule)

Vault content - CONTEXT, ADRs, scratchpad, any file under `$VAULTS_DIR/*` - is local context. Never
appears in PR title, body, commit messages, or any other outbound text. No ADR numbers, no vault
paths, no "see ADR NNN". If a reader needs the detail, write it directly into the body in your own
words.

## Title

One line, conventional-commit style: `type: what changed`. No period. No AI adverbs.

## Body

Short. Human. Write like the dev who did the work is telling the reviewer what to look at.

**Do:**

- Two or three sentences of what and why, dropping anything obvious from the diff
- A short bullet list only when there is real structure worth showing (e.g.
  `swap :rocket: → :package: in three places` beats a paragraph)
- Call out anything reviewer-hostile (migration step, temporary hack, known follow-up)

**Don't:**

- Open with "This PR…" or "The purpose of this PR is…"
- Restate the title
- Explain what the diff already shows
- Add `## Testing`, `## Screenshots`, `## Checklist` sections when you have nothing to say - leave
  them out entirely, no "N/A"
- Adverbs: "carefully", "thoroughly", "properly", "seamlessly", "cleanly"
- Marketing adjectives: "comprehensive", "robust", "elegant", "cohesive"
- Restate the emoji/label decisions if they are visible in the diff

## Style

- Plain language, active voice
- `-` (hyphen-minus), not `-` or `-`
- Backticks for code, file paths, identifiers, and any Slack `:emoji:` codes
- Fenced code blocks for anything longer than one identifier

## Final scan - mandatory before sending

**Run `leak-check` against the drafted title + body before `gh pr create`.** The
PR is a public artifact - the reader has no access to your vault, ADRs,
scratchpad, or personal skill pack.

Specifically forbid: `see ADR NNN`, `per ADR X`, `see the vault`,
`per the CONTEXT note`, `$VAULTS_DIR`, `Coding/`, vault note filenames, any
`dots.factory` / `dots.corpo` path. If the reader needs the *reasoning*, restate
it in the PR body directly. Never point at a path or ADR they cannot open.

```bash
# scan the draft
grep -nEi '\$VAULTS_DIR|vaults/(mist|nil)|Coding/|ADR [0-9]{2,4}|Scratchpad|dots\.(factory|corpo)|see the vault' <<<"$TITLE"$'\n'"$BODY" \
  && { echo "LEAK - rewrite before sending"; exit 1; }
```

Re-scan until clean.

## Open It

```bash
gh pr create --title "<title>" --body "<body>"
```

Flags:

- `--draft` when not ready for review
- `--repo org/repo --head user:branch --base master` when pushing from a fork to upstream
- `--base <branch>` when the target is not the default branch

## Examples

**Bad (AI-ish, verbose):**

```text
## Summary

This PR comprehensively refactors the authentication helper to provide a
more robust and elegant token handling experience. It carefully renames
the legacy `authenticate()` function across the codebase to `verify_token()`
to align with our new naming conventions, ensuring a seamless developer
experience.

## Changes

- Renamed function across 12 files
- Updated all call sites
- Modified type hints

## Testing

Ran the full test suite.
```

**Good (short, human):**

```text
Renames `authenticate()` to `verify_token()` across the codebase to match
the new naming convention (verb + object, not just verb).

Call sites updated in the same commit. No behaviour change.
```
