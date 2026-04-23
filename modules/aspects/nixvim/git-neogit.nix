{ dots, ... }:
{
  dots.git.includes = [ dots.git._.git-neogit ];
  dots.git._.git-neogit.homeManager = { lib, ... }: {
  programs.nixvim = {
    plugins.neogit = {
      enable = true;
      settings = {
        kind = "replace";
        mappings = {
          status = {
            "<C-s>" = false;
          };
        };
      };
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
          desc = "Sync main (checkout->fetch->pull)";
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
          desc = "New branch (main->pull->create)";
        };
      }
    ];

    # Add autocommand/keymaps for OpenCode commit integration
    autoCmd = [
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
