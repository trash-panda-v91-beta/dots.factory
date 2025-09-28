{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.grug-far";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.grug-far = {
    enable = true;
  };
}
