{
  delib,
  ...
}:
delib.host {
  name = "pmb";

  homeManagerSystem = "aarch64-darwin";
  home.home.stateVersion = "24.05";

  nixos = {
    nixpkgs.hostPlatform = "aarch64-darwin";
    system.stateVersion = "24.05";
  };
  darwin = {
    nixpkgs.hostPlatform = "aarch64-darwin";
    system.stateVersion = 6;
  };
}
