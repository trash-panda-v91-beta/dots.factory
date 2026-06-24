---
description: Add a package, new software, or new capability to dots.factory. Use when installing a CLI tool, GUI app, new program, creating a new aspect file, bundling tools into a workflow, adding a nixvim plugin, or wiring up home-manager packages in this repo.
---

# Add Aspect - dots.factory

The repo follows a strict taxonomy. Every aspect file lands in exactly one of these buckets.

## Decision tree

```text
Is it a single program or tightly-coupled program family?
    single file is enough          -> tool/<name>.nix
    has companion files            -> tool/<name>/default.nix + companions
Does it configure the system?      -> platform/<name>.nix
Does it compose multiple tools?    -> bundle/<name>.nix       (mostly includes; user enables these)
Is it a theme?                     -> rice/<theme>.nix
Is it a nixvim plugin?
    extends another tool (X)       -> tool/<X>/nixvim.nix or tool/<X>/nixvim/<plugin>.nix
    vim-internal (lsp, ui, ...)    -> tool/nixvim/<plugin>.nix
Just a CLI tool that fits a tool?  -> that tool's `home.packages` (no new file)
```

**The discriminator question**: "Would I ever want to enable a subset of this thing?"
No -> tool. Yes -> split into tools and bundle them.

The user file is a manifest of bundles. If the new tool belongs in an existing capability,
add it to that bundle's `includes`. If it's a new capability, create a bundle.

---

## Adding a CLI tool to an existing aspect

The fastest path. Pick the right `tool/` file and add to `home.packages`:

| Tool kind | File |
|---|---|
| Dev workflow (direnv, mise, docker-like) | `modules/aspects/tool/dev-tools.nix` |
| Language runtime (python, node, rust, go) | `modules/aspects/tool/runtimes.nix` |
| Git workflow companion (gh, lazygit, delta) | `modules/aspects/tool/git/default.nix` |
| Terminal / shell | `modules/aspects/tool/terminal.nix` |
| Kubernetes tool | `modules/aspects/tool/k8s.nix` |
| AI assistant | `modules/aspects/tool/ai/default.nix` |
| Security / credentials | `modules/aspects/tool/security.nix` |
| Secrets pipeline (sops, age) | `modules/aspects/tool/sops.nix` |

```nix
homeManager = { pkgs, ... }: {
  home.packages = with pkgs; [ existing new-pkg ];
};
```

A Homebrew GUI app (macOS code-signing or MAS):

```nix
darwin.homebrew.casks = [ "<cask-name>" ];
darwin.homebrew.masApps."<App Name>" = <appstore-id>;
```

---

## Creating a new tool aspect

Use when the program needs its own config (options, daemon settings, themes, multi-class) and
doesn't fit any existing tool.

**File**: `modules/aspects/tool/<name>.nix` (or `tool/<name>/default.nix` if you expect companions)

**Template:**

```nix
{ ... }:
{
  dots.tool._.<name> = {
    description = "<one-line description>";

    # darwin = { pkgs, ... }: {
    #   environment.systemPackages = [ pkgs.<name> ];
    #   homebrew.casks = [ "<cask>" ];
    # };

    homeManager = { pkgs, ... }: {
      programs.<name>.enable = true;
      # home.packages = [ pkgs.<name> ];
    };
  };
}
```

**Critical**: declare via `dots.tool._.<name>` (the `._.` is the provides marker). Without it,
angle-bracket includes like `<dots/tool/<name>>` cannot resolve.

**Wire it in** by adding `<dots/tool/<name>>` to an existing bundle's `includes`, or to the user's
`includes` directly if it's truly standalone. Then `git add` the file.

---

## Adding a nixvim plugin

Two cases. The file location follows what the plugin *extends*.

### Case A - extends another tool (most common)

Examples: `octo.nvim` extends git, `obsidian.nvim` extends obsidian, `copilot.lua` extends ai.

**File**: `modules/aspects/tool/<tool>/nixvim/<plugin>.nix` (or `tool/<tool>/nixvim.nix` for a
single-plugin tool).

```nix
{ dots, ... }:
{
  dots.tool._.<tool>.includes = [ dots.tool._.<tool>._.<plugin> ];
  dots.tool._.<tool>._.<plugin>.homeManager = { ... }: {
    programs.nixvim.plugins.<plugin> = {
      enable = true;
      settings = { /* ... */ };
    };
  };
}
```

The plugin activates *when its host tool is enabled*. Delete the tool folder and the plugin
disappears with it.

### Case B - vim-internal (lsp, completion, ui, file pickers, etc.)

**File**: `modules/aspects/tool/nixvim/<plugin>.nix`

```nix
{ dots, ... }:
{
  dots.tool._.nixvim.includes = [ dots.tool._.nixvim._.<plugin> ];
  dots.tool._.nixvim._.<plugin>.homeManager = { ... }: { /* ... */ };
}
```

---

## Creating a new bundle

Use when introducing a new capability that composes several tools (e.g. "data-science" =
runtimes + jupyter + duckdb tooling). Bundles are what the user enables.

**File**: `modules/aspects/bundle/<name>.nix`

```nix
{ __findFile, ... }:
{
  dots.bundle._.<name> = {
    description = "<capability description>";
    includes = [
      <dots/tool/<a>>
      <dots/tool/<b>>
    ];
    # optional: extra config that ties the tools together
    # homeManager = { ... }: { ... };
  };
}
```

**Wire it in** by adding `<dots/bundle/<name>>` to `modules/users/trash-panda-v91-beta.nix`.

---

## Creating a new platform aspect

Rare. Only for system-level concerns (nix daemon, darwin defaults, homebrew, overlays).

**File**: `modules/aspects/platform/<name>.nix`

```nix
{ ... }:
{
  dots.platform._.<name> = {
    description = "<system-level description>";
    darwin = { ... }: { ... };
    # or nixos = { ... }: { ... };
  };
}
```

Wire into `modules/aspects/bundle/platform.nix`.

---

## Promoting a tool from leaf to folder

When a tool grows companion files (typically the first nixvim plugin), promote:

```bash
git mv modules/aspects/tool/<name>.nix modules/aspects/tool/<name>/default.nix
# then add the companion files alongside default.nix
```

The aspect path (`dots.tool._.<name>`) is unchanged - only the file location moves.

---

## Verify

```bash
git add modules/...                              # required - flake source is git-tracked
nix build .#darwinConfigurations.pmb.system --dry-run
nix build .#checks.aarch64-darwin.pmb-config     # runs the assertions in modules/checks.nix
```

If you broke a path, the build trace points at the offending file.
