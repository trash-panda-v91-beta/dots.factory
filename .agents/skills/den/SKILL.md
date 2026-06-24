---
name: den
description: Use when writing den aspects, debugging den framework issues, or working with the aspect-oriented Nix configuration in this repo
---

# Den - Aspect-Oriented Nix Framework

> Docs: <https://den.denful.dev> | Source: <https://github.com/denful/den>

Den is a **library** (`den.lib`) and **framework** (`modules/`) for NixOS/nix-darwin/home-manager
configurations. Its core purpose: enabling shareable, parametric, cross-class Nix configurations.

**The inversion**: traditional Nix pushes config downward from hosts. Den flips this - aspects
(features) are primary, hosts just select which apply. One aspect configures NixOS, Darwin, and
home-manager simultaneously. Adding bluetooth to three hosts is one line. Removing it is one delete.

---

## Four Core Concepts

| Concept | What it is | Where it lives |
|---------|-----------|---------------|
| **Entity** | Typed data record - a host, user, or home | `den.hosts`, `den.homes`, `den.schema` |
| **Aspect** | Composable unit of config spanning Nix classes | `den.aspects` |
| **Policy** | Function defining how entities relate and route | `den.policies` |
| **Quirk** | Structured data emitted by aspects, aggregated via pipes | `den.quirks` |

Entities declare _what exists_. Aspects declare _what it does_. Policies declare
_how things relate_.

---

## Aspects

An aspect is an attrset (or function returning one) that bundles modules for one or more Nix
classes. It is the primary unit of configuration.

```nix
# Bluetooth configured once, applied everywhere it is included
den.aspects.bluetooth = {
  nixos.hardware.bluetooth.enable = true;
  homeManager.services.blueman-applet.enable = true;
  darwin.homebrew.casks = [ "blueutil" ];
};

# Every host that includes it gets bluetooth
den.aspects.laptop.includes = [ den.aspects.bluetooth ];
den.aspects.desktop.includes = [ den.aspects.bluetooth ];
```

### Three attribute categories

**Owned configs** - modules per Nix class, either plain attrset or function form:

```nix
den.aspects.igloo = {
  nixos.networking.hostName = "igloo";             # attrset form
  darwin = { pkgs, ... }: {                        # function form
    environment.systemPackages = [ pkgs.git ];
  };
  homeManager.programs.starship.enable = true;
};
```

**Includes** - dependency DAG, three kinds of values:

```nix
den.aspects.igloo.includes = [
  # (1) Static attrset - unconditional
  { nixos.programs.vim.enable = true; }

  # (2) Static aspect leaf - gets { class, aspect-chain } args
  ({ class, aspect-chain }: { ${class}.foo = "bar"; })

  # (3) Parametric function - gets { host, user, home, ... }
  ({ host, ... }: { nixos.time.timeZone = "UTC"; })

  # Reference to another aspect (full DAG included)
  den.aspects.tools
];
```

**Provides** - named sub-aspects scoped to this aspect:

```nix
den.aspects.tools = {
  # Accessed as den.aspects.tools.editors  (provides. prefix optional)
  # or with angle brackets: <dots/tools/editors>
  editors = {
    homeManager.programs.helix.enable = true;
    homeManager.programs.vim.enable = true;
  };

  # Parametric provides
  work-vpn = { host, ... }:
    lib.optionalAttrs host.hasVpn {
      nixos.services.openvpn.servers.work.config = "...";
    };
};
```

**Cross-entity provides** - special keys that route across entity boundaries automatically:

```nix
den.aspects.igloo = {
  provides.to-users = { user, ... }: {          # -> all users on this host
    homeManager.programs.helix.enable = user.name == "alice";
  };
  provides.alice.homeManager.programs.vim.enable = true;  # -> specific user
};

den.aspects.tux = {
  provides.to-hosts = { host, ... }: {          # -> all hosts this user lives on
    nixos.programs.nh.enable = host.name == "igloo";
  };
  provides.igloo.nixos.programs.emacs.enable = true;      # -> specific host
};
```

---

## Parametric Dispatch

Aspect functions declare which context they need via argument names. Den introspects with
`builtins.functionArgs` and silently skips functions whose required args are not in scope.
**The argument shape IS the condition** - no `mkIf`, no `enable` flags.

```nix
# Always runs (no args = static)
den.aspects.firewall = {
  nixos.networking.firewall.enable = true;
};

# Runs only in host context
den.aspects.hostname-config = { host, ... }: {
  nixos.networking.hostName = host.hostName;
};

# Runs only when both host AND user are present
den.aspects.user-groups = { host, user, ... }: {
  nixos.users.users.${user.userName}.extraGroups = [ "wheel" ];
};

# Runs only for standalone home context
den.aspects.shell = { home, ... }: {
  homeManager.programs.zsh.enable = true;
};
```

**What happens when a parametric aspect encounters an entity-kind arg:**

1. **In-context** - arg is already in scope: binds once, emits once at that scope.
2. **Schema DAG descendant** - arg is a child entity (e.g. `{ user }` in a host scope):
   fans out once per matching descendant, emits per-item at the parent scope.
3. **Neither** - silently skips. No warning by design (fan-out and misplacement are
   indistinguishable without whole-fleet context).

**Context injection inside class modules** (different from aspect-level parametric):

```nix
den.aspects.laptop = {
  # host, config, pkgs all available in the same function
  nixos = { host, config, pkgs, ... }: {
    networking.hostName = host.hostName;
    environment.systemPackages = [ pkgs.git ];
  };
};
```

---

## Schema and Hosts

```nix
# Declare a host (den auto-creates den.aspects.pmb for you)
den.hosts.aarch64-darwin.pmb.users.alice = {};

# User options: name, userName, classes, aspect, resolved
den.hosts.aarch64-darwin.pmb.users.alice.classes = [ "homeManager" ];

# Standalone home-manager configs (no host)
den.homes.x86_64-linux.tux = {};              # -> homeConfigurations.tux
den.homes.x86_64-linux."tux@igloo" = {};      # host-associated standalone HM
```

**Auto-created aspects**: Den creates an empty aspect for every declared host and user with the
right class keys pre-populated. You fill them in your aspect file.

**`den.default`** - global settings applied to all hosts, users, and homes:

```nix
den.default = {
  nixos.system.stateVersion = "25.11";
  homeManager.home.stateVersion = "25.11";
  includes = [
    den.batteries.define-user
    den.batteries.hostname
    den.batteries.inputs'
  ];
};
```

**`den.schema`** - shared metadata distinct from configuration:

```nix
den.schema.host.options.vpn-group = lib.mkOption { ... };  # freeform extends host data
den.schema.conf  # applied to host, user, and home
den.schema.host  # host-specific base
den.schema.user  # user-specific base
den.schema.home  # home-specific base
```

---

## Resolution Pipeline

```text
den.hosts entry
  -> host scope {host}
    -> host-to-users policy
      -> user scope {host, user}
        -> home-env battery policy (if homeManager in user.classes)
          -> hm-user scope -> home-manager.users.<name>
  -> den.homes entry
    -> home scope {home} (no host in context)
      -> homeConfigurations.<name>
```

Detailed steps:

1. **Host resolution** - each `den.hosts.<system>.<name>` creates a host scope;
   `den.schema.host.includes` binds owned configs.
2. **Fan-out to users** - `host-to-users` policy creates `{host, user}` pair per `host.users` entry.
3. **Battery policies** - home-env batteries forward users into `home-manager.users.<name>`,
   `hjem.users.<name>`, etc. Each battery's OS module is imported once (keyed) even across many
   users.
4. **Deduplication** - seen-set keyed by `"${scope}/${identityKey}"`. First include in a scope gets
   the full resolution. Same aspect in different scopes each gets their own copy.
5. **Output assembly** - flake policies produce `nixosConfigurations`, `darwinConfigurations`,
   `homeConfigurations` by calling `nixpkgs.lib.nixosSystem` etc. per entity.

---

## Batteries Reference

Batteries are reusable aspect providers under `den.batteries` (aliases: `den.provides`, `den._`).

### Opt-in batteries

| Battery | What it does |
|---------|-------------|
| `define-user` | Creates `users.users.<name>` with `isNormalUser`, home dir; sets HM `home.username` |
| `hostname` | Sets system hostname from `den.hosts.<name>.hostName` |
| `primary-user` | Adds `wheel`/`networkmanager` (NixOS), sets `system.primaryUser` (Darwin), `defaultUser` (WSL) |
| `user-shell "fish"` | Sets login shell at OS and HM levels; enables `programs.fish.enable` |
| `mutual-provider` | Bidirectional host-user config influence via `provides.<name>` |
| `host-aspects` | Projects user-relevant classes from the host's aspect tree onto users |
| `tty-autologin "alice"` | TTY1 auto-login on NixOS via systemd getty override |
| `vm-autologin "alice"` | Same but for NixOS VMs |
| `unfree [ "steam" ]` | Allows specific unfree packages via `allowUnfreePredicate` |
| `insecure [ "openssl-1.1.1w" ]` | Allows specific insecure packages |
| `inputs'` | System-qualified `inputs'` as module arg (requires flake-parts) |
| `self'` | System-qualified `self'` as module arg (requires flake-parts) |
| `import-tree ./dir` | Recursively imports `.nix` files; auto-detects class from `_nixos/`, `_darwin/`, `_homeManager/` dirs |
| `forward { ... }` | Generic class forwarding primitive (see Custom Classes) |

### Auto-activated batteries

| Battery | When |
|---------|------|
| `os-class` | Always - provides `os` class that forwards into both `nixos` and `darwin` |
| `os-user` | Always for user entities - provides `user` class forwarded into `users.users.<name>` |
| `home-manager` | When users have `homeManager` in `classes` (requires `inputs.home-manager`) |
| `hjem` | When users have `hjem` in `classes` (requires `inputs.hjem`) |
| `maid` | When users have `maid` in `classes`, NixOS only (requires `inputs.nix-maid`) |
| `wsl` | When `host.wsl.enable = true` (requires `inputs.nixos-wsl`) |

### Applying batteries

```nix
# Global - all entities
den.default.includes = [ den.batteries.define-user den.batteries.hostname ];

# Per-aspect
den.aspects.alice.includes = [
  den.batteries.primary-user
  (den.batteries.user-shell "fish")
  (den.batteries.unfree [ "vscode" ])
];

# Per entity kind
den.schema.user.includes = [ den.batteries.define-user ];

# Composed with inline config
den.aspects.my-admin = {
  includes = [
    den.batteries.primary-user
    (den.batteries.user-shell "fish")
    { nixos.security.sudo.wheelNeedsPassword = false; }
  ];
};
```

---

## Angle Brackets Syntax

Setup (in a module that sets `_module.args`):

```nix
{ den, ... }: {
  _module.args.__findFile = den.lib.__findFile;
}
```

Resolution order:

1. `<den.x.y>` -> `config.den.x.y`
2. `<aspect>` -> `config.den.aspects.aspect`
3. `<aspect/sub>` -> `config.den.aspects.aspect.provides.sub` (or `._.sub`)
4. `<namespace>` -> `config.den.ful.namespace`

```nix
# These are equivalent:
includes = [ den.aspects.tools.editors ];
includes = [ <dots/tools/editors> ];  # using angle brackets (repo uses "dots" namespace)
```

---

## Namespaces

Create a scoped aspect library under `den.ful.<name>`:

```nix
{ inputs, ... }: {
  imports = [ (inputs.den.namespace "dots" false) ];   # local only
  imports = [ (inputs.den.namespace "eg" true) ];      # local + exported as flake.denful.eg
}
```

This generates: `den.ful.eg`, module arg `eg`, and optionally `flake.denful.eg`.

**This repo uses the `dots` namespace** - aspects are at `den.ful.dots.*` and accessed
via `<dots/name>` angle brackets.

Merge from upstream flakes:

```nix
imports = [ (inputs.den.namespace "shared" [ inputs.team-config ]) ];
# include true in the list to also export:
imports = [ (inputs.den.namespace "shared" [ inputs.team-config true ]) ];
```

---

## Custom Nix Classes

Custom classes forward their contents into a target submodule path on another class. This is how
`homeManager`, `user`, `hjem`, and `maid` are implemented in Den itself.

```nix
# The built-in user class example - instead of:
den.aspects.alice.nixos.users.users.alice.extraGroups = [ "wheel" ];
# You write:
den.aspects.alice.user.extraGroups = [ "wheel" ];
```

**`den.batteries.forward` parameters:**

| Parameter | Purpose |
|-----------|---------|
| `each = items` | Items to iterate over (users, `[ true ]` for singleton, etc.) |
| `fromClass = item: class` | Custom class name to read from |
| `intoClass = item: class` | Target class to write into |
| `intoPath = item: path` | Target attribute path in target class |
| `fromAspect = item: aspect` | Aspect to read the custom class from |
| `guard = args: bool` | Only forward when predicate returns true |
| `adaptArgs = args: attrs` | Transform module arguments before forwarding |
| `adapterModule = deferredModule` | Custom module type for the forwarded submodule |

**Example - container class:**

```nix
{ den, lib, ... }: {
  den.schema.user.includes = [
    ({ host, user }:
      den.batteries.forward {
        each = lib.singleton user;
        fromClass = _: "container";
        intoClass = _: host.class;
        intoPath  = _: [ "virtualisation" "oci-containers" "containers" user.userName ];
        fromAspect = _: den.aspects.${user.aspect};
      })
  ];
}
# Now any user aspect can use:
den.aspects.alice.container = { image = "nginx:latest"; ports = [ "8080:80" ]; };
```

**Splitting custom class config across files (the nixvim pattern in this repo):**

Files that set `dots.<aspect>.<customClass>.*` are valid flake-parts modules - import-tree
loads them automatically without `_` prefixes:

```nix
# modules/aspects/nixvim/which-key.nix
{ dots, ... }: {
  dots.editor.nixvim.plugins.which-key = {
    enable = true;
    settings.preset = "helix";
  };
}
```

Files that write raw class options (e.g. `{ plugins.foo.enable = true; }`) are NOT valid
flake-parts modules and must be under `_`-prefixed dirs or inlined.

---

## This Repo's Structure

```text
modules/
  den.nix                       - flake module import, den.hosts declaration, schema defaults
  defaults.nix                  - den.default global settings, batteries, formatters
  namespace.nix                 - registers the `dots` namespace
  hosts/
    pmb.nix                     - host aspect (den.aspects.pmb), includes <dots/bundle/platform>
  users/
    trash-panda-v91-beta.nix    - user aspect, list of capability bundles
  aspects/
    categories.nix              - root aspects (tool, bundle, platform, rice)
    platform/<name>.nix         - system-level (nix daemon, darwin defaults, homebrew, overlays)
    tool/<name>.nix             - one program per file (leaf)
    tool/<name>/default.nix     - one program with companion files (e.g. tool/git/, tool/ai/)
    tool/<X>/nixvim/<plugin>.nix - editor plugin that extends tool X (co-located with tool)
    tool/nixvim/<plugin>.nix    - vim-internal plugins (lsp, completion, mini-*, ui, etc.)
    bundle/<name>.nix           - composite capability (mostly `includes`)
    rice/<theme>.nix            - cross-cutting theme
```

**Namespace**: `dots` (registered in `modules/namespace.nix`, accessed via `<dots/...>` angle
brackets)

**Host**: `pmb` (aarch64-darwin, single user `trash-panda-v91-beta`)

**Aspect naming**: every aspect is declared at `dots.<category>._.<name>` - the `._.` makes it
a provides of the category root aspect (defined in `categories.nix`), which lets angle brackets
like `<dots/tool/git>` resolve to `den.ful.dots.tool.provides.git`.

**Tool-vs-bundle discriminator**: "Would I ever want to enable a subset of this?" If no, it's a
tool (e.g. `git + delta + gh + lazygit` are one tool because you never enable a subset). If yes,
split into tools and bundle them (`dev = terminal + nvim + git + ai` because each is a separate
concern combined for the coding workflow).

**Key patterns in use:**

- `<den/mutual-provider>`, `<den/hostname>`, `<den/define-user>` in `den.default.includes`
- `provides.<user-name>` on the host aspect for host-specific user overrides (routed via
  mutual-provider)
- **Editor integration co-located with the tool**: a nixvim plugin file that extends git lives
  at `tool/git/nixvim/<plugin>.nix` and attaches to `dots.tool._.git._.<plugin>`. Only
  vim-internal plugins (lsp, completion, ui, file pickers, etc.) live under `tool/nixvim/`.
- **New `.nix` files must be `git add`ed** before `nix build` sees them (the flake's source is
  the git tree, not the working directory)

---

## Aspect Fixed-Point and Meta

Aspects are fixed-point - they can reference themselves via `config`:

```nix
den.aspects.igloo =
  { config, ... }:   # config = the igloo aspect itself
  {
    meta.default-key = "Hello World!";
    homeManager.programs.gpg.settings.default-key = config.meta.default-key;
  };
```

Default meta attributes: `aspect.name`, `aspect.meta.loc`, `aspect.meta.name`,
`aspect.meta.file`, `aspect.meta.self`.

Custom submodule on an aspect:

```nix
den.aspects.tux =
  { config, ... }:   # function-args style required so `imports` is not an aspect class
  {
    imports = [{
      options.default-key = lib.mkOption { type = lib.types.str; };
    }];
    default-key = "Hello World!";
  };
```

---

## Debugging

```bash
nix repl :lf .                    # explore nixosConfigurations, den.*
```

Expose den for inspection:

```nix
flake.den = den;    # then: den.aspects.pmb, den.hosts, den.ctx in repl
```

Common issues:

| Symptom | Cause | Fix |
|---------|-------|-----|
| Duplicate option values | Parametric `{ user }` fn in `den.default.includes` runs once per user | Use `den.lib.perHost` to restrict to host context |
| Missing attributes | Context key not in scope | Trace context; check the scope where the aspect is included |
| Wrong class | `host.class` mismatch | Verify system → `"darwin"` not `"nixos"` on macOS |
| Module not found | File not under `modules/` or in `_`-prefixed dir | Move file or remove `_` prefix |
| Aspect silently skipped | Parametric arg not in context and not a descendant | Trace inclusion scope |

Trace aspect resolution: `den.lib.aspects.resolve "nixos" den.aspects.pmb`

---

## `den.lib` Reference

| Function | Purpose |
|----------|---------|
| `aspects.resolve class aspect` | Resolve an aspect for a class; returns deferred module |
| `parametric` / `parametric.atLeast` / `parametric.exactly` | Wrap aspects with context filtering (mostly replaced by bare functions) |
| `parametric.fixedTo attrs` | Fix aspect to given attrs regardless of context |
| `parametric.expands attrs` | Extend received context before dispatch |
| `canTake.atLeast` / `canTake.exactly` | Check if function accepts given params |
| `take.atLeast` / `take.exactly` | Conditionally apply functions based on params |
| `perHost` / `perUser` / `perHome` | Shorthand context-specific aspects |
| `statics` / `owned` / `isFn` / `isStatic` | Extract and inspect aspect components |
| `__findFile` | Angle-brackets path resolver |
| `fx.*` | Algebraic effects API (`fx.pure`, `fx.send`, `fx.bind`, `fx.bind.fn`, `fx.handle`) |

---

## Templates

```bash
nix flake init -t github:vic/den#<template>
```

| Template | Description |
|----------|-------------|
| `minimal` | Smallest possible - flakes only, no HM |
| `default` | Recommended - flake-parts, HM, VM testing |
| `example` | Feature showcase - namespaces, angle-brackets, mutual providers, CI |
| `noflake` | Without flakes - npins + nix-maid |
| `nvf-standalone` | NVF Neovim config, no NixOS - custom forwarding class |
| `microvm` | MicroVM host + guest - custom pipeline, schema extensions |
| `ci` / `bogus` | Test suite / bug reproduction (best learning resource) |

```bash
nix repl "github:denful/den?dir=templates/ci"   # interactive learning REPL
```

---

## Migration from Legacy Configs

1. **Add Den as input** and import `inputs.den.flakeModule`
2. **Declare hosts** in `den.hosts`
3. **Import existing modules** via `den.batteries.import-tree` (auto-detects class from dir names)
4. **Extract aspects** - convert features into den aspects incrementally
5. **Remove legacy** - clean up original files as aspects replace them

Legacy modules and Den aspects coexist without conflicts.

---

## Ecosystem

- [dendrix](https://dendrix.oeiuwq.com) - community aspect index
- [import-tree](https://github.com/vic/import-tree) - recursive `.nix` file importer
- [flake-aspects](https://github.com/vic/flake-aspects) - dependency-free parametric aspect library
- [denful](https://github.com/vic/denful) - lazyvim-style config distribution (WIP)
- [flake-file](https://github.com/vic/flake-file) - declarative `flake.nix` generation
- [nix-effects](https://github.com/denful/nix-effects) - algebraic effects library Den runs on

Real-world repos: `vic/vix`, `tangled.org/quasigod.xyz/nixconfig`, `codeberg.org/Adda/nixos-config`
