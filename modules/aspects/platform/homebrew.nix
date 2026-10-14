{ inputs, ... }:
{
  dots.platform._.homebrew = {
    description = "Homebrew management via nix-homebrew";

    includes = [ { darwin.imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ]; } ];

    darwin =
      { config, ... }:
      let
        # Keys are the on-disk repo names (homebrew- prefix kept); values the
        # pinned flake inputs.
        nixHomebrewTaps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
          "SableClient/homebrew-sable" = inputs.sable-tap;
        };
        # Brewfile `tap` lines use the token form (homebrew- prefix stripped).
        homebrewTapTokens = [
          "homebrew/core"
          "homebrew/cask"
          "SableClient/sable"
        ];
      in
      {
        nix-homebrew = {
          enable = true;
          mutableTaps = false;
          user = config.system.primaryUser;
          taps = nixHomebrewTaps;
          # Third-party taps need explicit trust; homebrew/* are trusted by default.
          trust.taps = [ "SableClient/sable" ];
        };
        homebrew = {
          enable = true;
          greedyCasks = true;
          onActivation = {
            # cleanup = "zap";
            autoUpdate = false;
            upgrade = true;
          };
          taps = homebrewTapTokens;
        };
      };
  };
}
