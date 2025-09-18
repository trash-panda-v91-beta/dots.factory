{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.hammerspoon;
in
{
  options.modules.hammerspoon = {
    enable = lib.mkEnableOption "hammerspoon";
  };
  config = lib.mkIf cfg.enable {
    homebrew = {
      casks = [
        "hammerspoon"
      ];
    };
  };
}
