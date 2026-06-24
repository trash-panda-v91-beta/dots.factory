{ dots, ... }:
{
  dots.tool._.git.includes = [ dots.tool._.git._.git-diffview ];
  dots.tool._.git._.git-diffview.homeManager = { ... }: {
    programs.nixvim = {
      plugins.diffview = {
        enable = true;
        settings = {
          integrations = {
            neogit = true;
          };
        };
      };

      keymaps = [
        {
          mode = [ "n" ];
          key = "<leader>gd";
          action = "<cmd>DiffviewOpen<cr>";
          options = {
            desc = "Open Diffview";
          };
        }
        {
          mode = [ "n" ];
          key = "<leader>gh";
          action = "<cmd>DiffviewFileHistory<cr>";
          options = {
            desc = "Diffview File History";
          };
        }
        {
          mode = [ "n" ];
          key = "<leader>gH";
          action = "<cmd>DiffviewFileHistory %<cr>";
          options = {
            desc = "Diffview Current File History";
          };
        }
      ];
    };
  };
}
