{
  delib,
  ...
}:
delib.host {
  name = "pmb";

  features = [
    "coding"
    "githubCopilot"
    "kubernetes"
    "python"
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

    programs = {
      actual.enable = true;
      colima.enable = true;
      git.userEmail = "42897550+trash-panda-v91-beta@users.noreply.github.com";
      mcp.servers = {
        actualBudget = {
          disabled = true;
          command = "docker";
          args = [
            "run"
            "-i"
            "--rm"
            "-e"
            "ACTUAL_PASSWORD={env:ACTUAL_PASSWORD}"
            "-e"
            "ACTUAL_SERVER_URL=https://actual.nebular-grid.space"
            "-e"
            "ACTUAL_BUDGET_SYNC_ID={env:ACTUAL_BUDGET_SYNC_ID}"
            "sstefanov/actual-mcp:latest"
            "--enable-write"
          ];
        };
        home-assistant = {
          disabled = false;
          url = "https://hass.nebular-grid.space/api/mcp";
          headers = {
            Authorization = "Bearer {env:HASS_TOKEN}";
          };
        };
      };
      nushell.enable = true;
      nixvim.plugins.obsidian = {
        enable = true;
        workspaces = [
          {
            name = "personal";
            path = "~/notes";
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
            windows = [ "sidekick" ];
          }
          {
            name = "nebular grid";
            path = "~/repos/personal/nebular-grid";
            startup_command = "nvim";
            windows = [ "sidekick" ];
          }
          {
            name = "notes";
            path = "~/notes";
            startup_command = "nvim";
            windows = [ "sidekick" ];
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
