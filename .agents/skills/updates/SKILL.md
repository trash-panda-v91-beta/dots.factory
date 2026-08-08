---
name: updates
description: How to update inputs (flake inputs, npins sources, Obsidian, pi-* FOD hashes) in this repo. Use when the user says "update", "bump flake", "update packages", "refresh hashes", or asks how to keep the repo current. Covers both `mise run update` and per-package updates.
---

## TL;DR

```bash
mise run update
```

Runs, in order:

1. `nix flake update` - bumps real flakes (nixpkgs, home-manager, darwin, den, nixvim, ...)
2. `npins update` - bumps pi-*, ponytail, context7-pi, koda-nvim, pi-nvim, opencode-nvim
3. `packages/update-obsidian.sh` - Obsidian version + hashes from GitHub releases
4. `packages/refresh-pi-hashes.sh` - rewrites `outputHash` for whole-build FOD pi-* packages when their source rev bumped

Then verify:

```bash
mise run build     # dry-run for the current host (or HOST_ALIAS=cmb)
mise run switch    # activate
```

## Where each input lives

| Input | Managed by | Update command |
|---|---|---|
| nixpkgs, nixpkgs-master, home-manager, darwin, den, nixvim, flake-parts, import-tree, sops-nix, zen-browser, hunk, vicinae, nix-homebrew, brew-src, homebrew-core, homebrew-cask, systems | flake input (`flake.nix`) | `nix flake update <name>` (or all: `nix flake update`) |
| pi-web-access, pi-mcp-adapter, pi-lsp, pi-neuralwatt, ponytail, context7-pi, koda-nvim, pi-nvim, opencode-nvim | npins (`npins/sources.json`) | `npins update <name>` (or all: `npins update`) |
| Obsidian (version + release-asset hashes in `packages/*obsidian*/default.nix`) | `packages/update-obsidian.sh` (curl -> GitHub Releases API) | script auto-detects latest tag |
| Whole-build FOD hashes for pi-web-access, pi-mcp-adapter, pi-neuralwatt (in each `packages/pi-*/default.nix` under `outputHash = "sha256-..."`) | `packages/refresh-pi-hashes.sh` (build, catch `got: sha256-...`) | run after any npins bump of those pkgs |

Why the split: real flakes live as flake inputs so nixpkgs' Nix ecosystem tooling works. The nine `flake = false` sources moved to npins in commit `dba2de4` because `npins update <pkg>` is a natural per-package update, and dots.corpo already uses npins - same mental model across both repos now.

## Automation

**Renovate** (weekly Monday 02:00-03:00, per `renovate.json`):
- Opens PRs for `flake.nix` / `flake.lock` bumps (nixpkgs and other real flake inputs)
- Does not see `npins/sources.json`, Obsidian versions, or pi-* FOD hashes

**GitHub Action `deps-update.yml`** (weekly Monday 06:00 UTC, or `workflow_dispatch`):
- Runs on macos-latest
- `npins update` -> `update-obsidian.sh` -> `refresh-pi-hashes.sh` -> `mise run check`
- Opens a PR on branch `deps/weekly-npins`

**CI (`ci.yml`)** runs on every PR (Renovate's, deps-update's, or manual):
- `mise run check` on macos-latest catches stale FOD hashes and broken
  builds before merge - if you land a Renovate PR that touches nixpkgs
  and bun's version drifted, the pi-* FOD hash mismatch will fail check.

### Manual follow-up on Renovate PRs

Renovate can't refresh FOD hashes on its own. If a Renovate PR fails CI
with a hash mismatch, pull the branch and run:

```bash
packages/refresh-pi-hashes.sh
git add packages/pi-*/default.nix
git commit --amend --no-edit && git push --force-with-lease
```

## Common tasks

### Just one package

Everything from the npins list:

```bash
npins update pi-web-access
packages/refresh-pi-hashes.sh   # only needed if this pkg has a whole-build FOD
mise run build                  # verify
```

Everything from the flake list:

```bash
nix flake update nixpkgs
mise run build
```

Obsidian only:

```bash
packages/update-obsidian.sh
mise run build
```

### After a Renovate PR arrives

Renovate PRs typically bump one flake input (or one npins pin) at a time. If the PR touches a package that has a whole-build FOD (pi-web-access, pi-mcp-adapter, pi-neuralwatt), the build will fail with a hash mismatch. On the Renovate branch:

```bash
packages/refresh-pi-hashes.sh
git add packages/pi-*/default.nix
git commit --amend --no-edit && git push --force-with-lease
```

Or wire Renovate's [`postUpgradeTasks`](https://docs.renovatebot.com/configuration-options/#postupgradetasks) to run `packages/refresh-pi-hashes.sh` automatically, if the Renovate runner has Nix available.

### After bumping nixpkgs

nixpkgs bumps can silently change:

- **The `obsidian` derivation shape** - `sourceRoot` overrides in `modules/aspects/platform/overlays.nix` may need adjustment. If Obsidian fails with "chmod: cannot access 'Obsidian.app'" or "no Makefile", read the log and adjust `sourceRoot` (currently `Obsidian ${old.version}-universal`).
- **The `bun` version** - which can change pi-* whole-build FOD outputs. `refresh-pi-hashes.sh` handles this.

If a nixpkgs bump touches something else and breaks the build, `nix log <drv-path>` on the failing derivation is your friend.

## Anti-patterns

- **Do not** hand-edit `outputHash` in pi-* package derivations. Run `refresh-pi-hashes.sh`.
- **Do not** hand-edit `flake.lock` or `npins/sources.json`. Use the update commands.
- **Do not** run `nix flake update <name>` for a package that's in npins - it doesn't exist there. Check the table above first.

## Related skills

- `pi-package-builds` - why pi-* packages are whole-build FODs and how they're structured
- `add-aspect` - adding new aspects / packages (may involve adding a new npins pin)
