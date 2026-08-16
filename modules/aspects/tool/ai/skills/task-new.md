---
name: task-new
description: Create a new task in the current vault - and, on vaults with a tracker adapter, in the tracker too. Auto-fires when the user says "make a task", "capture this as a task", "add to backlog", "track this", "new ticket for", "create an issue for", "note this as a task", "new bug for X", "add a story for". Uses the universal task shape from the `vault` skill; on nil the vault-jira adapter creates the CAT ticket in the same pass.
---

# task-new

Create one task. Detect vault, write the note, let the tracker adapter fire if
there is one.

## 1. Detect vault + repo

Per the `vault` skill's selection rule.

```bash
REPO=$(basename "$(git rev-parse --show-toplevel)")
```

## 2. Gather the fields

Ask or infer from the conversation context - short, no ceremony. Skip a
question if the answer is already obvious.

| ask | vault field |
|---|---|
| what's the work? | title |
| type - default `task` (offer `story`, `bug`, `subtask`, `epic`) | `type` |
| priority - default `normal` | `priority` |
| estimated in days (`0.5`, `1`, `2`, ...) | `estimated` |
| scheduled - default today | `scheduled` |
| epic parent (optional; only if part of one) | `epic` |
| sprint (only if the user wants a non-current sprint on nil) | `sprint` |

## 3. Capture the vault note

Follow the tasknotes:capture pattern in the `vault` skill:

```bash
RESULT=$(obsidian-cli tasknotes:capture vault=$VAULT \
  title="$TITLE" \
  priority=$PRIORITY \
  scheduled=$SCHEDULED \
  details="$DESCRIPTION")
PATH_REL=$(echo "$RESULT" | jq -r .path)
test -f "$VAULTS_DIR/$VAULT/$PATH_REL" || { echo "wrong vault"; exit 1; }
```

Then set the universal fields with `property:set`:

```bash
obsidian-cli property:set vault=$VAULT path="$PATH_REL" name=type       value=$TYPE
obsidian-cli property:set vault=$VAULT path="$PATH_REL" name=estimated  value=$ESTIMATED
obsidian-cli property:set vault=$VAULT path="$PATH_REL" name=projects   type=list value='["[[<REPO>]]"]'
[ -n "$EPIC" ]   && obsidian-cli property:set vault=$VAULT path="$PATH_REL" name=epic   value=$EPIC
[ -n "$SPRINT" ] && obsidian-cli property:set vault=$VAULT path="$PATH_REL" name=sprint value=$SPRINT
```

Follow the `vault` writing rule for the Description body: brief and human,
dev-note voice, hyphen-minus only. **Link everything that could plausibly
become a note** - technologies, tools, companies, people, repos, concepts,
places, books, patterns. Cast wide. Unresolved links are breadcrumbs. See
`vault` for the full rule.

## 4. Adapter fires if configured

- **mist** - no adapter today. `issue:` stays empty. Done.
- **nil** - hand off to `vault-nil` (the Jira adapter). It reads the vault
  frontmatter, applies the mapping tables (estimated -> story points, type /
  priority / status), calls `jira issue create` with the right component /
  labels / epic parent, adds the ticket to the sprint (current sprint if
  `sprint:` is empty), and writes the returned `CAT-XXXX` back to the vault
  `issue:` field.

**On nil, run `leak-check` on the task description before it goes to Jira.** The
vault Description is the CAT ticket body - coworkers will read it. No ADR
pointers, no vault paths, no scratchpad phrasing. Restate the *why* directly.

## 5. Report

Tell the user:
- vault note path
- tracker id if the adapter fired
- next action - usually `orient` at the top of the next session will pick it up
