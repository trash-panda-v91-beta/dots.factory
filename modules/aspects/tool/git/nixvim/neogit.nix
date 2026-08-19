{ dots, ... }:
{
  dots.tool._.git.includes = [ dots.tool._.git._.git-neogit ];
  dots.tool._.git._.git-neogit.homeManager = { ... }: {
    programs.nixvim = {
      plugins.neogit = {
        enable = true;
        lazyLoad.settings.cmd = [ "Neogit" ];
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
                local client = require("neogit.client")
                git.branch.checkout("main")
                git.cli.pull.env(client.get_envs_git_editor()).args("origin", "main").arg_list(popup:get_arguments()).call {
                  pty = true,
                }
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
      ];
    };
  };
}
