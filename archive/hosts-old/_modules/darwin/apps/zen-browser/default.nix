{
  lib,
  config,
  ...
}:
let
  cfg = config.modules.zen-browser;
in
{
  options.modules.zen-browser = {
    enable = lib.mkEnableOption "zen-browser";
  };
  config = lib.mkIf cfg.enable {
    homebrew = {
      casks = [
        "zen"
      ];
    };
  };
}
