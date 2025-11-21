{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.mini.extra";

  options = delib.singleEnableOption false;

  home.ifEnabled.programs.nixvim.plugins.mini-extra = {
    enable = true;
  };
}
