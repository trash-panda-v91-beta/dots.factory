---
name: fnox-secrets
description: Use fnox for every secret - inject, read, store, and rotate. Use when a task needs a token, API key or password, when asked to add, rotate or look up a stored secret, or when something fails because a credential is missing.
---

# fnox secrets

Secrets live in fnox, not in the environment, not in the keychain, not in a `.env` file.
Configs: global `~/.config/fnox/config.toml` (machine-wide providers and secrets), a
project `fnox.toml` (committed, references only), and `fnox.local.toml` (personal
overrides, keep out of git). `fnox config-files` shows what applies in the current
directory.

## Order of preference

1. `mcp__fnox__exec` - run a command with secrets injected. Output comes back with values
   replaced by `[REDACTED]`.
2. `fnox exec -- <cmd>` in the shell when MCP is unavailable.
3. `mcp__fnox__get_secret` / `fnox get NAME` - only when the value itself must be
   handled. Never print it, never write it into a file or a commit.
4. `mcp__fnox__request_secret` - if enabled, opens a local page where I type a missing
   value. Use it instead of asking me to paste a secret into chat.

Never open the fnox config to lift a value out by hand, and never fall back to
`env | grep`, `.env` files, hardcoded strings, or the macOS keychain.

## Store a new value

```sh
fnox set NAME                       # prompts with hidden input
printf '%s' "$VALUE" | fnox set NAME
fnox set NAME --generate --length 48
fnox set NAME --from-file ~/.ssh/id_ed25519
```

The provider is `--provider`, else the secret's current one, else `default_provider`. A
real value must go to an encryption provider: a read-only remote provider (such as
1Password) would record the text as an item reference instead of a secret. Never the
`plain` provider, and never pass a real value as a command argument.

Add `-g` for machine-wide secrets; project secrets go into the repo's `fnox.toml` without
it. Machine-specific values belong in `fnox.local.toml`.

## Rotate

Update the value at its source, then refresh the local cache - it serves the old value
until re-synced:

```sh
fnox sync -g NAME
```

## Check

```sh
fnox list         # names and descriptions, no values
fnox get NAME     # auth check - resolve one secret without printing it
fnox config-files # which config files apply here
```

Prefer `fnox get` over `fnox provider test`: the provider check can report false failures
even when real reads work.
