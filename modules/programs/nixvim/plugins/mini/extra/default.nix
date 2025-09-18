{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.mini.extra";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.mini-extra = {
    enable = true;
  };
}
