---
name: vault
description: Shared vault conventions for the mist and nil Obsidian vaults - flat structure, typed frontmatter, TaskNotes capture, ADR/CONTEXT patterns, base:query recipe, privacy fence. Use when the agent needs to read, write, or query vault content; create an ADR or CONTEXT note; capture a task; or find notes for a repo. Jira-specific workflows live in vault-nil.
---

# Vault

Both vaults are flat: three tool-owned folders, everything else at root, typed by
`type:` frontmatter. Structure and conventions are identical - `vault-nil` layers
Jira sync on top for the work vault.

## Vault selection

Default: `mist`.

```bash
VAULT=mist
```

On CMB, the `vault-nil` skill provides a routing rule that flips this to `nil`
for work repos and layers Jira sync on top. On PMB or any machine where
`vault-nil` isn't loaded, always use `mist`.

Pass `vault=$VAULT` to every `obsidian-cli` call. Plugin commands
(`tasknotes:capture`, `daily:*`) silently ignore `vault=` - see `obsidian-cli` skill
for the URI-focus workaround.

`$VAULTS_DIR` points to the local vaults root; the two vaults are at
`$VAULTS_DIR/mist` and (on CMB only) `$VAULTS_DIR/nil`.

## Structure

Both vaults:

```
<vault>/
  Attachments/     images, PDFs (admin, invisible)
  Templates/       template notes + Templates/Bases/*.base
  TaskNotes/       TaskNotes plugin state (invisible)
  <ID> <title>.md  everything else - flat, typed by frontmatter
```

Nothing else lives in subfolders. Grouping is done by `type:` and `tags:`, surfaced
via Bases views (`Templates/Bases/*.base`) - not by folders.

## Writing vault content

Vault bodies - CONTEXT descriptions, ADR sections, task Description/Scratchpad,
daily notes - are written **brief and human**. Like a note left for a teammate:
plain sentences, active voice, no preamble ("This document tracks...",
"The purpose of this ADR is..."), no bullet-point sprawl when two lines fit.
Hyphen-minus only, never en-dash or em-dash. This is the global AGENTS.md rule;
restated here because it's the moment agents most often drift.

## Note types

`type:` frontmatter classifies every note.

| type | filename | notes |
|---|---|---|
| `context` | `<repo>.md` | one per repo; repo name is the ID |
| `adr` | `<repo> - ADR NNN - <slug>.md` | per-repo, sortable by number |
| `task`, `story`, `bug`, `subtask` | `YYYY-MM-DD HHMM <title>.md` | TaskNotes emits filename via `customFilenameTemplate` |
| `daily` | `YYYY-MM-DD.md` | daily-notes core plugin emits this |
| `reference` | `<canonical name>.md` | book, person, place - use the name that identifies the thing |
| `clipping` | `YYYY-MM-DD HHMM <title>.md` | Web Clipper output |
| `evergreen`, `journal` | `YYYY-MM-DD HHMM <title>.md` | anything else |

Rule: use the timestamp ID `YYYY-MM-DD HHMM` when nothing else is globally unique.
Books / people / places / repos have canonical names - use them.

## `projects:` - the universal filter

Every coding-related note carries `projects: ["[[<repo>]]"]`. That's the one field
that finds every note about a repo (CONTEXT, ADR, task) in a single query.

## CONTEXT

```yaml
---
project: dots.factory
projects:
  - "[[dots.factory]]"
type: context
status: active
tags: [coding]
---

# dots.factory

<one-paragraph description>

## Domain
…

## Constraints
…
```

Filename: `<repo>.md`. Written by `setup-skills` on onboard.

## ADR

```yaml
---
project: dots.factory
projects:
  - "[[dots.factory]]"
type: adr
adr-number: 001
status: active
tags: [coding, adr]
date: 2025-06-19
---

# ADR 001 - Decision title

**Date**: YYYY-MM-DD
**Status**: Accepted

## Context
## Decision
## Consequences
```

Filename: `<repo> - ADR NNN - <slug>.md`. Next number = count of existing ADRs for
the repo (base:query with `type == "adr"` and `projects.contains(link("<repo>"))`).

## Task capture (TaskNotes)

Every task note carries the same universal shape in both vaults. Tracker-specific
fields (`issue`, `epic`, `sprint`) stay empty when the vault has no tracker
adapter configured.

```yaml
---
type: task           # task | story | bug | subtask | epic
status: open         # open | in-progress | done
priority: normal     # none | low | normal | high
scheduled: 2026-08-20
due:                 # optional YYYY-MM-DD
estimated: 1         # number, days (0.5, 1, 2, ...); empty for unsized
projects: ["[[<repo>]]"]
blockedBy: []
issue:               # tracker id; empty on mist, CAT-XXXX on nil
epic:                # parent tracker id
sprint:              # tracker sprint id; empty on mist
---
```

**Tracker adapter** (optional, per vault) translates fields when writing to and
syncing from an external tracker. On mist there is no adapter today - the
fields are informational only. On nil, the `vault-nil` skill is the Jira
adapter; see it for the translation tables (estimated -> story points,
type/priority/status maps, sprint behavior).

### Capture flow

```bash
RESULT=$(obsidian-cli tasknotes:capture vault=$VAULT \
  title="short summary" \
  priority=normal \
  scheduled=$(date +%Y-%m-%d) \
  details="body content")
PATH_REL=$(echo "$RESULT" | jq -r .path)
```

Then, in order:

1. **Verify vault landing** (plugin commands ignore `vault=`):

   ```bash
   test -f "$VAULTS_DIR/$VAULT/$PATH_REL" || { echo "wrong vault"; exit 1; }
   ```

2. **Verify template headings** are present:

   ```bash
   grep -q '## Description' "$VAULTS_DIR/$VAULT/$PATH_REL" \
     && grep -q '## Scratchpad' "$VAULTS_DIR/$VAULT/$PATH_REL" \
     || echo "WARNING: template headings missing"
   ```

3. **Set `projects:`** with `property:set` (never in the capture call - `tags=` /
   `projects=` flags on capture suppress the template's frontmatter):

   ```bash
   obsidian-cli property:set vault=$VAULT path="$PATH_REL" \
     name=projects type=list value='["[[<repo>]]"]'
   ```

4. On nil, set the additional `issue:` and `type:` Jira user fields - see
   `vault-nil`.

TaskNotes settings (`tasksFolder = ""`, `taskTag = "task"`, `moveArchivedTasks = false`)
are managed by home-manager from `dots.factory/modules/aspects/tool/obsidian/default.nix`.
Do not edit `.obsidian/plugins/tasknotes/data.json` directly - it's a symlink to the
Nix store.

## Base query recipe

Structured queries across frontmatter use the temp-base pattern - create it, query
it, delete it:

```bash
REPO=$(basename "$(git rev-parse --show-toplevel)")

obsidian-cli vault=$VAULT create name="_tmp.base" overwrite silent content="
filters:
  and:
    - projects.contains(link(\"$REPO\"))
properties:
  note.type:      { displayName: Type }
  note.status:    { displayName: Status }
  note.title:     { displayName: Title }
  note.priority:  { displayName: Priority }
views:
  - type: table
    name: All
    order: [type, status, title, priority]
"
sleep 1
obsidian-cli vault=$VAULT base:query path="_tmp.base" view="All" format=json
obsidian-cli vault=$VAULT delete path="_tmp.base" silent
```

Filter results client-side by `type` field. On nil, add `note.issue` to
`properties:` and `order` to surface tracker keys.

Bases filter/formula reference: `obsidian-bases` skill.

## Obsidian must be running

```bash
pgrep -x Obsidian >/dev/null || { open -a Obsidian; sleep 3; }
```

Every `obsidian-cli` call needs the app open. Run this at the top of any script
that will make more than one call.

## Breadcrumbs - link generously

Unresolved wikilinks (`[[Deep Work]]` with no matching note) are **breadcrumbs**,
not bugs. Both vaults have hundreds. Don't fix them defensively - they're future
notes the user planned to write.

**When writing vault content, link everything that could become a note.** Cast
wide. Every unresolved link is a future backlink; every backlink is how the
vault answers "where did I write about X?" months later.

The rule of thumb: **would I ever plausibly want a note called `<X>`?** If yes,
wikilink the first mention now, even if the note doesn't exist. That covers -
but is not limited to:

- Technologies, tools, libraries, frameworks, protocols, standards
- Companies, vendors, products, services
- People (colleagues, authors, contacts)
- Repos, services, projects, teams
- Domain concepts, patterns, techniques, phrases you use often
- Places, events, meetings
- Books, papers, talks, podcasts
- Anything with a proper name, a distinct concept, or a reusable meaning

Err on the side of linking. Cost of a stray unresolved link: zero. Cost of a
missed link: no backlink when you need one.

**Don't link**:

- Generic verbs, adjectives, or common words ("error", "config", "the", "fix").
- One-off strings that only make sense in this note (a specific error message,
  a hash, a file path).
- Anything inside a code fence or a URL - wikilinks don't work there.

Wikilinks in **outbound** content (PR bodies, Jira, commit messages, code
comments) are never allowed - they don't render for the reader. Vault-only.

## Privacy fence

Vault content - CONTEXT, ADRs, task scratchpads - is local context for the agent's
reasoning. It never leaves the machine. No mention of vault paths, ADR identifiers
("ADR 003", "see ADR NNN"), scratchpad phrasing, or vault filenames in code
comments, docstrings, PR titles/descriptions, commit messages, Jira comments, or
any shared channel. If a reader needs the reasoning, restate it in the outbound
message directly. Keep the *why*, drop the pointer.
