{ inputs, lib, ... }:
{
  dots.homebrew = {
    description = "Homebrew management via nix-homebrew";

    includes = [ { darwin.imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ]; } ];

    darwin =
      { host, config, ... }:
      let
        nixHomebrewTaps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
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
            cleanup = "zap";
            autoUpdate = false;
            upgrade = true;
          };
          taps = builtins.attrNames nixHomebrewTaps;
        };
      };
  };
}
