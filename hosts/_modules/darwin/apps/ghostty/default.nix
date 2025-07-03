{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.ghostty;
in
{
  options.modules.ghostty = {
    enable = lib.mkEnableOption "ghostty";
  };
  config = lib.mkIf cfg.enable {
    homebrew = {
      casks = [
        "ghostty@tip"
      ];
    };
  };
}
