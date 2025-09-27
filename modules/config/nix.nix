{
  delib,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  shared.nix = {
    package = lib.mkForce pkgs.nixVersions.latest;
    settings = {
      # Enable flakes
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;

      # Add cachix and other trusted substituters
      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://cache.garnix.io"
        "https://numtide.cachix.org"
        "https://cache.nixos.org/"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];

      # Fallback quickly if substituters are not available
      connect-timeout = 5;

      # Avoid copying unnecessary stuff over SSH
      builders-use-substitutes = true;
    };
  };
in
delib.module {
  name = "nix";

  nixos.always = shared;
  home.always = shared;
}
