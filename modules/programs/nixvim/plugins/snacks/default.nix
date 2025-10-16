{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks";
  options = delib.singleEnableOption true;
  home.ifEnabled.programs.nixvim = {
    plugins.snacks = {
      enable = true;
    };
  };
}
