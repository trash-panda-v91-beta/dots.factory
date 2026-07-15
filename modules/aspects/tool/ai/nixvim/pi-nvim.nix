{ dots, ... }:
{
  dots.tool._.ai.includes = [ dots.tool._.ai._."ai-pi-nvim" ];
  dots.tool._.ai._."ai-pi-nvim".homeManager = { pkgs, ... }: {
    programs.nixvim = {
      extraPlugins = [ pkgs.local.pi-nvim ];
      extraConfigLua = ''require("pi-nvim").setup()'';

      plugins.which-key.settings.spec = [
        {
          __unkeyed-1 = "<leader>p";
          group = "Pi";
          icon = "🥧";
          mode = [ "n" "v" ];
        }
      ];
    };
  };
}
