# Dots Factory

Personal macOS dotfiles using [den](https://den.oeiuwq.com) (aspect-oriented Nix framework) and
nix-darwin + home-manager.

## Structure

### Aspect Placement Rule

- New concern (program, service, tool) → `aspects/<name>.nix`
- Concern with sub-files (kanata kbd files, nixvim plugins) → `aspects/<name>/default.nix` +
  siblings
- Aspect that grows too large → split into `aspects/<name>/` with `aspects/<name>/claude.nix`,
  `aspects/<name>/opencode.nix`, etc. — no `default.nix` required if import-tree picks up all files
- Nixvim plugin with an external counterpart → lives in that concern's aspect (e.g. gitsigns →
  `git.nix`)
- Nixvim plugin with no external counterpart → lives in `aspects/nixvim/`
- Feature bundle (composes other aspects) → `aspects/feature-<name>.nix`

See `docs/restructure-design.md` for full rationale and migration plan.

## Bootstrap (flake)

This repo uses **flake.nix + flake.lock** for input management. Key files:

- `flake.nix` — single source of truth for all flake inputs
- `flake.lock` — pinned revisions (updated by Renovate weekly, or manually via `nix flake update`)

To add or change an input: edit `flake.nix`, then run `nix flake lock` to update `flake.lock`.

## Hosts

- **PMB** — Defined here. Build with `nix build .#darwinConfigurations.pmb.system`.
- **CMB** — Defined in dots.corpo (`../dots.corpo`). Built via
  `nix build .#darwinConfigurations.cmb.system --override-input corpo path:../dots.corpo`.

## Common Tasks

```bash
mise run build    # dry-run build for current host
mise run switch   # build and activate (darwin-rebuild switch)
mise run diff     # show pending changes
mise run update   # update all flake inputs (flake.lock)
mise run check    # run linters + dry-run build
mise run fix      # run formatters
```

## Den Conventions

Use den skill.

## Adding packages or new software

Use add-aspect skill.
