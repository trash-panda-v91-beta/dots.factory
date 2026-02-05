{ delib, ... }:

delib.rice {
  name = "koda";
  home.programs.nixvim = {
    plugins.koda.enable = true;
    colorscheme = "koda";
  };
}
