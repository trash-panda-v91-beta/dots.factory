---
name: repo-layout-pmb
description: Where every repo, vault, and dotfile lives on PMB (personal Mac). Auto-fires when the agent needs to locate a personal repo by name, resolve `$REPOS` / `$VAULTS_DIR` on PMB, find dots.factory or any `github.com/<user>/*` repo, or answer "where is X" on the personal machine. PMB has no work repos, no dots.corpo, no nil vault.
---

# Repo Layout (PMB)

PMB is the personal Mac. It has **no work repos, no work-org tree, no dots.corpo,
no nil vault.** Anything work-shaped belongs on CMB.

## Roots

```text
$REPOS/
  github.com/<user>/<repo>          # personal repos only
```

Vault:

```text
$VAULTS_DIR/                        # = ~/vaults
  mist/                             # personal - the only vault on PMB
```

## Dotfiles

| Path | What it is |
|---|---|
| `$REPOS/github.com/trash-panda-v91-beta/dots.factory` | PMB dotfiles - nix-darwin + home-manager via den. Owns `flake.nix`, host config, personal skill pack. |

`dots.corpo` does **not** exist on PMB. Any reference to it in scripts or
skills is for CMB only.

## Personal repos

Under `$REPOS/github.com/<user>/`. Each repo is standalone. Common ones live
next to `dots.factory` in the same `<user>` tree.

## Vault routing

Always `mist` on PMB - there is no nil vault, no `vault-nil` skill, no Jira
integration. Every task, ADR, CONTEXT note goes to `$VAULTS_DIR/mist`.
