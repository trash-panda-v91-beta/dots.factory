# Agent Guidelines for dots.factory

## Commands
- **Build**: `nix build` or `nix flake build` to build the system
- **Check**: `nix flake check` to validate the flake
- **Format**: `nixfmt-rfc-style *.nix` to format Nix files
- **Update**: `nix flake update` to update dependencies

## Code Style
- **Nix**: 2 space indentation, use `nixfmt-rfc-style` formatter
- **TypeScript**: Use `prettierd` or `biome` formatters
- **Python**: Use `ruff_format`, `ruff_fix`, and `ruff_organize_imports`
- **Lua**: Use `stylua` formatter

## Conventions
- Use camelCase for variable names in TypeScript/JavaScript
- Use snake_case for Python variables and functions
- Follow existing module structure in `/modules/*`
- Nix modules should use `delib.module` pattern with `name` and `options`
- Git commits use the Git histogram diff algorithm
- Avoid using `.DS_Store`, `.venv`, and `Thumbs.db` files

## GitHub Workflows
- **Update Flake**: Create a workflow to run `nix flake update` weekly
- **Validation**: Implement CI workflow to run `nix flake check` after updates
- **Testing**: Build and test updated system configurations
- **PRs**: Automate PR creation with dependency updates

## Error Handling
- Use proper try/catch in JavaScript/TypeScript
- Use option types in Nix where appropriate
- Follow existing error handling patterns in similar files