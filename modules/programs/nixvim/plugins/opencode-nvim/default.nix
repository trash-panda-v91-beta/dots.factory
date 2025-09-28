{ delib, pkgs, ... }:
delib.module {
  name = "programs.nixvim.plugins.opencode-nvim";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim = {
    extraPlugins = [ pkgs.local.opencode-nvim ];
    extraConfigLua = ''require("opencode").setup({ prefered_picker = "mini.pick", prefered_completion = "blink" })'';
  };
}
