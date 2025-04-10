{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.any-nix-shell;
in
{
  options.modules.any-nix-shell = {
    enable = lib.mkEnableOption "any-nix-shell";
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.any-nix-shell ];
    programs.fish.interactiveShellInit = ''
      any-nix-shell fish --info-right | source
    '';

  };
}
