{ dots, ... }:
{
  dots.tool._.git.includes = [ dots.tool._.git._.git-neogit ];
  dots.tool._.git._.git-neogit.homeManager = { lib, ... }: {
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
          builders.NeogitPullPopup.__raw = ''
            function(builder)
              builder:action("m", "Checkout main and pull", function(popup)
                local git = require("neogit.lib.git")
                git.branch.checkout("main")

                local current = git.branch.current()
                local pushRemote = git.branch.pushRemote() or git.branch.set_pushRemote()
                if pushRemote and current then
                  git.pull.pull_interactive(pushRemote, current, popup:get_arguments())
                end
              end)
            end
          '';
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
