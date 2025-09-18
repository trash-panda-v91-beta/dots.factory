# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'
{
  inputs,
  pkgs ? import <nixpkgs> { },
  ...
}:
{
  karabiner-config = pkgs.callPackage ./karabiner-config { };
  run-on-unlock = pkgs.callPackage ./run-on-unlock { };
  vifari = pkgs.callPackage ./vifari { };
  talhelper = inputs.talhelper.packages.${pkgs.system}.default;
}
