# Add Aspect — dots.factory

Add a package or new software concern to dots.factory.

## Is it a new concern or just a package?

**Just a package** (fits naturally in an existing aspect) → add to that aspect's `homeManager.home.packages`.

**New concern** (its own config, options, or cask) → create a new aspect file.

---

## Adding a package to an existing aspect

| Package type | Aspect file |
|---|---|
| CLI dev tool | `modules/aspects/dev-tools.nix` |
| Security tool | `modules/aspects/security.nix` |
| Runtime (node, python, go…) | `modules/aspects/runtimes.nix` |
| K8s tool | `modules/aspects/k8s.nix` |
| Terminal tool | `modules/aspects/terminal.nix` |
| AI tool | `modules/aspects/ai.nix` |

```nix
homeManager = { pkgs, ... }: {
  home.packages = with pkgs; [ existing new-pkg ];
};
```

For a Homebrew cask (GUI app with macOS code-signing):
```nix
darwin.homebrew.casks = [ "<cask-name>" ];
```

---

## Creating a new aspect

**Placement** (from CLAUDE.md Aspect Placement Rule):
- Simple single concern → `modules/aspects/<name>.nix`
- Has companion files → `modules/aspects/<name>/default.nix` + siblings
- Composes existing aspects → `modules/aspects/feature-<name>.nix` with `includes`

**Template:**
```nix
# <Description>
{ ... }:
{
  dots.<name> = {
    description = "<description>";

    darwin = { pkgs, ... }: {
      # environment.systemPackages = [ pkgs.<name> ];
      # homebrew.casks = [ "<cask>" ];
    };

    homeManager = { pkgs, ... }: {
      programs.<name>.enable = true;
    };
  };
}
```

**Wire it in** by adding `<dots/<name>>` to `includes` in:
- `modules/hosts/pmb.nix` — system-level for PMB
- `modules/users/trash-panda-v91-beta.nix` — user-level for PMB
- `../dots.corpo/cmb.nix` — CMB (either level)

---

## Verify

```bash
HOST_ALIAS=pmb mise run build
```
