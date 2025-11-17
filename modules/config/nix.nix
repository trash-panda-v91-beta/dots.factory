{
  delib,
  pkgs,
  lib,
  ...
}:
let
  systemSettings =
    { myconfig, ... }:
    {
      nix = {
        package = lib.mkForce pkgs.nixVersions.latest;
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          warn-dirty = false;

          substituters = [
            "https://dots-factory.cachix.org?priority=1"
            "https://cache.nixos.org?priority=10"
            "https://nix-community.cachix.org?priority=20"
          ];
          trusted-public-keys = [
            "dots-factory.cachix.org-1:x8uhqhYtk4U697Ql3+mRI3adtVkvNRRr5XbyzXv9YSU="
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];

          trusted-users = [
            "root"
            myconfig.user.name
          ];
        };
      };
    };

  homeSettings.nix = {
    package = lib.mkForce pkgs.nixVersions.latest;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
  };
in
delib.module {
  name = "nix";

  darwin.always = systemSettings;
  nixos.always = systemSettings;
  home.always = homeSettings;
}
