{ inputs, lib, ... }:
{
  dots.platform._.homebrew = {
    description = "Homebrew management via nix-homebrew";

    includes = [ { darwin.imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ]; } ];

    darwin =
      { host, config, ... }:
      let
        nixHomebrewTaps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
        }
        // lib.optionalAttrs (host.name == "pmb") {
          "neved4/tap" = inputs.neved4-tap;
        };
      in
      {
        nix-homebrew = {
          enable = true;
          mutableTaps = false;
          user = config.system.primaryUser;
          taps = nixHomebrewTaps;
        };
        homebrew = {
          enable = true;
          greedyCasks = true;
          onActivation = {
            # cleanup = "zap";
            autoUpdate = false;
            upgrade = true;
          };
          taps = builtins.attrNames nixHomebrewTaps;
          casks = lib.optionals (host.name == "pmb") [ "cinny" ];
        };
      };
  };
}
