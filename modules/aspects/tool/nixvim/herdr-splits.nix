{ dots, ... }:
{
  dots.tool._.nixvim.includes = [ dots.tool._.nixvim._.herdr-splits ];
  dots.tool._.nixvim._.herdr-splits.homeManager =
    { pkgs, ... }:
    let
      herdr-splits-nvim = pkgs.vimUtils.buildVimPlugin {
        pname = "herdr-splits.nvim";
        version = "2026-07-08";
        # reuse the same source as the herdr-side package in pkgs.herdr-splits
        src = pkgs.herdr-splits.src;
      };
    in
    {
      programs.nixvim = {
        extraPlugins = [ herdr-splits-nvim ];

        # ponytail: resize keys omitted - alt+h/j/k/l are taken by herdr tab bindings
        extraConfigLua = ''
          require('herdr-splits').setup()
        '';

        keymaps = [
          { mode = "n"; key = "<C-h>"; action.__raw = "function() require('herdr-splits').move_cursor_left() end"; options.desc = "Navigate left"; }
          { mode = "n"; key = "<C-j>"; action.__raw = "function() require('herdr-splits').move_cursor_down() end"; options.desc = "Navigate down"; }
          { mode = "n"; key = "<C-k>"; action.__raw = "function() require('herdr-splits').move_cursor_up() end"; options.desc = "Navigate up"; }
          { mode = "n"; key = "<C-l>"; action.__raw = "function() require('herdr-splits').move_cursor_right() end"; options.desc = "Navigate right"; }
        ];
      };
    };
}
