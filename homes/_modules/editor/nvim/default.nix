{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.editor.nvim;
  nixvim = inputs.editor.packages.${pkgs.system}.default.extend {
    inherit (cfg) aiProvider;
  };
in
{
  options.modules.editor.nvim = {
    enable = lib.mkEnableOption "nvim";
    aiProvider = lib.mkOption {
      type = lib.types.attrs;
      default = {
        name = "copilot";
        model = null;
      };
    };
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
