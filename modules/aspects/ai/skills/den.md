# Den — Aspect-Oriented Nix Framework

> Source: <https://den.oeiuwq.com> | <https://github.com/vic/den>

Den is both a **library** and a **framework** for NixOS/nix-darwin/home-manager configurations.
Core purpose: enabling **shareable, parametric, cross-class Nix configurations**.

- **Library** (`den.lib`): parametric dispatch functions; works without flakes; suitable for any
  module system (NixVim, Terranix, etc.)
- **Framework** (`modules/`): schema, context pipeline, batteries, flake output generation for
  nixos/darwin/homeConfigurations

---

## Philosophy

Traditional Nix wires config downward from hosts. Den inverts this:
**features (aspects) are primary**, hosts just select which apply. This eliminates duplication and
enables one-line feature additions/removals.

**Core problem Den solves**: sharing reusable, parametric cross-class Nix configurations across the
community — the social problem of wheel reinvention in Nix.

---

## Separation of Layers

| Layer | Purpose | Example |
|-------|---------|---------|
| **Schema** | Declare entities | `den.hosts.<arch>.<host>.users.<user>` |
| **Aspects** | Configure behavior | `den.aspects.<name>` |
| **Context** | Transform data flow through pipeline stages | `den.ctx` |
| **Batteries** | Reusable config patterns | `den.provides.*` / `<den/...>` |
| **Default** | Global settings for all hosts/users | `den.default` |

---

## Aspects

An aspect is an attrset of Nix modules across different classes — a single concern configured across
multiple domains simultaneously:

```nix
den.aspects.gaming = {
  nixos       = { pkgs, ... }: { environment.systemPackages = [ pkgs.steam ]; };
  darwin      = { pkgs, ... }: { homebrew.casks = [ "steam" ]; };
  homeManager = { ... }: { programs.mangohud.enable = true; };
};
```

### Aspect Structure — three attribute categories

**Owned configurations** (per-class modules):

```nix
den.aspects.igloo = {
  nixos.networking.hostName = "igloo";
  darwin.nix-homebrew.enable = true;
  homeManager.programs.vim.enable = true;
};
```

**Includes** (DAG-based composition):

```nix
den.aspects.igloo.includes = [
  { nixos.programs.vim.enable = true; }           # static — unconditional
  ({ host, ... }: { nixos.time.timeZone = "UTC"; }) # parametric — context-matched
  den.aspects.tools                                 # reference to another aspect
];
```

**Provides** (named sub-aspects for bidirectional config):

```nix
den.aspects.igloo.provides.gpu = { host, ... }:
  lib.optionalAttrs (host ? gpu) {
    nixos.hardware.nvidia.enable = true;
  };
# accessed via: den.aspects.igloo._.gpu  or  <igloo/gpu>
```

### Parametric Dispatch (the `__functor` pattern)

Aspects are functions. They declare needed context through their arguments —
**the shape of arguments IS the condition**, replacing `mkIf` sprawl:

```nix
# Runs in every context (no parameters)
den.aspects.base = { nixos = ...; };

# Runs only in host context
den.aspects.hostOnly = { host, ... }: { darwin = ...; };

# Runs only when both host AND user exist
den.aspects.userConfig = { host, user, ... }: { homeManager = ...; };
```

Den uses `builtins.functionArgs` to introspect at evaluation time, silently skipping functions that
lack required context. Context parameters are actual values (not module args), preventing infinite
loops.

### Parametric Constructor Variants

| Constructor | Behavior |
|---|---|
| `parametric` | Default: owned classes + static includes + matching functions |
| `parametric.atLeast` | Only function matching (no owned classes/static) |
| `parametric.exactly` | Exact matching instead of atLeast |
| `parametric.fixedTo attrs` | Ignores context, always uses given attributes |
| `parametric.expands attrs` | Extends received context before dispatch |

### Aspect Resolution

```nix
module = den.lib.aspects.resolve "nixos" den.aspects.igloo;
```

Collects class-specific attributes → recursively walks includes → applies parametric dispatch →
deduplicates → outputs unified deferred module.

---

## Context Pipeline

Den processes configurations through stages:

1. **Host context** — each `den.hosts.<system>.<name>` entry; applies host aspect with host params;
   for each user applies with `{host, user}`
2. **User context** — `into.user` creates `{host, user}` contexts per user
3. **Derived contexts** — batteries register `into.hm-host`, `into.hm-user`, `into.wsl-host`, etc.
4. **Deduplication** — `parametric.fixedTo` on first occurrence, `parametric.atLeast` on subsequent;
   prevents duplicate module application
5. **Home configurations** — `den.homes` entries bypass the host pipeline
6. **Output** — collected into `nixosConfigurations`/`darwinConfigurations`/`homeConfigurations`

### Context Type Anatomy

Each `den.ctx.<name>` entry carries:

- `provides.<name>` — functions mapping context data to aspect fragments
- `into.<other>` — functions generating derived contexts
- `meta.adapter` — filters/transforms aspects during resolution
- `includes` — aspect includes for battery injection
- `modules` — additional modules in resolved output

**Built-in context types**: `host`, `user`, `home`, `hm-host`, `hm-user`, `wsl-host`, `hjem-host`,
`hjem-user`, `maid-host`, `maid-user`

---

## Key Primitives

### `den.hosts`

```nix
den.hosts.aarch64-darwin.myhost.users.alice = {};
# options: name, hostName, system, class (nixos/darwin), users, resolved
# user options: name, userName, classes (default: ["homeManager"]), aspect, resolved
```

### `den.homes` (standalone home-manager configs)

```nix
den.homes.x86_64-linux.tux = { };        # → homeConfigurations.tux
den.homes.x86_64-linux."tux@igloo" = {}; # host-associated
```

### `den.aspects`

```nix
den.aspects.terminal = {
  includes = [ <mynamespace/some-dep> ];
  homeManager = { pkgs, ... }: { programs.zsh.enable = true; };
  darwin = { ... }: { ... };
};
```

### `den.default`

Global settings applied to all hosts/users:

```nix
den.default = {
  includes = [ <den/mutual-provider> <den/hostname> <den/define-user> ];
  homeManager.home.stateVersion = "24.05";
};
```

### `den.schema`

Shared metadata across all entities (distinct from aspects — configuration metadata that aspects
consume):

- `den.schema.conf` — applied to host, user, and home
- `den.schema.host` — host-specific base config
- `den.schema.user` — user-specific base config
- `den.schema.home` — home-specific base config

Freeform schema allows arbitrary attributes accessible within aspects:

```nix
den.schema.host.options.vpn-group = lib.mkOption { ... };
```

---

## Batteries (`den.provides.*` / `den._`)

Pre-built aspects for common patterns. Apply via `den.default.includes`, per-aspect `includes`, or
compose with `den.lib.parametric`.

| Battery | Purpose |
|---------|---------|
| `den._.define-user` | Creates OS-level user accounts (`isNormalUser`, home dir) across NixOS, Darwin, WSL, HM |
| `den._.hostname` | Sets `networking.hostName` from the host name |
| `den._.mutual-provider` | Bidirectional host↔user config influence |
| `den._.primary-user` | Marks user as admin/primary across NixOS, Darwin, WSL |
| `den._.user-shell "fish"` | Sets login shell + enables HM shell program |
| `den._.forward` | Forwards aspect config between aspects (for custom classes) |
| `den._.import-tree` | Imports legacy non-dendritic `.nix` files; auto-detects class from dir names (`_nixos/`, `_darwin/`, `_homeManager/`) |
| `den._.unfree ["pkg"]` | Allows specific unfree packages via `allowUnfreePredicate` |
| `den._.insecure ["pkg"]` | Allows specific insecure packages |
| `den._.tty-autologin` | TTY1 auto-login on NixOS |
| `den._.wsl` | Activates WSL config when `host.wsl.enable = true` |
| `den._.inputs'` | System-qualified `inputs'` (requires flake-parts) |
| `den._.self'` | System-qualified `self'` (requires flake-parts) |

---

## Namespaces

Create scoped aspect libraries:

```nix
imports = [ (inputs.den.namespace "mynamespace" false) ]; # local only
imports = [ (inputs.den.namespace "eg" true) ];           # local + exported as flake.denful.eg
```

Generates: `den.ful.eg`, `eg` (module arg alias), and optionally `flake.denful.eg`.

Pass upstream sources for merging: `inputs.den.namespace "eg" true [ inputs.some-remote ]`

---

## Angle Brackets Syntax

Setup:

```nix
{ den, ... }: {
  _module.args.__findFile = den.lib.__findFile;
}
```

Resolution priority:

1. `<den.x.y>` → `config.den.x.y`
2. `<aspect>` → `config.den.aspects.aspect`
3. `<aspect/sub>` → `config.den.aspects.aspect.provides.sub`
4. `<namespace>` → `config.den.ful.namespace`

Example: `<tools/editors>` instead of `den.aspects.tools.provides.editors`

---

## Mutual Providers

With `den._.mutual-provider` battery included:

```nix
# User contributes to host
den.aspects.alice.provides.igloo = { host, user }: {
  darwin.homebrew.casks = [ "some-app" ];
};

# Host contributes to user
den.aspects.igloo.provides.alice = { host, user }: {
  homeManager.home.packages = [ pkgs.special-tool ];
};

# User-to-user provisions also supported
# Standalone homes can be customized per host
```

---

## Custom Nix Classes

Custom classes forward their contents into target submodule paths on another class.

**The `forward` battery**:

| Parameter | Purpose |
|-----------|---------|
| `each = items` | List of items to forward |
| `fromClass = item: class` | Custom class name to read from |
| `intoClass = item: class` | Target class to write into |
| `intoPath = item: path` | Target attribute path in target class |
| `fromAspect = item: aspect` | Aspect to read custom class from |
| `guard` | Conditional forwarding based on predicates |
| `adaptArgs` | Transform module arguments before forwarding |
| `adapterModule` | Custom module type for forwarded submodules |

**Built-in example**: the `user` class auto-forwards to `users.users.<userName>` on whichever OS
class the host uses.

**Use cases**: platform-specific HM classes, cross-platform configs (nixos + darwin simultaneously),
role-based configs, git class with enable guards, NVF integration, impermanence.

### Splitting a custom class across multiple files (vic/vix pattern)

When an aspect has a custom class (e.g. `nixvim`) forwarded into another class, you can split
plugin config across multiple files **without `_` prefixes** by wrapping each file as a full
den/flake-parts module that contributes to the parent aspect's custom class attribute:

```nix
# modules/feature/editor/which-key.nix  ← loaded by import-tree, valid flake-parts module
{ dots, ... }:
{
  dots.editor.nixvim.plugins.which-key = {
    enable = true;
    settings = { preset = "helix"; /* ... */ };
  };
}

# modules/feature/editor/snacks.nix
{ dots, ... }:
{
  dots.editor.nixvim.plugins.snacks = {
    enable = true;
    settings = { picker.enabled = true; /* ... */ };
  };
}
```

This works because `dots.editor.nixvim` is a declared den option (a submodule), so files setting
it are valid flake-parts modules — import-tree loads them automatically, no `_` prefix needed.

**Key rule**: files that write raw nixvim options (e.g. `{ plugins.foo.enable = true; }`) are NOT
valid flake-parts modules and MUST be under `_`-prefixed dirs or inlined. Files that write
`dots.<aspect>.<customClass>.*` ARE valid and need no prefix.

**Real-world reference**: [vic/vix nvf modules](https://github.com/vic/vix/tree/main/modules/vic/nvf)
uses exactly this pattern — `which-key.nix`, `mini.nix`, etc. each set `vic.nvf.*` directly.

---

## Home Manager Integration

Supported home integration systems (all except `user` are opt-in):

- `homeManager` — standard Home Manager
- `hjem` — lightweight alternative (requires `inputs.hjem`)
- `maid` — nix-maid (requires `inputs.nix-maid`)
- `user` — built-in OS-level user class

```nix
den.hosts.x86_64-linux.igloo.users.tux.classes = [ "homeManager" ];
# or multiple: [ "homeManager" "hjem" ]
```

---

## `den.lib` Reference

| Function | Purpose |
|----------|---------|
| `parametric` / `parametric.atLeast` / `parametric.exactly` | Wrap aspects with context filtering |
| `parametric.fixedTo attrs` | Fix aspect to given attrs regardless of context |
| `canTake.atLeast` / `canTake.exactly` | Check if function accepts given params |
| `take.atLeast` / `take.exactly` | Conditionally apply functions based on params |
| `perHost` / `perUser` / `perHome` | Shorthand context-specific aspects |
| `statics` / `owned` / `isFn` / `isStatic` | Extract and inspect aspect components |
| `aspects.resolve` | Resolve aspect for a class with optional adapters |
| `__findFile` | Angle-brackets path resolver |

---

## Migration Strategy

Five progressive steps:

1. **Add Den as input** — integrate Den into flake, import its flake module
2. **Declare hosts** — move host declarations into `den.hosts`
3. **Import existing modules** — use `den._.import-tree` to load legacy non-dendritic modules
4. **Extract aspects** — convert features from legacy modules into Den aspects incrementally
5. **Remove legacy** — clean up original files as aspects replace them

Tips: start with a single host; legacy modules and Den aspects coexist without conflicts; test via
`nix run .#vm` before applying to hardware.

---

## Debugging

```bash
nix repl :lf .   # explore nixosConfigurations
```

Temporarily expose den for inspection:

```nix
flake.den = den;   # then access den.aspects, den.hosts, den.ctx in repl
```

Common issues:

- **Duplicate values**: use `den.lib.perHost` to restrict parametric functions in
  `den.default.includes`
- **Missing attributes**: trace context keys to verify expected parameters
- **Wrong class**: verify `host.class` matches system type (`"darwin"` not `"nixos"` on macOS)
- **Module not found**: files must be under `modules/`, not prefixed with `_`

Trace aspect includes: `den.lib.aspects.resolve` with `adapters.trace`

---

## Templates

Init with `nix flake init -t github:vic/den#<template>`:

| Template | Description |
|----------|-------------|
| `minimal` | Smallest possible setup — flakes only, no HM |
| `default` | Recommended starting point — flake-parts, HM, VM testing |
| `example` | Feature showcase — namespaces, angle-brackets, mutual providers, CI checks |
| `noflake` | Without flakes — uses npins + nix-maid |
| `nvf-standalone` | NVF Neovim config without NixOS — custom forwarding class |
| `microvm` | MicroVM host + guest — custom context pipeline, schema extensions |
| `ci` / `bogus` | Test suite / bug reproduction template |

The `ci` template is the best learning resource for understanding exactly how Den behaves.

---

## Project Structure (default template)

```text
modules/
  dendritic.nix    — flake-file + den setup
  hosts.nix        — den.hosts declarations
  defaults.nix     — den.default global settings
  igloo.nix        — host aspect
  tux.nix          — user aspect
  vm.nix           — VM test runner
```

`nix run .#vm` to test before applying to hardware.

---

## `import-tree`

Automatically imports all `.nix` files in a directory tree. Underscore prefix (`_dir/`) prevents
auto-loading. Den's `modules/` directory uses this pattern.

---

## Releases

Den is in the v0.x series with 180+ CI tests. No external dependencies — `flakeModule` only requires
nixpkgs lib. Commonly paired with `import-tree`.

- Bleeding-edge: `github:vic/den` (main branch)
- Latest release: `github:vic/den/latest`
- Versioned: `github:vic/den/v0.x`

---

## Ecosystem

- [import-tree](https://github.com/vic/import-tree) — recursive `.nix` file importer
- [flake-aspects](https://github.com/vic/flake-aspects) — dependency-free parametric aspect library
- [dendrix](https://dendrix.oeiuwq.com) — community aspect index
- [denful](https://github.com/vic/denful) — lazyvim-style configuration distribution (WIP)
- [flake-file](https://github.com/vic/flake-file) — declarative flake.nix generation
- [with-inputs](https://github.com/vic/with-inputs) — flake-like input handling without flakes

Real-world examples: `vic/vix`, `quasigod.xyz/nixconfig`, `Adda/nixos-config`, `drupol/infra`
