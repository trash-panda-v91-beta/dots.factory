# Agent Guidelines for dots.factory

NixOS/Darwin configuration using Denix modular system. Supports multiple hosts, rices (themes), and feature flags.

## Essential Commands

**Build/Test**: `just check` (validate), `just build [hostname]` (build), `just diff [hostname]` (preview)
**Deploy**: `just sync [hostname]` (build+activate), `just upgrade [hostname]` (update+sync)
**Maintenance**: `just update [input]` (flake inputs), `nix fmt` (format), `just clean [keep]` (GC)

## Code Style

**Nix**: 2-space indentation, `nixfmt-rfc-style` formatter, use `delib.module`/`delib.host`/`delib.rice` patterns
**Naming**: Modules match option path (`programs.direnv`), hosts use hostname, rices use theme names
**Imports**: Use delib option helpers (`boolOption`, `strOption`) instead of `lib.mkOption`
**Error Handling**: Use `ifEnabled`/`ifDisabled`/`always` blocks, avoid manual `mkIf`

## Key Patterns

```nix
# Module structure
{delib, host, ...}:
delib.module {
  name = "programs.example";
  options = delib.singleEnableOption host.codingFeatured;
  home.ifEnabled = {cfg, ...}: {
    programs.example.enable = true;
  };
}

# Host structure  
{delib, ...}:
delib.host {
  name = "hostname";
  features = ["coding" "python"];
  rice = "cyberdream-dark";
  myconfig = {myconfig, ...}: {
    user.name = "username";
  };
}
```

## Repository Structure

- `modules/`: Auto-discovered modules (config/, features/, programs/, services/)
- `hosts/darwin|nixos/`: Machine-specific configurations  
- `rices/`: Theme presets with `delib.rice`
- `overlays/`: Package modifications (auto-discovered)
- `packages/`: Custom packages

## Critical Notes

- Modules auto-discovered from `/modules/*` - name must match option path
- Hardware files should be plain Nix, not `delib.host`
- Feature flags: `host.codingFeatured`, `host.pythonFeatured`, etc.
- Default user: "trash-panda-v91-beta" (overrideable per-host)
- Private repo access requires GH_TOKEN via 1Password (see `.justfile`)

## Validation Workflow

1. `nix fmt` (format)
2. `just check` (validate)  
3. `just build [hostname]` (test)
4. `just sync [hostname]` (deploy)
