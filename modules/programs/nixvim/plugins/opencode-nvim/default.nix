{ delib, pkgs, ... }:
delib.module {
  name = "programs.nixvim.plugins.opencode-nvim";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    extraPlugins = [ pkgs.local.opencode-nvim ];

    extraConfigLua = ''
      require("opencode").setup({
      	preferred_picker = "snacks.picker",
      	preferred_completion = "blink",
      	keymap = {
      		editor = {
      			["<A-o>"] = { "toggle", mode = { "n", "i" } },
      		},
      	},
      	ui = {
      		window_width = 0.95,
      		zoom_width = 0.95,
      	},
      })
    '';
  };
}
