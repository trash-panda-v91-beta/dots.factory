# dots.factory

Personal macOS dotfiles using [den](https://den.oeiuwq.com) (aspect-oriented Nix) on
nix-darwin + home-manager. Hosts: **PMB** (here) and **CMB** (in `../dots.corpo`).

## Common Tasks

```bash
mise run build    # dry-run build for current host
mise run switch   # build and activate
mise run diff     # show pending changes
mise run update   # update flake inputs (flake.lock)
mise run check    # linters + dry-run build
mise run fix      # formatters
```

`HOST_ALIAS=cmb mise run …` builds CMB (requires `../dots.corpo`).

## Layout

- `flake.nix` / `flake.lock` — single source of truth for inputs (Renovate-managed weekly)
- `modules/aspects/` — den aspects, one concern per file or folder
- `modules/aspects/feature-*.nix` — feature bundles composing other aspects
- `modules/aspects/nixvim/` — nixvim plugins with no external counterpart
- `packages/` — local package derivations
- `.agents/skills/` — repo-local skills (`add-aspect`); `.claude/skills` is a symlink for Claude Code/pi compatibility

## Conventions

- **Adding a package or new software** → use the `add-aspect` skill
- **Den / aspect authoring** → use the `den` skill
- **Nixvim plugin with an external counterpart** → goes in that concern's aspect (e.g. gitsigns → `git.nix`), not in `nixvim/`
- **Don't** create `docs/adr/` or `CONTEXT.md` here — see Agent skills below

## Agent skills

Repo metadata (CONTEXT, ADRs, ticket notes) lives in the **mist vault** under
`Coding/dots.factory`. Use the `vault-mist` skill to read or update them.
