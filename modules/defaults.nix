{ den, lib, __findFile, ... }:
{
  den.default = {
    darwin.system.stateVersion = 6;
    homeManager.home.stateVersion = "24.05";
  };

  # Enable host<->user mutual providers and common batteries
  den.default.includes = [
    # Bidirectional host<->user config flow
    <den/mutual-provider>
    # Auto-set networking.hostName from host name
    <den/hostname>
    # Auto-create the user account on the host
    <den/define-user>
  ];

  # Formatters for nix fmt
  perSystem =
    { pkgs, system, ... }:
    {
      formatter = pkgs.nixfmt-tree;
    };
}
