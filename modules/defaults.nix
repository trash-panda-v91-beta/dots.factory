{
  den,
  lib,
  __findFile,
  ...
}:
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
    # Forward home.sessionVariables into nushell when enabled
    {
      homeManager =
        { config, lib, ... }:
        lib.mkIf config.programs.nushell.enable {
          programs.nushell.environmentVariables = config.home.sessionVariables;
        };
    }
  ];

  # Restrict perSystem evaluation to aarch64-darwin only.
  # nixpkgs 26.11 dropped x86_64-darwin; treefmt-nix (via hunk) would
  # otherwise try to evaluate perSystem for x86_64-darwin and fail.
  systems = [ "aarch64-darwin" ];

  # Formatters for nix fmt
  perSystem =
    { pkgs, system, ... }:
    {
      formatter = pkgs.nixfmt-rfc-style;
    };
}
