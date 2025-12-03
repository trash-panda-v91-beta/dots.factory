# Rust Development Template

This template provides a complete Rust development environment using Nix flakes and rust-overlay.

## Quick Start

### Create a new Rust project:

```bash
# Option 1: Using cargo init (requires entering dev shell first)
mkdir my-rust-project && cd my-rust-project
nix flake init --template github:trash-panda-v91-beta/dots.factory#rust
git init
direnv allow  # Enable automatic environment activation
cargo init .  # Initialize Cargo project

# Option 2: With cargo new (from outside the project)
cargo new my-rust-project
cd my-rust-project
nix flake init --template github:trash-panda-v91-beta/dots.factory#rust
direnv allow
```

### For an existing Rust project:

```bash
cd my-existing-project
nix flake init --template github:trash-panda-v91-beta/dots.factory#rust
direnv allow
```

## What's Included

The template creates three files:

1. **flake.nix** - Nix flake with Rust toolchain
2. **.envrc** - direnv configuration for automatic activation
3. **.gitignore** - Rust-specific gitignore patterns

## Available Dev Shells

### Default (Stable Rust)
```bash
nix develop
# or just cd into the directory with direnv enabled
```

Includes:
- Latest stable Rust (rustc, cargo, rustfmt, clippy)
- rust-analyzer

### Specific Rust Version
```bash
nix develop .#rust-1-91
```

### Nightly Rust
```bash
nix develop .#nightly
```

## Usage Examples

### With direnv (Recommended)
```bash
cd my-rust-project  # Tools automatically available
cargo build
cargo test
```

### Without direnv
```bash
cd my-rust-project
nix develop
cargo build
```

### One-off Commands
```bash
nix develop --command cargo build --release
```

## Customization

Edit the `flake.nix` to add more tools:

```nix
packages = with pkgs; [
  rust-bin.stable.latest.default
  rust-analyzer
  
  # Add these:
  cargo-watch      # Auto-rebuild on changes
  cargo-edit       # cargo add, cargo rm, cargo upgrade
  cargo-audit      # Security scanner
  cargo-bloat      # Binary size analysis
];
```

## Local Usage

If you're working from the dots.factory repository:

```bash
# Using local template
nix flake init --template ~/repos/personal/dots.factory#rust

# Using from GitHub
nix flake init --template github:trash-panda-v91-beta/dots.factory#rust
```

## Why rust-overlay?

The [rust-overlay](https://github.com/oxalica/rust-overlay) provides:
- All Rust versions (stable, beta, nightly)
- Faster updates than nixpkgs
- Per-channel, per-version, or per-date versions
- Rust targets and components

## Troubleshooting

### "cargo: command not found" outside dev shell
This is expected! Rust is only available inside the project directory (with direnv) or inside `nix develop`.

### direnv not working
```bash
# Check if direnv is enabled
direnv status

# Re-allow the directory
direnv allow
```

### Want global cargo just for initialization?
```bash
# Use nix shell temporarily
nix shell nixpkgs#cargo nixpkgs#rustc --command cargo new myproject
```
