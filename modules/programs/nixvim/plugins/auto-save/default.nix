{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.auto-save";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.auto-save = {
    enable = true;
  };
}
