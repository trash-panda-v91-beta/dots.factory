{
  inputs,
  delib,
  ...
}:
delib.overlayModule {
  name = "nixkpgs.master";
  overlay =
    let
      system = "aarch64-darwin";
    in
    final: prev:
    let
      inherit (final) config;
      master = import inputs.nixpkgs-master {
        inherit system config;
      };
    in
    {
      inherit master;
    };
}
