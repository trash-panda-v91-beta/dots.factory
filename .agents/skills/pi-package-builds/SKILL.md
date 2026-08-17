---
name: pi-package-builds
description: How pi-* packages (pi-web-access, pi-mcp-adapter, pi-neuralwatt, pi-lsp) are built in this repo, why they use a "whole-build FOD" pattern instead of the textbook nixpkgs split-FOD approach, and how to update their hashes when a flake input bumps.
---

## TL;DR

- `pi-lsp` has zero npm deps -> plain `stdenvNoCC.mkDerivation`, no FOD, hermetic.
- `pi-web-access`, `pi-mcp-adapter`, `pi-neuralwatt` have real npm deps and are built as **whole-build FODs**: `bun install` + `bun build` in a single fixed-output derivation, the tiny bundled `.js` is what lands in the store.
- When a flake input bumps, run the build; nix will report `got: sha256-...`; paste it into `outputHash`. That's the whole workflow.

## Reproducibility (one `outputHash` works on every host)

The whole-build FOD drift the old way: `bun install` with no lockfile resolved floating
semver ranges per machine/day, AND `bun build` inlines the absolute build dir
(`/nix/var/nix/builds/<n>/source/...`), which differs per build and per host. Both made
the FOD hash non-reproducible, so the pinned `outputHash` matched cmb or pmb but not both.

Two mechanisms keep the bundle byte-identical everywhere:

1. **Committed `bun.lock`** - each `packages/<pkg>/bun.lock` pins the resolution.
   The build copies it in, removes the source's own lockfile
   (`package-lock.json` / `pnpm-lock.yaml`, which bun re-migrates and drifts), then runs
   a plain `bun install --ignore-scripts` (**not** `--production`/`--frozen-lockfile` -
   both imply frozen and spuriously error with `lockfile had changes` on these graphs).
2. **Embedded-path normalization** - after `bun build`, `sed "s|$PWD|/bundle|g"` rewrites
   the inlined absolute module path to a constant so the store hash doesn't depend on the
   build dir. (The `*_default` identifier bun generates from the cwd basename is already
   constant: the sandbox cwd basename is always `source`.)

The FOD `outputHash` is now stable and reproducible - set it once, it holds on every host
until the next source bump.

## Why whole-build FOD (and not fetchBunDeps / buildNpmPackage)

The textbook nixpkgs pattern is:

1. Deps-only FOD (network) -> `node_modules/`
2. Pure sandboxed build -> bundle

We tried that. On macOS APFS it is **~4x slower** than the whole-build FOD:

| Step                                            | Whole-build FOD | Deps FOD + pure build |
|-------------------------------------------------|:---------------:|:---------------------:|
| `bun install`                                   | ~10s            | ~10s                  |
| Copy extracted `node_modules` into `/nix/store` | never           | **~1m40s per pkg**    |
| Recursive NAR hash of `node_modules`            | never           | **~30s per pkg**      |
| `bun build` bundle                              | ~1s             | ~1s                   |
| Total                                           | **~50s**        | ~3m+                  |

Why: nix has a well-known slow path for FODs whose output is a tree of many small files ([nix#7284](https://github.com/NixOS/nix/issues/7284), [nix#7519](https://github.com/NixOS/nix/issues/7519)). `node_modules` is exactly that. Nixpkgs' own `buildNpmPackage` avoids this by putting compressed **tarballs** in the FOD (`fetchNpmDeps`) and extracting them in the sandboxed build - but that requires `package-lock.json` with `integrity` fields on every entry, and the upstream lockfiles for these pi-* extensions don't have them (prefetch-npm-deps panics with `non-git dependencies should have associated integrity`).

`buildBunPackage` doesn't exist yet ([nixpkgs#255890](https://github.com/NixOS/nixpkgs/issues/255890)).

So: whole-build FOD is the pragmatic answer here. The single derivation lands only the tiny bundled `.js` (a few MB) in the store, avoiding the slow path entirely.

## Where sources come from

Source revisions are pinned via **npins** (`npins/sources.json`), not as flake
inputs. Each npins-pinned source is exposed to modules as `inputs.<name>` at
the flake output level (see `flake.nix`: `npinsSources` gets merged into
`inputs`), so package derivations still read `inputs.pi-web-access` etc.

Why npins here and flake inputs for the rest: these packages are just source
tarballs (they were `flake = false` inputs). npins gives us per-package
updates (`npins update pi-web-access`) which flake inputs don't. Real flakes
(nixpkgs, home-manager, darwin, den, nixvim, ...) stay in `flake.nix`.

## When (and how) to bump hashes

Automatic path (preferred):

```bash
mise run update    # bumps flake inputs (`nix flake update`), then npins
                   # sources (`npins update`), then obsidian, then runs
                   # `refresh-pi-hashes.sh` which walks each FOD-having
                   # pi-* package and rewrites outputHash from the build's
                   # `got: sha256-...` line.
```

`refresh-pi-hashes.sh` does both steps automatically: it regenerates each package's
`bun.lock` from the current npins source, then rebuilds and rewrites `outputHash`.
So `mise run update` (and the single-package command below) are fully self-contained -
no manual lock step needed.

External peers (`@earendil-works/*`) may float in the regenerated lock, but they're
`--external` in the build (never bundled), so they can't change `outputHash` - a
cosmetic lock rewrite is harmless.

Update a single package:

```bash
nix run nixpkgs#npins -- update pi-web-access    # bump source rev
packages/refresh-pi-hashes.sh                    # regen lock + bump FOD hash
```

Manual path (if the script chokes): a flake input bump will fail the build
with:

```
error: hash mismatch in fixed-output derivation '/nix/store/...-pi-web-access-*.drv':
         specified: sha256-<old>
            got:    sha256-<new>
```

Copy the `got:` value into `outputHash` in the package's `default.nix`.

If you're curious what changed, `nix log <drv-path>` shows the `bun install`
resolution.

## The isolation trade-off (in case someone asks)

Whole-build FODs grant network to the compilation step, not just the fetch step. That's a slightly larger trust surface than a split. Mitigations already in place:

- `src` is pinned to a git commit via the flake input (upstream can't sneak code without a commit bump).
- `--ignore-scripts` blocks npm/bun postinstall exec.
- Bundled output is byte-pinned by `outputHash` (drift fails loudly).

The [FOD sandbox escape CVE](https://github.com/NixOS/nix/security/advisories/GHSA-2ffj-w4mj-pg37) was patched in nix >=2.20.4. Keep nix current and this is fine for a personal dotfiles repo.

## Files

- `packages/pi-lsp/default.nix` - pure, no FOD.
- `packages/pi-web-access/default.nix` + `bun.lock` - whole-build FOD.
- `packages/pi-mcp-adapter/default.nix` + `bun.lock` - whole-build FOD.
- `packages/pi-neuralwatt/default.nix` + `bun.lock` - whole-build FOD.
- `packages/ponytail-pi/default.nix`, `packages/context7-pi/default.nix` - pure (no real deps, just bundle).

`refresh-pi-hashes.sh` regenerates each `bun.lock` from the current source before
rebuilding, so a source bump that changes `package.json` is handled automatically.
