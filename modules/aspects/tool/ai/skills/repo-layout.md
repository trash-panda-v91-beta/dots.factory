---
name: repo-layout
description: Reference for where repos, vaults, and dotfiles live on this machine (PMB). Use when you need to know where a specific repo is, which vault belongs to which context, or how $REPOS/$VAULTS_DIR are used.
---

# Repo Layout (PMB)

## Repo Roots

```text
$REPOS/
  github.com/<org>/<repo>        <- personal repos (github.com or no remote)
```

## Key Repos

| Path | What it is |
|---|---|
| `$REPOS/github.com/trash-panda-v91-beta/dots.factory` | PMB dotfiles - nix-darwin + home-manager via den |
| `$REPOS/github.com/trash-panda-v91-beta/ghossion` | personal project |
| `$REPOS/github.com/trash-panda-v91-beta/haunts` | personal project |
| `$REPOS/github.com/trash-panda-v91-beta/nebular-grid` | Kubernetes home lab |

## Vault Routing

- Personal `github.com` or no remote -> use `vault-mist` skill (`$VAULTS_DIR/mist`)

## MISE Trust

`$REPOS/github.com/trash-panda-v91-beta` is in `MISE_TRUSTED_CONFIG_PATHS`, so `mise` tasks run without prompting in any repo under that root.
