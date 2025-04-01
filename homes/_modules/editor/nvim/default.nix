{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.editor.nvim;
  nixvim = inputs.nixvim.packages.${pkgs.system}.default;
in
{
  options.modules.editor.nvim = {
    enable = lib.mkEnableOption "nvim";
    makeDefaultEditor = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.makeDefaultEditor) {
      home.packages = [ nixvim ];
      programs.git.extraConfig.core.editor = "nvim";
      home.sessionVariables = {
        EDITOR = "nvim";
        MANPAGER = "nvim +Man!";
      };

      programs.fish = {
        shellAliases = {
          vi = "nvim";
          vim = "nvim";
        };
      };
    })
  ];
}
