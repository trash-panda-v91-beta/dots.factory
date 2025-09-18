{
  delib,
  lib,
  ...
}:
delib.module {
  name = "unfreePackages";

  options.unfreePackages = with delib; {
    allow = listOfOption str [ ];
  };

  nixos.always =
    { cfg, ... }:
    {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) cfg.allow;
    };

  darwin.always =
    { cfg, ... }:
    {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) cfg.allow;
    };
}
