{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.mini.statusline";

  options = delib.singleEnableOption false;

  home.ifEnabled.programs.nixvim.plugins.mini-statusline = {
    enable = true;
  };
}
