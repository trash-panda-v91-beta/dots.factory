{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.homerow;
in
{
  options.modules.homerow = {
    enable = lib.mkEnableOption "homerow";
  };
  config = lib.mkIf cfg.enable {
    homebrew = {
      casks = [
        "homerow"
      ];
    };
  };
}
