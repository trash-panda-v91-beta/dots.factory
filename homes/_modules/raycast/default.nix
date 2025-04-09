{
  lib,
  config,
  hostname,
  pkgs,
  ...
}:
let
  cfg = config.modules.raycast;
  scripts = "raycast/scripts";
in
{
  options.modules.raycast = {
    enable = lib.mkEnableOption "raycast";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ raycast ];

    xdg.configFile."${scripts}/rebuild-dots.sh" = {
      text = ''
        #!${pkgs.bash}/bin/bash

        # @raycast.schemaVersion 1
        # @raycast.title Rebuild dots
        # @raycast.mode compact
        # @raycast.packageName Raycast Scripts
        # @raycast.icon ⚫
        # @raycast.currentDirectoryPath ~
        # @raycast.needsConfirmation false
        # Documentation:
        # @raycast.description Run NixOS rebuild command

        /run/current-system/sw/bin/darwin-rebuild switch --flake "git+ssh://git@github.com/aka-raccoon/dot.factory/#${hostname}"
      '';
      executable = true;
    };
  };
}
