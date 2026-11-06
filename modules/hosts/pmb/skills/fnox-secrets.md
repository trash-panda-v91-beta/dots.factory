---
name: fnox-secrets
description: Use fnox for every secret on PMB - inject, read, store, and keep the 1Password copy in sync. Use when a task needs a token, API key or password, when asked to add, rotate or look up a stored secret, or when something fails because a credential is missing.
---

# fnox secrets (PMB only)

Secrets live in fnox, not in the environment, not in the keychain, not in a `.env` file.
Global config: `~/.config/fnox/config.toml`. Providers there: `onepass` (1Password vault
`NebularGrid`, the default) and `age` (local encryption, also the offline cache that
`fnox sync` writes).

## Order of preference

1. `mcp__fnox__exec` - run a command with secrets injected. Output comes back with values
   replaced by `[REDACTED]`.
2. `fnox exec -- <cmd>` in the shell when MCP is unavailable.
3. `mcp__fnox__get_secret` / `fnox get NAME` - only when the value itself must be
   handled. Never print it, never write it into a file or a commit.
4. `mcp__fnox__request_secret` - if enabled, opens a local page where I type a missing
   value. Use it instead of asking me to paste a secret into chat.

Never open `~/.config/fnox/config.toml` to lift a value out by hand, and never fall back to
`env | grep`, `.env` files, hardcoded strings, or the macOS keychain.

## Add a secret: 1Password holds it, fnox points at it

The 1Password provider is read-only. `fnox set --provider onepass` records a reference, it
does not create the item. So the item comes first, and the value must never pass through
shell history or chat:

1. Create the item in 1Password (vault `NebularGrid`), either in the app, or as an empty
   shell for me to fill in the app afterwards:

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

Project-scoped secrets go into the repo's `fnox.toml` (committed, references only) instead
of `-g`; machine-specific values go into `fnox.local.toml` and stay out of git.

## Local-only or generated secrets

```sh
fnox set NAME -g --provider age              # prompts with hidden input
fnox set NAME -g --provider age --generate --length 48
fnox set NAME -g --provider age --from-file ~/.ssh/id_ed25519
printf '%s' "$VALUE" | fnox set NAME -g      # value from stdin
```

Never the `plain` provider. Never pass the value as an argument when it can be prompted or
piped.

## Check

```sh
fnox list         # names and descriptions, no values
fnox get NAME     # auth check - resolve one secret without printing it
fnox config-files # which config files apply here
```

Prefer `fnox get` over `fnox provider test`: the provider check can report a false
failure for `onepass` even when real reads work.
