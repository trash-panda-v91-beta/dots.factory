{
  lib,
  config,
  ...
}:
let
  cfg = config.modules._1password-gui;
in
{
  options.modules._1password-gui = {
    enable = lib.mkEnableOption "1password-gui";
  };
  config = lib.mkIf cfg.enable {
    homebrew = {
      casks = [
        "1password"
      ];
    };
  };
}
