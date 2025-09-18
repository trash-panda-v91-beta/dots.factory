{ delib, pkgs, ... }:
delib.module {
  name = "programs.nixvim.plugins.treesitter";

  options = delib.singleEnableOption true;

  home.ifEnabled.programs.nixvim.plugins.treesitter = {
    enable = true;

    settings = {
      indent = {
        enable = true;
      };
      highlight = {
        enable = true;
      };
    };

    folding = true;
    nixvimInjections = true;
    grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
  };
}
