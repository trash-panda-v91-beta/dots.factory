{ dots, ... }:
{
  dots.tool._.git.includes = [ dots.tool._.git._."snacks-lazygit" ];
  dots.tool._.git._."snacks-lazygit".homeManager = { ... }: {
    programs.nixvim = {
      plugins.snacks.settings.lazygit.enabled = true;

      keymaps = [
        {
          mode = "n";
          key = "<leader>gl";
          action = "<cmd>lua Snacks.lazygit()<CR>";
          options.desc = "Open lazygit";
        }
      ];
    };
  };
}
