{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.mini.ai";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.mini-ai = {
    enable = true;
  };
}
