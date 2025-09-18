{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "services.karabiner-dk";

  options = delib.singleEnableOption false;

  darwin.always.imports = [
    ../../../extra/karabiner-dk.nix
  ];

  darwin.ifEnabled = {
    services.karabiner-dk = {
      enable = true;
      package = pkgs.local.karabiner-dk;
    };
  };
}
