{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.lspconfig";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.lspconfig = {
    enable = true;
  };
}
