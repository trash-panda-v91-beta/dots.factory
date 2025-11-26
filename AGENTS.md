# Agent Guidelines for dots.factory

This document provides guidelines for AI agents and developers working with this NixOS/Darwin configuration repository built with Denix.

## About This Repository

This is a scalable NixOS/Darwin configuration using [Denix](https://yunfachi.github.io/denix/), a library for creating modular system configurations. The repository supports multiple hosts (machines), rices (appearance themes), and features organized in a clean, maintainable structure.

## Understanding Denix

### What is Denix?

Denix is a Nix library that provides functions to transform configuration data into well-structured NixOS, Home Manager, and Nix-Darwin modules. It eliminates boilerplate code and makes configurations more readable and maintainable.

### Core Concepts

#### 1. Modules (`modules/`)
Denix modules wrap traditional Nix modules with the `delib.module` function, providing:
- Simplified option declarations using `delib` options (e.g., `boolOption`, `strOption`, `listOfOption`)
- Built-in enable/disable logic with `ifEnabled`, `ifDisabled`, and `always` blocks
- Separated configurations for different systems: `nixos.*`, `home.*`, `darwin.*`, and `myconfig.*`

**Module Structure:**
```nix
{delib, ...}:
delib.module {
  name = "programs.example";  # Should match the option path
  
  options = {cfg, ...}: {
    # Options defined here become available at myconfig.programs.example.*
  };
  
  # Runs only if cfg.enable exists and is true
  home.ifEnabled = {cfg, ...}: {
    programs.example.enable = true;
  };
  
  # Runs only if cfg.enable exists and is false
  home.ifDisabled = {cfg, ...}: {};
  
  # Always runs regardless of enable state
  home.always = {cfg, ...}: {};
}
```

**Key Points:**
- `name`: Should match the option path (e.g., `"programs.direnv"`)
- `cfg`: Refers to the current module's config values at `myconfig.${name}`
- `myconfig.*`: Sets custom options under your config namespace
- `nixos.*`: Only applies when building NixOS systems
- `home.*`: Applies to Home Manager (nested under home-manager.users.${user} in NixOS/Darwin)
- `darwin.*`: Only applies when building nix-darwin systems
- Modules in `/modules/*` are automatically discovered

#### 2. Hosts (`hosts/`)
Hosts represent individual machines and use the `delib.host` function. They separate:
- **Shared configuration**: Applied to all hosts (e.g., SSH keys, common settings)
- **Host-specific configuration**: Unique to each machine

**Host Structure:**
```nix
{delib, ...}:
delib.host {
  name = "hostname";           # Unique identifier for this host
  rice = "theme-name";         # Which rice (theme) to apply
  type = "desktop";            # Or "server", etc.
  features = [];               # List of features to enable
  homeManagerUser = "username"; # Override default Home Manager user
  
  # Configuration specific to this host
  myconfig = {myconfig, ...}: {
    programs.example.enable = true;
  };
  
  # Shared configuration applied to all hosts
  shared.myconfig = {myconfig, ...}: {
    services.openssh.authorizedKeys = ["ssh-ed25519 ..."];
  };
}
```

**Directory Structure:**
- `hosts/darwin/`: Darwin (macOS) hosts
- `hosts/nixos/`: NixOS hosts
- Each host should have its own subdirectory with `default.nix`

#### 3. Rices (`rices/`)
Rices are configuration presets (especially for appearance) that can be applied to any host. They use the `delib.rice` function.

**Rice Structure:**
```nix
{delib, ...}:
delib.rice {
  name = "theme-name";
  inherits = [];              # Inherit from other rices
  inheritanceOnly = false;    # If true, only used for inheritance
  
  # Configuration applied when this rice is active
  home = {
    stylix = {
      polarity = "dark";
      # ... theme settings
    };
  };
}
```

**Key Points:**
- Rices enable theming and appearance customization across hosts
- Can inherit configurations from other rices using `inherits`
- Use `inheritanceOnly = true` for base rices not meant to be used directly
- Applied based on `rice = "name"` in host configuration

#### 4. Overlays (`overlays/`)
Overlays modify or add packages to nixpkgs. This repository uses denix's auto-discovery for overlays.

**Overlay Structure:**
```nix
final: prev: {
  packageName = prev.packageName.overrideAttrs (oldAttrs: {
    # modifications
  });
}
```

## Repository Structure

```
dots.factory/
├── modules/
│   ├── config/        # System-wide configurations (nix, sops, users)
│   ├── features/      # Feature flags (kubernetes, python)
│   ├── programs/      # Program-specific modules
│   └── services/      # Service configurations
├── hosts/
│   ├── darwin/        # macOS hosts
│   └── nixos/         # NixOS hosts
├── rices/
│   └── cyberdream-dark/  # Theme configurations
├── overlays/          # Package overlays
├── packages/          # Custom packages
├── extra/             # Additional files
└── flake.nix          # Main flake configuration
```

## Common Commands

This repository uses [just](https://github.com/casey/just) for common tasks. Run `just` to see all available commands.

### Building and Deployment
- **Build system**: `just build [hostname]` - Build darwin configuration (defaults to current hostname)
- **Check flake**: `just check` - Validate flake configuration and check for errors
- **Show diff**: `just diff [hostname]` - Show diff between current and new configuration
- **Build and activate**: `just sync [hostname]` - Build and activate darwin configuration
- **Update dependencies**: `just update [input]` - Update all flake inputs (or specific input)
- **Update and sync**: `just upgrade [hostname]` - Update flake inputs and sync configuration
- **Format code**: `nix fmt` or `nixfmt-rfc-style *.nix`

### Maintenance
- **Garbage collection**: `just clean [keep]` - Run garbage collection keeping N generations (default: 3)
- **Bootstrap system**: `just bootstrap [username]` - Setup SSH keys and sync configuration

### Development
- **List commands**: `just` or `just --list`
- **Show flake outputs**: `nix flake show`

### Direct Nix Commands (if needed)
- **Build specific host**: `nix build .#darwinConfigurations.cmb.system`
- **Test configuration**: `nix build --dry-run`
- **Enter dev shell**: `nix develop`

## Code Style and Conventions

### Nix
- **Indentation**: 2 spaces (enforced by nixfmt-rfc-style)
- **Formatter**: `nixfmt-rfc-style` (available as `nix fmt`)
- **Naming**: Use descriptive names matching their purpose
  - Modules: Match option path (e.g., `programs.direnv`)
  - Hosts: Use actual hostname
  - Rices: Use descriptive theme names
- **Module pattern**: Always use `delib.module` with `name` and appropriate option blocks

### Other Languages
- **TypeScript/JavaScript**: Use `prettierd` or `biome` formatters, camelCase for variables
- **Python**: Use `ruff_format`, `ruff_fix`, and `ruff_organize_imports`, snake_case for variables
- **Lua**: Use `stylua` formatter
- **YAML**: Follow `.yamlfmt.yaml` and `.yamllint.yaml` configurations

### Git
- Uses histogram diff algorithm
- Follow conventional commit messages (see existing commits)
- Ignore: `.DS_Store`, `.venv`, `Thumbs.db`, `.direnv`, `.envrc`

## Adding New Components

### Adding a New Program Module

1. **Research the program**: Check if Home Manager already has a module
   - NixOS options: https://search.nixos.org/options
   - Home Manager options: https://home-manager-options.extranix.com/
   - Nix-Darwin options: https://nix-darwin.github.io/nix-darwin/manual/

2. **Get upstream source** (for Home Manager modules):
   ```bash
   curl -s "https://raw.githubusercontent.com/nix-community/home-manager/master/modules/programs/<program-name>.nix"
   ```

3. **Create module file**: `modules/programs/<program-name>/default.nix`
   ```nix
   {delib, host, ...}:
   delib.module {
     name = "programs.<program-name>";
     
     options = delib.singleEnableOption host.codingFeatured;
     
     home.ifEnabled = {
       programs.<program-name> = {
         enable = true;
         # Enable shell integrations
         enableNushellIntegration = true;
         # ... other options
       };
     };
   }
   ```

4. **Format the file**: `nix fmt modules/programs/<program-name>/default.nix`

5. **Validate**: `just check`

6. **Module is auto-discovered**: Denix automatically imports all modules in `/modules/*`

### Adding a New Host

1. **Choose platform**: Create in `hosts/darwin/` or `hosts/nixos/`

2. **Create directory**: `mkdir -p hosts/darwin/<hostname>`

3. **Create host file**: `hosts/darwin/<hostname>/default.nix`
   ```nix
   {delib, ...}:
   delib.host {
     name = "<hostname>";
     
     features = ["coding" "python"];
     rice = "cyberdream-dark";
     type = "desktop";
     
     homeManagerUser = "username";  # Optional override
     
     myconfig = {myconfig, ...}: {
       user.name = "username";
       programs.git.userEmail = "user@example.com";
     };
   }
   ```

4. **Create hardware file** (if needed): `hosts/darwin/<hostname>/hardware.nix`

5. **Format and validate**:
   ```bash
   nix fmt hosts/darwin/<hostname>/
   just check
   ```

6. **Build**: `just build <hostname>`

### Adding a New Rice

1. **Create directory**: `mkdir -p rices/<rice-name>`

2. **Create rice file**: `rices/<rice-name>/default.nix`
   ```nix
   {delib, ...}:
   delib.rice {
     name = "<rice-name>";
     inherits = [];  # Optional: inherit from other rices
     
     home = {
       # Home Manager configuration
     };
     
     nixos = {
       # NixOS-specific configuration
     };
     
     darwin = {
       # Darwin-specific configuration
     };
   }
   ```

3. **Add rice-specific overrides** (optional):
   - `rices/<rice-name>/programs/`: Program-specific rice settings
   - Example: `rices/cyberdream-dark/programs/k9s/skin.yaml`

4. **Format and validate**:
   ```bash
   nix fmt rices/<rice-name>/
   just check
   ```

### Adding a Custom Package

1. **Create package directory**: `mkdir -p packages/<package-name>`

2. **Create package file**: `packages/<package-name>/default.nix`
   ```nix
   {pkgs, ...}:
   pkgs.stdenv.mkDerivation {
     pname = "<package-name>";
     version = "0.1.0";
     
     src = ./src;
     
     installPhase = ''
       mkdir -p $out/bin
       cp <script> $out/bin/
     '';
   }
   ```

3. **Format and validate**:
   ```bash
   nix fmt packages/<package-name>/
   just check
   ```

### Adding an Overlay

1. **Create overlay file**: `overlays/<overlay-name>.nix`
   ```nix
   final: prev: {
     packageName = prev.packageName.overrideAttrs (oldAttrs: {
       # modifications
     });
   }
   ```

2. **For package-specific overlays**: `overlays/<package-name>/default.nix`

3. **Format and validate**:
   ```bash
   nix fmt overlays/
   just check
   ```

## Denix-Specific Patterns

### Module Options
Use Denix option helpers instead of verbose `lib.mkOption`:
```nix
options = with delib; {
  enable = boolOption true;              # Boolean with default
  hostnames = listOfOption str [];       # List of strings
  package = packageOption pkgs.example;  # Package option
  config = strOption "default";          # String option
};
```

### Conditional Logic
Use Denix's built-in conditional blocks:
```nix
# Only when module is enabled
home.ifEnabled = {...}: {
  programs.example.enable = true;
};

# Only when module is disabled
home.ifDisabled = {...}: {
  programs.alternative.enable = true;
};

# Always runs
home.always = {...}: {
  home.packages = with pkgs; [always-installed];
};
```

### Accessing Config Values
```nix
delib.module {
  name = "programs.example";
  
  home.ifEnabled = {cfg, parent, myconfig, ...}: {
    # cfg = myconfig.programs.example
    # parent = myconfig.programs
    # myconfig = myconfig (root)
    programs.example.path = cfg.customPath;
  };
}
```

## Features System

This repository uses a feature flag system configured in `flake.nix`:
```nix
hosts.features = {
  features = [
    "coding"
    "githubCopilot"
    "kubernetes"
    "python"
  ];
};
```

Modules can check feature flags using `host.codingFeatured`, etc., via `delib.singleEnableOption`.

## Troubleshooting

### Common Issues
1. **Module not found**: Ensure the file is in `/modules/*` and properly formatted
2. **Infinite recursion**: Check for circular dependencies between modules
3. **Option already defined**: Ensure `name` in `delib.module` matches the intended option path
4. **Build fails**: Run `just check` to validate configuration
5. **Private flake input access**: Ensure you have GH_TOKEN configured (see `.justfile` for 1Password integration)

### Validation Workflow
1. Format code: `nix fmt`
2. Check syntax: `just check`
3. Show differences: `just diff`
4. Test build: `just build`
5. Apply changes: `just sync`

## Resources

- **Denix Documentation**: https://yunfachi.github.io/denix/
- **NixOS Options**: https://search.nixos.org/options
- **Home Manager Options**: https://home-manager-options.extranix.com/
- **Nix-Darwin Manual**: https://nix-darwin.github.io/nix-darwin/manual/
- **Nix Language**: https://nixos.org/manual/nix/stable/language/

## GitHub Workflows

This repository includes automated workflows for:
- **Update Flake**: Weekly `nix flake update` via Renovate
- **Validation**: `nix flake check` on PRs
- **Security**: CodeQL analysis
- **Dead Code**: Unused code detection
- **Auto-merge**: Automated PR merging for dependencies

## Best Practices

1. **Module Organization**: Keep modules focused and single-purpose
2. **Documentation**: Add comments for complex configurations
3. **Testing**: Validate changes with `just check` before committing
4. **Formatting**: Always run `nix fmt` before committing
5. **Dependencies**: Pin versions in `flake.lock`, update with `just update`
6. **Secrets**: Use sops-nix for sensitive data (see `modules/config/sops.nix`)
7. **Naming**: Use clear, descriptive names that reflect functionality
8. **Reusability**: Prefer modules over host-specific configuration
9. **Private Repository Access**: The repository uses 1Password for GitHub token management (see `.justfile`)

## Important Notes

- Modules are automatically discovered from `/modules/*`
- Hosts require explicit `myconfig.host` and `myconfig.hosts` options (defined in a module)
- Rices require explicit `myconfig.rice` and `myconfig.rices` options (defined in a module)
- The `homeManagerUser` defaults to "trash-panda-v91-beta" but can be overridden per-host
- Use `delib` option helpers for cleaner code
- Leverage `ifEnabled`/`ifDisabled`/`always` blocks instead of manual `mkIf`
