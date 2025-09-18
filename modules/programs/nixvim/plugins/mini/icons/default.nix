{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.mini.icons";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.mini-icons = {
    enable = true;
    mockDevIcons = true;
  };
}
