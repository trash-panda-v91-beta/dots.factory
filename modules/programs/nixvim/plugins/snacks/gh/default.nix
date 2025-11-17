{ delib, pkgs, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.gh";
  options = delib.singleEnableOption true;
  home.ifEnabled.programs.nixvim = {
    extraPackages = [
      pkgs.gh
    ];
    plugins.snacks.settings.gh = {
    };
  };
}
