---
name: obsidian-cli
description: Interact with Obsidian vaults using the Obsidian CLI to read, create, search, and manage notes, tasks, properties, and more. Also supports plugin and theme development with commands to reload plugins, run JavaScript, capture errors, take screenshots, and inspect the DOM. Use when the user asks to interact with their Obsidian vault, manage notes, search vault content, perform vault operations from the command line, or develop and debug Obsidian plugins and themes.
---

# Obsidian CLI

Use the `obsidian-cli` command to interact with a running Obsidian instance. Requires Obsidian to be open.

## Command reference

Run `obsidian-cli help` to see all available commands. This is always up to date.

## Syntax

**Parameters** take a value with `=`. Quote values with spaces:

```bash
obsidian-cli create name="My Note" content="Hello world"
```

**Flags** are boolean switches with no value:

```bash
obsidian-cli create name="My Note" silent overwrite
```

For multiline content use `\n` for newline and `\t` for tab in `content=` and `append=`.
**Exception:** `details=` in `tasknotes:capture` does NOT interpret `\n` — it is a verbatim
template substitution.

## File targeting

Many commands accept `file` or `path` to target a file. Without either, the active file is used.

- `file=<name>` — resolves like a wikilink (name only, no path or extension needed)
- `path=<path>` — exact path from vault root, e.g. `folder/note.md`

Prefer `path=` when filenames contain special characters; `file=` lookup can mangle them.

## Vault targeting

Commands target the most recently focused vault by default. Use `vault=<name>` as the first
parameter to target a specific vault explicitly:

```bash
obsidian-cli vault=nil search query="test"
```

Always pass `vault=` explicitly when multiple vaults may be open.

## Common patterns

```bash
obsidian-cli vault=nil read path="folder/note.md"
obsidian-cli vault=nil create name="New Note" content="# Hello" template="Template" silent
obsidian-cli vault=nil append path="folder/note.md" content="New line"
obsidian-cli vault=nil search query="search term" limit=10
obsidian-cli vault=nil property:read path="folder/note.md" name="status"
obsidian-cli vault=nil property:set path="folder/note.md" name="status" value="done"
obsidian-cli vault=nil backlinks file="My Note"
obsidian-cli vault=nil daily:read
obsidian-cli vault=nil daily:append content="- [ ] New task"
```

Use `silent` to prevent files from opening in Obsidian. Use `total` on list commands to get a count.

## Searching

### Full-text search

```bash
obsidian-cli vault=nil search query="search term" path="Tasks" format=json
```

Supports Obsidian property filters: `[property: "value"]`

```bash
obsidian-cli vault=nil search query='[issue: "CAT-1234"]' path="Tasks" format=json
```

Returns a JSON array of file paths. Use `property:read` for individual field values, or
prefer `base:query` when you need multiple fields from multiple files.

### Base query (preferred for structured frontmatter queries)

`base:query` returns all requested fields in one structured JSON response — no follow-up
`property:read` calls needed. Use it whenever you need to filter notes by frontmatter and
read multiple fields from the results.

**Pattern:** create a temp `.base` file, query it, delete it:

```bash
obsidian-cli vault=nil create name="_tmp.base" overwrite silent content="
filters:
  and:
    - projects.contains(link(\"my-repo\"))
    - 'status != \"done\"'
properties:
  note.type:
    displayName: Type
  note.status:
    displayName: Status
  note.issue:
    displayName: Issue
  note.title:
    displayName: Title
  note.priority:
    displayName: Priority
views:
  - type: table
    name: Open
    order: [type, status, issue, title, priority]
"
sleep 1
obsidian-cli vault=nil base:query path="_tmp.base" view="Open" format=json
obsidian-cli vault=nil delete path="_tmp.base" silent
```

The `sleep 1` gives Obsidian time to index the new base file before querying.

#### Base filter syntax

```yaml
# Tag filter
- file.hasTag("task")

# Property equals
- 'status != "done"'

# Property contains wikilink
- projects.contains(link("repo-name"))

# Path prefix
- file.path.startsWith("Tasks/")

# Combine with and/or
filters:
  and:
    - file.hasTag("task")
    - or:
        - 'status == "open"'
        - 'status == "in-progress"'
```

#### Properties block

Reference properties by their bare name (not `note.` prefix in filters, but `note.` prefix
in the `properties:` block display names):

```yaml
properties:
  note.issue:
    displayName: Issue
  note.title:
    displayName: Title
  file.name:
    displayName: Name    # built-in file property
```

## Plugin development

### Develop/test cycle

After making code changes to a plugin or theme, follow this workflow:

1. **Reload** the plugin to pick up changes:
   ```bash
   obsidian-cli plugin:reload id=my-plugin
   ```
2. **Check for errors** — if errors appear, fix and repeat from step 1:
   ```bash
   obsidian-cli dev:errors
   ```
3. **Verify visually** with a screenshot or DOM inspection:
   ```bash
   obsidian-cli dev:screenshot path=screenshot.png
   obsidian-cli dev:dom selector=".workspace-leaf" text
   ```
4. **Check console output** for warnings or unexpected logs:
   ```bash
   obsidian-cli dev:console level=error
   ```

### Additional developer commands

Run JavaScript in the app context:

```bash
obsidian-cli eval code="app.vault.getFiles().length"
```

Inspect CSS values:

```bash
obsidian-cli dev:css selector=".workspace-leaf" prop=background-color
```

Toggle mobile emulation:

```bash
obsidian-cli dev:mobile on
```

Run `obsidian-cli help` to see additional developer commands including CDP and debugger controls.
