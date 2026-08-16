---
name: leak-check
description: Final scan before any outbound write - PR body, commit message, Jira description, Jira comment, code comment, docstring, Slack message, or any text a stranger will read. **Auto-fires unconditionally at the last moment before send.** Catches vault paths, ADR pointers ("see ADR 003", "per ADR NNN"), scratchpad phrasing, `$VAULTS_DIR` / `Coding/` / vault note filenames, and any other reference to a private-side artifact the reader cannot open. Also catches the reverse: corp strings (`concur.com`, `CAT-XXXX`, service repo names) landing in personal-side files. Triggered by every outbound skill (`create-pr`, `review-comments`, `task-new`, `vault-nil` sync flows, `handoff`) as their mandatory final step; and directly on "check for leaks", "audit for leaks", "scan this", "make sure this doesn't leak".
---

# leak-check

A fast grep-based scan for two directions of leak. Run it before content
leaves your head into a place strangers can read.

## Direction 1 - Corp strings in personal files

Ban list, applied to any file under:

- `$REPOS/github.com/*/` (personal repos)
- `$REPOS/github.com/trash-panda-v91-beta/dots.factory/` (personal dotfiles)
- `~/.pi/agent/` (personal agent config)

Never allowed:

- `github.concur.com` (or any corp hostname)
- `jira.concur.com` / `concur.com` in any URL
- `CAT-<digits>` (or other work-tracker keys)
- Service repo names that only exist on the corp side (cima-*, tmas-*, plz/*,
  cia/*, cat/*)
- Corp product names in code / comments / docs
- Dynatrace tenant IDs, Kibana index names, corp Slack channels

One-liner scan:

```bash
grep -nEi 'concur\.com|CAT-[0-9]|jira\.concur|github\.concur|cima-|tmas-|plz/|\bcat/' <file>
```

Skip matches inside backticks that are naming the forbidden string itself
(e.g. this skill's own body).

## Direction 2 - Private strings in outbound text

Applied to any text going into:

- Commit messages, PR titles, PR bodies (any repo, work or personal)
- Jira issue descriptions and comments
- Slack messages, chat threads, external emails
- Code / docstrings / comments in any repo other than dots.factory
- Anything a coworker or the public would read

Never allowed:

- Vault paths (`$VAULTS_DIR`, `~/vaults`, `/mist`, `/nil`, `Coding/`)
- ADR identifiers used as pointers ("ADR 003", "see ADR NNN", "our ADR on X")
- Scratchpad phrasing or vault filenames
- `dots.factory` / `dots.corpo` paths in code that ships publicly
- References to personal skills the reader doesn't have (e.g. `vault`,
  `orient`, `coding` in a public repo's README)

One-liner scan (bash):

```bash
grep -nEi '\$VAULTS_DIR|vaults/(mist|nil)|Coding/|ADR [0-9]{2,4}|Scratchpad|dots\.factory|dots\.corpo' <text>
```

If the reader might genuinely need the *reasoning*, restate it in the outbound
text in your own words. Never point at a path or identifier they cannot open.
Keep the *why*, drop the pointer.

## When to run

**Before writing** to a file under a personal-side path (Direction 1):

```bash
# after generating the intended content into $TMP
grep -nEi 'concur\.com|CAT-[0-9]|jira\.concur|github\.concur|cima-|tmas-|plz/|\bcat/' "$TMP" \
  && { echo "LEAK: corp strings in personal file"; exit 1; }
```

**Before committing / opening a PR / posting a Jira comment** (Direction 2):

```bash
# from `review` skill, before hand-off to create-pr
git diff --cached | grep -nEi '\$VAULTS_DIR|vaults/(mist|nil)|Coding/|ADR [0-9]{2,4}|Scratchpad|dots\.factory|dots\.corpo' \
  && { echo "LEAK: private strings in outbound diff"; exit 1; }

# for a PR body / commit message / Jira comment held in $TEXT
grep -nEi '\$VAULTS_DIR|vaults/(mist|nil)|Coding/|ADR [0-9]{2,4}|Scratchpad|dots\.factory|dots\.corpo' <<<"$TEXT" \
  && { echo "LEAK: private strings in outbound text"; exit 1; }
```

## When a match is a false positive

- **This skill itself** and other skills that document the forbidden strings
  (`vault`, `vault-nil` privacy fence, global AGENTS.md dashes rule) - they name
  the forbidden strings to explain them. Allowed. Skip the check on this file.
- **Naming a skill by its filename** in a public README - e.g. "see `vault` in
  the skill pack" - is a leak on Direction 2 because the reader can't open it.
  Rephrase.

## What to do on a match

1. Surface every match with line number.
2. Ask the user for each one: is this deliberate (naming the forbidden thing,
   e.g. inside a `code fence`) or accidental?
3. Rewrite the accidental ones. If the reader needs the *why*, restate it
   directly; never point at a path.
4. Re-scan until clean before the write / commit / PR happens.
