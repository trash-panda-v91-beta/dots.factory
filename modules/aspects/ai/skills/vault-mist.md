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

Project metadata lives in root, not in a `Coding/` subfolder. The main note name equals the repo name.

```
dots.factory.md            # CONTEXT note
dots.factory - ADR 001 - use den.md
dots.factory - add pi agent.md
nebular-grid.md
```

### Frontmatter for coding notes

```yaml
---
project: dots.factory
type: context | adr | issue
adr-number: 001            # type=adr only
issue: 42                  # type=issue only, GitHub issue number
status: active | archived
tags: [coding, projects]
date: 2025-06-19
---
```

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

Stored in `Daily/YYYY-MM-DD.md`. Used as anchor points linked from other notes — not written in directly. Journal fragments are individual notes in root, named `YYYY-MM-DD HHmm optional-title.md`, created with Obsidian's unique note hotkey.

## Prerequisite

`obsidian-cli` requires Obsidian to be running. If commands fail with "unable to find Obsidian", remind the user to open Obsidian first.

Always target the mist vault explicitly when nil might also be open:

```bash
obsidian vault="mist" <command>
```

## Workflows

### Find the CONTEXT note for a repo

```bash
obsidian vault="mist" read file="dots.factory"
```

Or by searching:

```bash
obsidian vault="mist" search query="project: dots.factory"
```

### List all ADRs for a repo

```bash
ls $VAULTS_DIR/mist/ | grep "^dots.factory - ADR"
```

### Create a new ADR

```bash
# Check next ADR number
ls $VAULTS_DIR/mist/ | grep "^dots.factory - ADR" | sort -V | tail -1

# Create the file
cat > "$VAULTS_DIR/mist/dots.factory - ADR 003 - flake-parts.md" <<'EOF'
---
project: dots.factory
type: adr
adr-number: 003
status: active
tags: [coding, projects, adrs]
date: YYYY-MM-DD
---

# ADR 003 — Flake Parts

**Date**: YYYY-MM-DD
**Status**: Accepted

## Context
...

## Decision
...

## Consequences
...

## Alternatives considered
...
EOF
```

### Start notes for a GitHub issue

```bash
gh issue view 42 --repo trash-panda-v91-beta/dots.factory
```

Then create `$VAULTS_DIR/mist/dots.factory - <issue-slug>.md`:

```markdown
---
project: dots.factory
type: issue
issue: 42
status: active
tags: [coding, projects, issues]
date: YYYY-MM-DD
---

# dots.factory#42 — <title>

**GitHub**: [#42](https://github.com/trash-panda-v91-beta/dots.factory/issues/42)

## Investigation
...
```

### Search investigation notes for a keyword

```bash
obsidian vault="mist" search query="deadlock"
```

### Find backlinks to a note

```bash
obsidian vault="mist" backlinks file="dots.factory"
```

### When a skill asks for ADRs / CONTEXT for the current repo

1. Identify the repo: `basename "$(git rev-parse --show-toplevel)"`
2. Read `$VAULTS_DIR/mist/<repo-name>.md` for CONTEXT
3. Check `ls $VAULTS_DIR/mist/ | grep "^<repo-name> - ADR"` for ADRs

If neither exists, the project hasn't been onboarded — offer to create the CONTEXT note in root.

## Authority

- **GitHub Issues** — authoritative for: status, assignee, labels, milestones
- **mist vault** — authoritative for: CONTEXT, ADRs, investigation notes, decisions, links, personal notes
