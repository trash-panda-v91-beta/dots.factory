{ dots, ... }:
{
  dots.tool._.nixvim.includes = [ dots.tool._.nixvim._.ui ];
  dots.tool._.nixvim._.ui.homeManager =
    { ... }:
    {
      programs.nixvim.plugins = {
        web-devicons.enable = true;

        lualine = {
          enable = true;
          lazyLoad.settings.event = "VeryLazy";
          settings.tabline.lualine_a = [
            {
              __unkeyed-1 = "tabs";
              cond.__raw = "function() return #vim.api.nvim_list_tabpages() > 1 end";
            }
          ];
        };
      };
    };
}
