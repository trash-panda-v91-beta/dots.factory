---
name: create-pr
description: >
  Create a pull request for the current branch. Use when the user says 'create a PR',
  'open a PR', 'make a pull request', 'create pr', 'raise a PR', 'submit a PR', 'ship
  this', 'push this up', 'let's PR this', or when they otherwise indicate the current
  work is ready for review. Also use when finishing a branch of work that has commits
  and no open PR yet.
---

Create a PR with `gh pr create`. Write it like a note to a teammate, not like documentation.

## Prep

```bash
git branch --show-current
git status --porcelain
git log <base>..HEAD --oneline           # what is going in
gh pr list --head "$(git branch --show-current)"  # already open?
```

If on `main` / `master` / `trunk`: cut a feature branch first. Derive the name from the intended title (kebab-case, optional conventional-commit prefix). If there are uncommitted changes, ask whether to include them - don't silently `git add -A`.

Read the diff before writing the body. If a vault note gives you background, use it for your own understanding only.

### Privacy fence (hard rule)

Vault content - CONTEXT, ADRs, scratchpad, any file under `$VAULTS_DIR/*` - is local context. Never appears in PR title, body, commit messages, or any other outbound text. No ADR numbers, no vault paths, no "see ADR NNN". If a reader needs the detail, write it directly into the body in your own words.

## Title

One line, conventional-commit style: `type: what changed`. No period. No AI adverbs.

## Body

Short. Human. Write like the dev who did the work is telling the reviewer what to look at.

**Do:**
- Two or three sentences of what and why, dropping anything obvious from the diff
- A short bullet list only when there is real structure worth showing (e.g. "3 files, 3 emoji swaps" beats one prose sentence)
- Call out anything reviewer-hostile (migration step, temporary hack, known follow-up)
- One-line diff-stat summary at the end when changes are countable and repetitive (`15 files, 15 insertions, 15 deletions`)

**Don't:**
- Open with "This PR…" or "The purpose of this PR is…"
- Restate the title
- Explain what the diff already shows
- Add `## Testing`, `## Screenshots`, `## Checklist` sections when you have nothing to say - leave them out entirely, no "N/A"
- Adverbs: "carefully", "thoroughly", "properly", "seamlessly", "cleanly"
- Marketing adjectives: "comprehensive", "robust", "elegant", "cohesive"
- Restate the emoji/label decisions if they are visible in the diff

## Style

- Plain language, active voice
- `-` (hyphen-minus), not `–` or `—`
- Backticks for code, file paths, identifiers, and any Slack `:emoji:` codes
- Fenced code blocks for anything longer than one identifier

## Open it

```bash
gh pr create --title "<title>" --body "<body>"
```

Flags:
- `--draft` when not ready for review
- `--repo org/repo --head user:branch --base master` when pushing from a fork to upstream
- `--base <branch>` when the target is not the default branch

## Examples

**Bad (AI-ish, verbose):**
```
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
```
Renames `authenticate()` to `verify_token()` across the codebase to match
the new naming convention (verb + object, not just verb).

Call sites updated in the same commit. No behaviour change.

12 files, 24 insertions, 24 deletions.
```
