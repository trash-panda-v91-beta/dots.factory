{
  lib,
  ...
}:
let
  inherit (builtins) readDir;
  inherit (lib.attrsets) foldlAttrs;
  inherit (lib.lists) optional;
  by-name = ./apps;
in
{
  imports =
    (foldlAttrs (
      prev: name: type:
      prev ++ optional (type == "directory") (by-name + "/${name}")
    ) [ ] (readDir by-name))
    ++ [
      ./homebrew.nix
      ./nix.nix
      ./os-defaults.nix
      ./sops.nix
      ./users.nix

    ];
  system.stateVersion = 5;
}
