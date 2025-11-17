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

## Adding New Modules

### Home Manager Modules
1. **Find module options**: Check https://home-manager-options.extranix.com/ for available options
2. **Get module source**: View the upstream module at `https://github.com/nix-community/home-manager/blob/master/modules/programs/<module-name>.nix`
3. **Fetch raw source**: Use `curl -s "https://raw.githubusercontent.com/nix-community/home-manager/master/modules/programs/<module-name>.nix"` to see available options
4. **Create module**: Follow the pattern from existing modules like `direnv` or `carapace`:
   - Create directory: `modules/programs/<module-name>/`
   - Create file: `modules/programs/<module-name>/default.nix`
   - Use `delib.module` with `name` and `options`
   - Enable relevant shell integrations (Nushell, Fish, Zsh, etc.)
5. **Format**: Run `nix fmt modules/programs/<module-name>/default.nix`
6. **Validate**: Run `nix flake check` to ensure the module is valid
7. **Auto-discovery**: Modules in `/modules/*` are automatically discovered by denix

## GitHub Workflows
- **Update Flake**: Create a workflow to run `nix flake update` weekly
- **Validation**: Implement CI workflow to run `nix flake check` after updates
- **Testing**: Build and test updated system configurations
- **PRs**: Automate PR creation with dependency updates

## Error Handling
- Use proper try/catch in JavaScript/TypeScript
- Use option types in Nix where appropriate
- Follow existing error handling patterns in similar files