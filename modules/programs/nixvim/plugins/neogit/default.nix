{
  delib,
  lib,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.neogit";

  options.programs.nixvim.plugins.neogit = with delib; {
    enable = boolOption true;
    gitService = allowNull (strOption null);
    openCodeCommit = {
      enable = boolOption true;
      autoGenerate = boolOption false;
      keymap = strOption "<leader>gc";
    };
  };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.nixvim = {
        plugins.neogit = {
          enable = true;
          settings = {
            mappings = {
              status = {
                "<C-s>" = false;
              };
            };
          }
          // (lib.mkIf (cfg.gitService != null) {
            git_services = {
              "${cfg.gitService}" = {
                pull_request = "https://${cfg.gitService}/\${owner}/\${repository}/compare/\${branch_name}?expand=1";
                commit = "https://${cfg.gitService}/\${owner}/\${repository}/commit/\${oid}";
                tree = "https://${cfg.gitService}/\${owner}/\${repository}/tree/\${branch_name}";
              };
            };
          });
        };
        keymaps = [
          {
            mode = [ "n" ];
            key = "<leader>gg";
            action = "<cmd>Neogit<cr>";
            options = {
              desc = "Open Neogit";
            };
          }
          {
            mode = [ "n" ];
            key = "<leader>gm";
            action.__raw = ''
              function()
                -- ... your Lua code ...
              end
            '';
            options = {
              desc = "Sync main (checkout→fetch→pull)";
            };
          }
          {
            mode = [ "n" ];
            key = "<leader>gn";
            action.__raw = ''
              function()
                -- ... your Lua code ...
              end
            '';
            options = {
              desc = "New branch (main→pull→create)";
            };
          }
        ];

        # Add autocommand/keymaps for OpenCode commit integration (unchanged now)
        autoCmd = lib.optionals cfg.openCodeCommit.enable [
          {
            event = [ "FileType" ];
            pattern = [
              "gitcommit"
              "NeogitCommitMessage"
            ];
            callback = {
              __raw = ''
                function(event)
                  -- ... your Lua code ...
                end
              '';
            };
          }
        ];
      };
    };
}
