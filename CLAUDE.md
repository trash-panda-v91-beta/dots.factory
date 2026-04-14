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

## Bootstrap (noflake)

This repo uses **npins + with-inputs** instead of flakes. Key files:

- `default.nix` — entry point: loads npins sources, calls with-inputs, then flake-parts +
  import-tree
- `npins/sources.json` — pinned inputs (run `npins update <name>` to update a pin)
- `follows.nix` — input aliases and sub-input follows (replaces `flake.nix` inputs block)

## Hosts

- **PMB** — Defined here.
- **CMB** — Defined in dots.corpo (`../dots.corpo`). Built via
  `NPINS_OVERRIDE_corpo=../dots.corpo nix-build ...` (handled automatically by mise tasks).

## Common Tasks

```bash
mise run build    # dry-run build for current host
mise run switch   # build and activate (nix-build + darwin-rebuild activate)
mise run diff     # show pending changes
mise run update   # update npins inputs
```

## Den Conventions

Use den skill.

## Adding packages or new software

Use add-aspect skill.
