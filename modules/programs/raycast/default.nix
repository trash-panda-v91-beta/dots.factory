{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.raycast";

  options = delib.singleEnableOption false;

  myconfig.ifEnabled.unfreePackages.allow = [ "raycast" ];

  darwin.ifEnabled = {
    environment.systemPackages = with pkgs; [
      raycast
    ];
  };

  home.ifEnabled =
    {
      myconfig,
      ...
    }:
    let
      scriptsFolder = "raycast/scripts";
    in
    {
      xdg.configFile = {
        "${scriptsFolder}/dismiss-notifications.js".source = scripts/dismiss-notifications.js;
        "${scriptsFolder}/open-notifications.js".source = scripts/open-notifications.js;
        "${scriptsFolder}/fix-grammar.sh".source = scripts/fix-grammar.sh;
        "${scriptsFolder}/update-dots-factory.sh".text = ''
          #!/bin/bash

          # @raycast.schemaVersion 1
          # @raycast.title Sync dots
          # @raycast.mode compact
          # @raycast.packageName Raycast Scripts
          # @raycast.icon ⚫
          # @raycast.currentDirectoryPath ~
          # @raycast.needsConfirmation false
          # Documentation:
          # @raycast.description Run NixOS rebuild command

          GH_TOKEN=$(${pkgs.lib.getExe pkgs._1password-cli} read "op://Private/dots.vault Read Access/password")
          echo "Building and switching to configuration for '${myconfig.host.name}' ..."
          NIX_CONFIG="access-tokens = github.com=$GH_TOKEN" nh darwin switch . --hostname {{hostname}}
        '';
      };
    };
}
