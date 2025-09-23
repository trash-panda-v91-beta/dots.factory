{
  config,
  delib,
  inputs,
  homeManagerUser,
  moduleSystem,
  pkgs,
  ...
}:
let
  shared.home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };
in
delib.module {
  name = "home";
  options = delib.singleEnableOption true;

  myconfig.always.args.shared.homeconfig =
    if moduleSystem == "home" then config else config.home-manager.users.${homeManagerUser};

  nixos.always.imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home.ifEnabled.programs.home-manager.enable = true;
  nixos.ifEnabled = shared;
  darwin.ifEnabled = shared;
}
