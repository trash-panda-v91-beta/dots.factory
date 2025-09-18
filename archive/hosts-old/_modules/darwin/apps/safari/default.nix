{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.safari;
in
{
  options.modules.safari = {
    enable = lib.mkEnableOption "safari";
  };
  config = lib.mkIf cfg.enable {
    homebrew = {
      masApps = {
        "1Password For Safari" = 1569813296;
        "Ghostery Privacy Ad Blocker" = 6504861501;
      };
    };
  };
}
