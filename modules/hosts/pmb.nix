# PMB — personal MacBook (aarch64-darwin)
{
  lib,
  __findFile,
  ...
}:
{
  den.aspects.pmb = {
    description = "Personal MacBook — darwin host aspect";

    includes = [
      # System config
      <dots/nix>
      <dots/darwin-system>
      <dots/homebrew>
      <dots/library-linking>
      <dots/overlays>
      <dots/sops>
      # Services
      <dots/keyboard>
      <dots/raycast>
    ];

    darwin = {
      nixpkgs.hostPlatform = "aarch64-darwin";
    };

    provides.trash-panda-v91-beta = {
      homeManager =
        { pkgs, ... }:
        {
          programs.bun.enable = false;

          programs.ssh.matchBlocks."asc.internal" = {
            user = "trash-panda-v91-beta";
            identityFile = "~/.ssh/trash-panda-v91-beta.pub";
            identitiesOnly = true;
            extraOptions.IdentityAgent = "'~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'";
          };

          programs.mcp.servers = {
            hass = {
              disabled = true;
              command = lib.getExe pkgs.ha-mcp;
              env = {
                HOMEASSISTANT_URL = "https://hass.nebular-grid.space";
                HOMEASSISTANT_TOKEN = "{env:HASS_TOKEN}";
              };
            };
            perplexity = {
              disabled = true;
              command = lib.getExe pkgs.perplexity-mcp;
              env.PERPLEXITY_API_KEY = "{env:PERPLEXITY_API_KEY}";
            };
          };

          programs.obsidian.vaults.mist.target = "vaults/mist";

          programs.nixvim.plugins.obsidian.settings.workspaces = [
            {
              name = "mist";
              path = "~/vaults/mist";
            }
          ];
          programs.nixvim.plugins.obsidian-bases-nvim = {
            enable = true;
            vaults = [
              {
                name = "mist";
                path = "vaults/mist";
              }
            ];
          };

          programs.sesh.settings.session = [
            {
              name = "hack";
              path = "~";
            }
            {
              name = "asc";
              path = "~";
              startup_command = "ssh asc.internal";
            }
            {
              name = "dots";
              path = "~/repos/personal/dots.factory";
              startup_command = "nvim";
            }
            {
              name = "nebular grid";
              path = "~/repos/personal/nebular-grid";
              startup_command = "nvim";
            }
            {
              name = "mist";
              path = "~/vaults/mist";
              startup_command = "nvim";
            }
            {
              name = "psb";
              path = "~/repos/personal/nebular-grid";
              startup_command = "k9s";
            }
          ];
        };
    };
  };
}
