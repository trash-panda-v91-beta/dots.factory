{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.programs.docker-cli;
in
{
  options.${namespace}.programs.docker-cli = {
    enable = lib.mkEnableOption "docker-cli";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.docker-buildx
      pkgs.docker-client
      pkgs.docker-compose
    ];
  };
}