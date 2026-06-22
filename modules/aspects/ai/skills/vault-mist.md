---
name: vault-mist
description: Search, create, and manage personal notes in the mist Obsidian vault. Use for personal repos (dots.factory, nebular-grid), journal entries, evergreen notes, references, and clippings. Works through obsidian-cli — Obsidian must be running.
---

# Mist Vault — Personal

The mist vault follows [Steph Ango's vault approach](https://stephango.com/vault): bottom-up, minimal folders, emergent structure through links and properties rather than hierarchy.

## Vault location

`$VAULTS_DIR/mist`

## Personal rules

- **Avoid folders for organisation** — most notes live in the vault root
- **Avoid nested sub-folders** entirely
- **Use internal links profusely** — link the first mention of everything; unresolved links are fine (they're breadcrumbs)
- **Always pluralise tags** — never `book`, always `books`
- **Use `YYYY-MM-DD` dates** everywhere (properties, filenames, note titles)
- **Use the 7-point rating scale** for anything rated (see below)
- **Categories as a property**, not folders — Bases views surface them

## Folder structure

```
$VAULTS_DIR/mist/
  <most notes>.md          # root: personal writing, journal, evergreen, coding notes
  References/              # things outside your world: books, movies, places, people
  Clippings/               # things others wrote: essays, articles (via Web Clipper)
  Attachments/             # images, PDFs, audio, video — admin, not navigated
  Daily/                   # daily notes YYYY-MM-DD.md — linked to, not written in
  Templates/               # templates — admin
```

Two optional organisational folders (notes here would normally live in root):
- **Categories/** — top-level Bases overviews per category (Books, Movies, etc.)
- **Notes/** — example or onboarding notes

## Root vs References vs Clippings

| Note type | Where |
|---|---|
| Personal journal, journal fragments | root |
| Evergreen notes, essays, ideas | root |
| Coding: CONTEXT, ADRs, project notes | root |
| Book, movie, place, person, podcast | `References/` — named after the title/name |
| Article or essay written by someone else | `Clippings/` |
| Web-clipped page | `Clippings/` |

## Coding notes (CONTEXT, ADRs, issues)

Project metadata lives in root, not in a `Coding/` subfolder. The main note name equals
the repo name.

```
dots.factory.md
dots.factory - ADR 001 - use den.md
dots.factory - add pi agent.md
nebular-grid.md
```

### Frontmatter for coding notes

```yaml
---
project: dots.factory       # plain string — repo name
projects:                   # wikilink list — universal base:query filter
  - "[[dots.factory]]"
type: context | adr | issue
adr-number: 001             # type=adr only
issue: 42                   # type=issue only, GitHub issue number
status: active | archived
tags: [coding, projects]
date: 2025-06-19
---
```

`projects: ["[[<repo>]]"]` is the universal filter across all note types. Use it with
`base:query` (see `obsidian-cli` skill) to find CONTEXT, ADRs, and issues in one query.

## Properties convention

- Short names: `start` not `start-date`, `rating` not `my-rating`
- Default to `list` type if a property might ever hold more than one value
- Reuse property names across categories (`genre` works for books, movies, shows)
- Templates should be composable (e.g. `Person` + `Author` on the same note)

## 7-point rating scale

Used on any note with a `rating` property (integer 1–7):

| Rating | Label | Meaning |
|---|---|---|
| 7 | Perfect | Life-changing, go out of your way |
| 6 | Excellent | Worth repeating |
| 5 | Good | Enjoyable, no extra effort needed |
| 4 | Passable | Works in a pinch |
| 3 | Bad | Avoid if you can |
| 2 | Atrocious | Actively avoid |
| 1 | Evil | Life-changing in a bad way |

## Daily notes

Stored in `Daily/YYYY-MM-DD.md`. Used as anchor points linked from other notes — not written
in directly. Journal fragments are individual notes in root, named
`YYYY-MM-DD HHmm optional-title.md`, created with Obsidian's unique note hotkey.

## Prerequisites

- `obsidian-cli` requires Obsidian to be running
- Always target the vault explicitly when nil might also be open: `vault=mist`

## Workflows

### Find all notes for a repo

```bash
REPO=$(basename "$(git rev-parse --show-toplevel)")

obsidian-cli vault=mist create name="_tmp.base" overwrite silent content="
filters:
  and:
    - projects.contains(link(\"$REPO\"))
properties:
  note.type:
    displayName: Type
  note.status:
    displayName: Status
views:
  - type: table
    name: All
    order: [type, status]
"
sleep 1
obsidian-cli vault=mist base:query path="_tmp.base" view="All" format=json
obsidian-cli vault=mist delete path="_tmp.base" silent
```

Filter results client-side by `"Type"` to get CONTEXT (`context`), ADRs (`adr`), or issues
(`issue`). Read each with `obsidian-cli vault=mist read path="<path>"`.

### Read CONTEXT for the current repo

```bash
REPO=$(basename "$(git rev-parse --show-toplevel)")
obsidian-cli vault=mist read path="$REPO.md"
```

### Find a note by keyword

```bash
obsidian-cli vault=mist search query="deadlock" format=json
```

### Find backlinks to a note

```bash
obsidian-cli vault=mist backlinks file="dots.factory"
```

### Create a new ADR

Check the next ADR number from existing notes, then create:

```bash
REPO=$(basename "$(git rev-parse --show-toplevel)")
# Find next number
obsidian-cli vault=mist search query="[project: \"$REPO\"] [type: \"adr\"]" format=json

obsidian-cli vault=mist create silent \
  name="$REPO - ADR 003 - decision-title" \
  content="---\nproject: $REPO\nprojects:\n  - \"[[$REPO]]\"\ntype: adr\nadr-number: 003\nstatus: active\ntags: [coding, projects, adrs]\ndate: $(date +%Y-%m-%d)\n---\n\n# ADR 003 — Decision Title\n\n**Date**: $(date +%Y-%m-%d)\n**Status**: Accepted\n\n## Context\n\n## Decision\n\n## Consequences\n\n## Alternatives considered\n"
```

### Create an issue investigation note

```bash
REPO=$(basename "$(git rev-parse --show-toplevel)")
ISSUE=42
TITLE="short-slug"

obsidian-cli vault=mist create silent \
  name="$REPO - $TITLE" \
  content="---\nproject: $REPO\nprojects:\n  - \"[[$REPO]]\"\ntype: issue\nissue: $ISSUE\nstatus: active\ntags: [coding, projects, issues]\ndate: $(date +%Y-%m-%d)\n---\n\n# $REPO#$ISSUE\n\n## Investigation\n"
```

## When a skill asks for ADRs / CONTEXT for the current repo

1. Identify the repo: `REPO=$(basename "$(git rev-parse --show-toplevel)")`
2. Run the base query above — returns CONTEXT, ADRs, and issues in one call
3. Read CONTEXT (`"Type": "context"`) and ADRs (`"Type": "adr"`) with:
   `obsidian-cli vault=mist read path="<path>"`

If no results, the project hasn't been onboarded — offer to create the CONTEXT note in root.

## Authority

- **GitHub Issues** — authoritative for: status, assignee, labels, milestones
- **mist vault** — authoritative for: CONTEXT, ADRs, investigation notes, decisions, links, personal notes
