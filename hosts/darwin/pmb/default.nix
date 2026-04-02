{
  delib,
  lib,
  pkgs,
  ...
}:
delib.host {
  name = "pmb";

  features = [
    "coding"
    "githubCopilot"
    "kubernetes"
    "python"
    "rust"
  ];
  rice = "cyberdream-dark";
  type = "desktop";

  myconfig = {
    user = {
      name = "trash-panda-v91-beta";
      ssh.matchBlocks = [
        {
          name = "asc.internal";
          user = "trash-panda-v91-beta";
        }
      ];
    };

    ai.mcp.servers = {
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
        env = {
          PERPLEXITY_API_KEY = "{env:PERPLEXITY_API_KEY}";
        };
      };
    };

    programs = {
      actual.enable = true;
      bun.enable = true;
      obsidian = {
        enable = true;
        vaults.mist = {
          target = "vaults/mist";
          extraCorePlugins = [
            {
              name = "sync";
              settings = {
                deviceName = "pmb";
                syncPluginSettings = true;
              };
            }
          ];
        };
      };
      colima.enable = true;
      git.userEmail = "42897550+trash-panda-v91-beta@users.noreply.github.com";
      opencode.env = {
        ACTUAL_BUDGET_SYNC_ID = "op://NebularGrid/Actual/sync id";
        ACTUAL_PASSWORD = "op://NebularGrid/Actual/password";
        HASS_TOKEN = "op://Private/HASS MCP/password";
        PERPLEXITY_API_KEY = "op://Private/Perplexity API Key/password";
        TAVILY_TOKEN = "op://Private/op4p2ok4buizqra3jssnnoet3u/credential";
      };
      nushell.enable = true;
      nixvim.plugins.obsidian = {
        enable = true;
        workspaces = [
          {
            name = "mist";
            path = "~/vaults/mist";
          }
        ];
      };
      nixvim.plugins.obsidian-bases-nvim = {
        enable = true;
        vaults = [
          {
            name = "mist";
            path = "vaults/mist";
          }
        ];
      };
      sesh = {
        sessions = [
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
