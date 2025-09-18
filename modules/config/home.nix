{
  config,
  delib,
  inputs,
  homeManagerUser,
  moduleSystem,
  pkgs,
  ...
}:
delib.module {
  name = "home";
  options = delib.singleEnableOption true;

  myconfig.always.args.shared.homeconfig =
    if moduleSystem == "home" then config else config.home-manager.users.${homeManagerUser};

  nixos.always.imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home.always =
    { myconfig, ... }:
    let
      username = myconfig.user.name;
    in
    {
      home = {
        inherit username;
        homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
      };
    };

  home.ifEnabled.programs.home-manager.enable = true;
  nixos.ifEnabled = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };
  };
  darwin.ifEnabled = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
    };
  };
}
