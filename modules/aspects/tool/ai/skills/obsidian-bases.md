---
name: obsidian-bases
description: Author and edit Obsidian .base files - the YAML schema, filter syntax, formula gotchas (Duration, null-guarding), view types, and quoting rules. Use when writing a .base file, embedding a base view in a note, debugging a base that renders empty or errors, or adding a filter/formula to an existing base. Query a base from the shell via `obsidian-cli base:query` - see the vault skill for that pattern.
---

# obsidian-bases

`.base` files are YAML that define views (table, cards, list, map) over frontmatter
and file properties. Bases is a core plugin (no install). Query results from a
script via `base:query` - see `vault` for the temp-base recipe.

## Schema outline

```yaml
# Global filters apply to every view.
filters:
  and:
    - 'status == "active"'

# Formula properties, referenced elsewhere as formula.<name>.
formulas:
  days_old: '(now() - file.ctime).days'

# Display names, applied to note properties, file properties, and formulas.
properties:
  status:
    displayName: Status
  formula.days_old:
    displayName: "Days Old"

# One or more views over the same data.
views:
  - type: table         # table | cards | list | map
    name: "Active"
    limit: 30
    groupBy:
      property: status
      direction: ASC
    filters:            # narrower than the global filters, same syntax
      and:
        - 'priority > 3'
    order:              # columns / fields, in order
      - file.name
      - status
      - formula.days_old
    summaries:          # column -> named summary formula
      formula.days_old: Average
```

## Filters

A filter is either a **single string** or a **recursive object** with exactly
one of `and`, `or`, `not` at each level.

```yaml
filters: 'status == "done"'

filters:
  and:
    - 'status == "done"'
    - 'priority > 3'

filters:
  or:
    - file.hasTag("book")
    - file.hasTag("article")

filters:
  not:
    - file.hasTag("archived")
```

Nest freely:

```yaml
filters:
  or:
    - file.hasTag("tag")
    - and:
        - file.hasTag("book")
        - file.hasLink("Textbook")
```

### Operators

| op | meaning |
|---|---|
| `==` `!=` | equality |
| `>` `<` `>=` `<=` | ordering |
| `&&` `\|\|` `!` | logical |

## Properties

Three sources:

1. **Note properties** (frontmatter) - `note.author` or bare `author`.
2. **File properties** (metadata) - `file.name`, `file.mtime`, `file.tags`, `file.ext`.
   Full list: <https://help.obsidian.md/bases/functions#file>
3. **Formula properties** (computed) - `formula.<name>`, defined in `formulas:`.

The `this` keyword refers to the base file (or the embedding file when embedded,
or the active file when the base is in the sidebar).

## Formulas

The dangerous edges:

**Duration is not a number.** Subtracting two dates returns a `Duration`. To use
it as a number, access `.days` / `.hours` / `.minutes` / `.seconds` / `.milliseconds`
first, then apply `.round(...)` etc.

```yaml
# WRONG - .round on Duration
days_old: "(now() - file.ctime).round(0)"

# CORRECT
days_old: "(now() - file.ctime).days.round(0)"
```

**Null guard everything from frontmatter.** Properties may be absent.

```yaml
# WRONG - crashes when due is empty
days_until_due: "(date(due) - today()).days"

# CORRECT
days_until_due: 'if(due, (date(due) - today()).days, "")'
```

**Undefined formulas fail silently.** Every `formula.X` in `order:` or
`properties:` needs a matching entry in `formulas:`.

Common building blocks:

```yaml
formulas:
  status_icon: 'if(done, "✅", "⏳")'
  formatted_price: 'if(price, price.toFixed(2) + " dollars")'
  created: 'file.ctime.format("YYYY-MM-DD")'
  day_of_week: 'date(file.basename).format("dddd")'

# Date arithmetic - duration units: y|M|d|w|h|m|s
tomorrow: 'now() + "1 day"'
next_week: 'today() + "7d"'
```

Full function reference: <https://help.obsidian.md/bases/functions>.

## Views

```yaml
- type: table              # tabular; supports groupBy and summaries
  order: [file.name, status, due]
  summaries:
    price: Sum             # named summary; see docs for the full set

- type: cards              # gallery; order defines the fields shown
  order: [cover, file.name, author]

- type: list               # simple bulleted list
  order: [file.name, status]

- type: map                # requires lat/lng properties + Maps plugin
```

Summary names: `Average`, `Min`, `Max`, `Sum`, `Range`, `Median`, `Stddev`,
`Earliest`, `Latest`, `Checked`, `Unchecked`, `Empty`, `Filled`, `Unique`.
Docs: <https://help.obsidian.md/bases/views>.

## Complete example - task tracker

```yaml
filters:
  and:
    - file.hasTag("task")
    - 'file.ext == "md"'

formulas:
  days_until_due: 'if(due, (date(due) - today()).days, "")'
  is_overdue: 'if(due, date(due) < today() && status != "done", false)'

properties:
  status:
    displayName: Status
  formula.days_until_due:
    displayName: "Days Until Due"

views:
  - type: table
    name: "Active"
    filters:
      and:
        - 'status != "done"'
    order: [file.name, status, priority, due, formula.days_until_due]
    groupBy:
      property: status
      direction: ASC

  - type: table
    name: "Done"
    filters: 'status == "done"'
    order: [file.name, completed]
```

## Embedding

```markdown
![[MyBase.base]]

![[MyBase.base#View Name]]     # specific view
```

## YAML quoting - the two rules that bite

1. **Strings containing `:`, `#`, `|`, `[`, `]`, `{`, `}`, `,`, `&`, `*`, `?`,
   `<`, `>`, `=`, `!`, `%`, `@`, `` ` `` must be quoted.**

   ```yaml
   # WRONG
   displayName: Status: Active
   # CORRECT
   displayName: "Status: Active"
   ```

2. **Wrap a formula containing double quotes in single quotes.**

   ```yaml
   # WRONG
   label: "if(done, "Yes", "No")"
   # CORRECT
   label: 'if(done, "Yes", "No")'
   ```

## Troubleshooting

- **View renders empty**: the `filters:` block is either scoped wrong (global vs
  per-view) or references a property that doesn't exist. Add a debug view with
  no filter to confirm the dataset is non-empty. Use `file.hasTag()` for actual
  file tags; `tags.contains()` only sees frontmatter tags.
- **YAML error on open**: nine times out of ten it's rule 1 or 2 above.
- **`formula.X` shows blank**: `X` isn't defined in `formulas:`, or the formula
  errored (Duration used as number, missing null guard).

## References

- Syntax: <https://help.obsidian.md/bases/syntax>
- Functions: <https://help.obsidian.md/bases/functions>
- Views: <https://help.obsidian.md/bases/views>
- Formulas: <https://help.obsidian.md/formulas>
