# dots.factory

Personal macOS dotfiles using [den](https://den.denful.dev) (aspect-oriented Nix) on
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

- `flake.nix` / `flake.lock` - single source of truth for inputs (Renovate-managed weekly)
- `modules/aspects/categories.nix` - root aspects for the category namespaces
  (`tool`, `bundle`, `platform`, `rice`)
- `modules/aspects/platform/<name>.nix` - system-level configuration (nix daemon,
  darwin defaults, homebrew, library hooks, overlays)
- `modules/aspects/tool/<name>.nix` *or* `tool/<name>/default.nix` - one program (or
  tightly-coupled program family); folder form when there are companion files
- `modules/aspects/tool/<name>/nixvim/<plugin>.nix` *or* `tool/<name>/nixvim.nix` -
  editor integration co-located with its tool
- `modules/aspects/tool/nixvim/<plugin>.nix` - **vim-internal** plugins only
  (lsp, completion, mini-*, snacks-picker, ui, editing, etc.)
- `modules/aspects/bundle/<name>.nix` - composite aspects (mostly `includes`) - the
  capability layer the user enables
- `modules/aspects/rice/<theme>.nix` - cross-cutting themes (recolor multiple programs)
- `modules/hosts/<host>.nix` - host aspect; enables `<dots/bundle/platform>` plus
  host-specific user provides
- `modules/users/<user>.nix` - user aspect; manifest of capability bundles to enable
- `packages/` - local package derivations
- `.agents/skills/` - repo-local skills (`add-aspect`, `den`); `.claude/skills` is a
  symlink for Claude Code/pi compatibility

## Decision tree - where does X go?

```text
Is it a single program or a tightly-coupled program family?
    single file is enough          -> tool/<name>.nix
    has companion files            -> tool/<name>/default.nix + companions
Does it configure the system?      -> platform/<name>.nix    (nix.*, system.*, homebrew, overlays)
Does it compose multiple tools?    -> bundle/<name>.nix      (mostly includes; user enables these)
Is it a theme?                     -> rice/<theme>.nix       (recolors many programs)
Is it a nixvim plugin?
    extends another tool (X)       -> tool/<X>/nixvim.nix or tool/<X>/nixvim/<plugin>.nix
    vim-internal (lsp, ui, ...)    -> tool/nixvim/<plugin>.nix
```

The **discriminator question** for tool-vs-bundle: "Would I ever want to enable a
subset of this?" If no, it's a tool. If yes, split into tools and bundle them.

The user file is a list of bundles. To add a new capability: create a bundle and
include it.

## Conventions

- **Adding software** -> use the `add-aspect` skill
- **Den / aspect authoring** -> use the `den` skill
- **Aspect naming** - declare via `dots.<category>._.<name> = { … };` so
  angle-bracket includes (`<dots/<category>/<name>>`) resolve through the namespace's
  provides path
- **New files must be `git add`ed** before `nix build` sees them (flake source =
  git-tracked files)
- **Editor integration co-locates with the tool** - a nixvim plugin that extends git
  lives at `tool/git/nixvim/<plugin>.nix` and attaches to `dots.tool._.git`. Only
  vim-internal plugins (lsp, completion, ui, etc.) stay under `tool/nixvim/`.
- **Don't** create `docs/adr/` or `CONTEXT.md` here - repo metadata (CONTEXT, ADRs,
  ticket notes) is kept out-of-tree by the maintainer's personal workflow
