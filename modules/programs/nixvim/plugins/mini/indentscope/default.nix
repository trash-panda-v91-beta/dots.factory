{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.mini.indentscope";
  options = delib.singleEnableOption true;
  home.ifEnabled.programs.nixvim = {
    plugins.mini = {
      enable = true;
      modules.indentscope = {
      };
    };
  };
}
