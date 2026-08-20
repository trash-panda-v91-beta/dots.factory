---
name: nixpkgs-lookup
description: Look up packages in nixpkgs before adding overlays or custom derivations. Use when adding a new package, deciding whether a custom override is still needed, checking what version nixpkgs ships, or inspecting how nixpkgs builds something (source vs binary, darwin support, build inputs). Also use when the user asks "is X in nixpkgs", "what version does nixpkgs have", or "can we remove this overlay".
---

# nixpkgs-lookup

Before writing any custom derivation or overlay, check what nixpkgs already provides. Most packages are already there, often at the right version.

## Quick commands

**Version nixpkgs ships:**
```bash
nix eval --impure --raw --expr '(import <nixpkgs> {}).PACKAGE.version'
```

**Source URL (tells you: source build or binary fetch, and which repo):**
```bash
nix eval --impure --expr '(import <nixpkgs> {}).PACKAGE.src.url or (import <nixpkgs> {}).PACKAGE.src.urls'
```

**Supported platforms:**
```bash
nix eval --impure --expr '(import <nixpkgs> {}).PACKAGE.meta.platforms'
```

**Darwin-specific build inputs (xcbuild, cctools, etc.):**
```bash
cat $(nix eval --impure --raw --expr 'toString (import <nixpkgs> {}).PACKAGE.meta.position' | cut -d: -f1)
```
Or just read the derivation directly:
```bash
cat /nix/store/HASH-source/pkgs/by-name/HE/PACKAGE/package.nix
```
Get that path via:
```bash
nix eval --impure --raw --expr '(import <nixpkgs> {}).PACKAGE.meta.position'
```

**A file inside a package's source tree** (no nix store trawl needed):
```bash
ls $(nix eval --impure --raw --expr '(import <nixpkgs> {}).PACKAGE.src')/some/path/
```

**Home-manager options for a program:**
```bash
grep -r 'programs.PACKAGE' /nix/store/HASH-source/modules/programs/PACKAGE.nix
# find the hm source:
nix eval --impure --raw --expr '(import <nixpkgs> {}).home-manager.src'
# then:
cat PATH_FROM_ABOVE/modules/programs/PACKAGE.nix
```
Or just grep the already-fetched hm source we have on disk:
```bash
grep -rn "programs\.PACKAGE" /nix/store/*-source/modules/programs/ 2>/dev/null | head -10
```

## Deciding whether an overlay is still needed

Ask three questions:

1. **Is the version acceptable?** `nix eval ... .version` - if nixpkgs is already at the right version, the overlay is dead weight.
2. **Does it build on darwin?** Check `meta.platforms` includes `aarch64-darwin`. Then read the package.nix - if `xcbuild`/`cctools` are in `nativeBuildInputs` for darwin, nixpkgs already handles the xcrun issue.
3. **Does `programs.PACKAGE` exist in home-manager?** If yes, `programs.PACKAGE.enable = true` is enough - no overlay needed for the config either.

If all three pass: delete the overlay block and any `herdr-src`-style alias, update any references from `pkgs.PACKAGE-src` to `pkgs.PACKAGE.src`.

## Don't use `find` in the nix store

The nix store has hundreds of thousands of entries. `find /nix/store -name foo` will run for minutes. Instead:

- Use `nix eval` to get a direct store path, then `ls`/`cat` that path.
- Use `nix eval ... .meta.position` to jump straight to the source file.
- Use `nix show-derivation STOREPATH` to inspect a specific `.drv`.

## Common gotcha: overlay version vs nixpkgs channel

Our flake pins nixpkgs to a specific commit. The version you get from `nix eval --impure` uses the *system* nixpkgs channel, which may differ from the flake pin. To eval against the exact flake input:

```bash
nix eval --impure --expr '
  let pkgs = import (builtins.getFlake "path:/path/to/repo").inputs.nixpkgs {};
  in pkgs.PACKAGE.version
'
```

Or just check `flake.lock` for the nixpkgs rev and cross-reference [search.nixos.org](https://search.nixos.org) with that rev.
