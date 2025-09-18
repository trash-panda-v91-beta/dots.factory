{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.mini.surround";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.mini-surround = {
    enable = true;
  };
}
