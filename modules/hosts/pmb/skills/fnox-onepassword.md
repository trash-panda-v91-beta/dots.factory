---
name: fnox-onepassword
description: 1Password-backed fnox secrets on PMB - create the vault item with op, record the reference in fnox, keep the offline cache fresh. Use when adding or rotating a secret that lives in 1Password, or when the onepass provider fails.
---

# fnox + 1Password (PMB only)

The 1Password provider (`onepass`, vault `NebularGrid`) is read-only: `fnox set` records a
reference, it does not create the item. The item comes first, and the value must never
pass through shell history or chat:

1. Create the item in 1Password, either in the app, or as an empty shell for me to fill
   in the app afterwards:

   ```sh
   op item create --vault NebularGrid --category "API Credential" --title "<Name>"
   ```

   For a value that can be generated, add `--generate-password=48,letters,digits` and skip
   the app step. Check any of this with `--dry-run` first.
2. Record the reference in fnox. Field names are the labels on the item:

   ```sh
   fnox set EXAMPLE_API_KEY "<Name>/credential" --provider onepass -g
   ```

   A full `op://NebularGrid/<Name>/<field>` reference also works.
3. Cache it locally so reads survive an `op` lock:

   ```sh
   fnox sync -g EXAMPLE_API_KEY
   ```

   The cache holds the old value, so re-run `fnox sync -g NAME` after rotating the item in
   1Password.

`op` must be signed in (desktop app integration) before the agent session starts - the
fnox MCP server never prompts in the terminal.
