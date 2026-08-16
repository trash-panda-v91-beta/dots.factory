---
name: obsidian-cli
description: Use the obsidian-cli command to read, create, search, and modify notes and properties in a running Obsidian vault, and to develop or debug Obsidian plugins and themes. Use when the user asks to run vault operations from the shell, script vault edits, capture debug output, or reload a plugin during development. Bases queries and vault structure are in the vault and obsidian-bases skills.
---

# obsidian-cli

`obsidian-cli` is a shell interface to a **running** Obsidian instance. Every
call needs Obsidian open (`pgrep -x Obsidian` - see `vault`).

## Command reference

`obsidian-cli help` prints every available command. Trust it over anything here
that could go stale.

## Syntax

**Parameters** take a value with `=`. Quote values with spaces:

```bash
obsidian-cli create name="My Note" content="Hello world"
```

**Flags** are boolean switches with no value:

```bash
obsidian-cli create name="My Note" silent overwrite
```

Multiline `content=` / `append=` interpret `\n` and `\t` as escapes.

**Exception**: `details=` in `tasknotes:capture` does **not** interpret `\n` -
it's a verbatim template substitution into `{{details}}`. Put real newlines in
the shell string.

## File targeting

- `file=<name>` - resolves like a wikilink (name only, no path or extension).
- `path=<path>` - exact path from vault root, e.g. `folder/note.md`.

Prefer `path=` when filenames contain special characters; `file=` lookup mangles
them.

## Vault targeting

Commands default to the most recently focused vault. Always pass `vault=<name>`
as the **first** parameter to disambiguate:

```bash
obsidian-cli vault=mist search query="test"
```

### Plugin commands ignore `vault=`

**Raw file commands** honour `vault=<name>`: `read`, `create`, `append`,
`property:set`, `property:read`, `delete`, `search`, `base:query`, `backlinks`.

**Plugin-backed commands** - anything under a plugin namespace like
`tasknotes:capture`, `daily:read`, `daily:append` - run against whichever vault
Obsidian has **focused**. The `vault=` flag is parsed but silently ignored.

Before a plugin command, switch Obsidian focus first:

```bash
open "obsidian://open?vault=$VAULT"
sleep 2
```

Then **verify the result landed** in the right vault - the CLI returns
plausible-looking JSON even when it didn't:

```bash
PATH_REL=$(echo "$RESULT" | jq -r .path)
test -f "$VAULTS_DIR/$VAULT/$PATH_REL" || { echo "wrong vault"; exit 1; }
```

## `tasknotes:capture` traps

- **Passing `tags=` or `projects=`** suppresses the template's default
  frontmatter (no `aliases`, `categories`, `due`, etc.). Set them with
  `property:set` **after** capture.
- **`details=` is silently dropped** when the body template has no
  `{{details}}` placeholder. The stock `Templates/Task Template.md` has one.
- **List values** in `property:set` need JSON-array form with `type=list`:
  `value='["[[a]]","[[b]]"]'`. Comma-separated strings become one string.

## Common patterns

```bash
obsidian-cli vault=$VAULT read path="note.md"
obsidian-cli vault=$VAULT create name="New" content="# Hello" template="Template" silent
obsidian-cli vault=$VAULT append path="note.md" content="one more line"
obsidian-cli vault=$VAULT search query="term" limit=10
obsidian-cli vault=$VAULT property:read path="note.md" name="status"
obsidian-cli vault=$VAULT property:set path="note.md" name="status" value="done"
obsidian-cli vault=$VAULT backlinks file="note"
obsidian-cli vault=$VAULT daily:read
obsidian-cli vault=$VAULT daily:append content="- [ ] new task"
```

`silent` prevents the file from opening in the UI. `total` on list commands
returns a count instead of results.

**`append` writes at end-of-file** - it has no awareness of `## Section`
headings. To insert inside a section, read, splice, overwrite.

## Search

Full-text plus property-filter syntax:

```bash
obsidian-cli vault=$VAULT search query="deadlock"
obsidian-cli vault=$VAULT search query='[status: "open"]' format=json
```

Returns a JSON list of paths. For structured multi-field results, use the
temp-base + `base:query` pattern in the `vault` skill.

## Plugin development

Iterate on a plugin or theme:

```bash
obsidian-cli plugin:reload id=my-plugin       # pick up code changes
obsidian-cli dev:errors                       # fix and reload if any
obsidian-cli dev:screenshot path=screenshot.png
obsidian-cli dev:dom selector=".workspace-leaf" text
obsidian-cli dev:console level=error
```

Other useful developer commands:

```bash
obsidian-cli eval code="app.vault.getFiles().length"
obsidian-cli dev:css selector=".workspace-leaf" prop=background-color
obsidian-cli dev:mobile on
```

`obsidian-cli help` lists CDP and debugger controls too.
