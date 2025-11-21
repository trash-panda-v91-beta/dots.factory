{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.scope";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.nixvim.plugins.snacks.settings.scope = {
      enabled = true;
      treesitter = {
        blocks = {
          enabled = true; # use treesitter for semantic scope detection
        };
      };
    };
  };
}
