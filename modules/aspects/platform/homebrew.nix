{ inputs, ... }:
{
  dots.platform._.homebrew = {
    description = "Homebrew management via nix-homebrew";

    includes = [ { darwin.imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ]; } ];

    darwin =
      { config, pkgs, ... }:
      let
        # Upstream tap's cask still uses `depends_on macos: :high_sierra`, a directive
        # Homebrew 6.x removed -> cask fails to load. Strip it until the tap fixes it.
        sableTap = pkgs.runCommand "sable-tap" { } ''
          cp -R "${inputs.sable-tap}" "$out"
          chmod -R u+w "$out"
          sed -i '/depends_on macos: :high_sierra/d' "$out/Casks/sable.rb"
        '';
        nixHomebrewTaps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
          "SableClient/homebrew-sable" = sableTap;
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
        };
        nix-homebrew.trust.casks = [ "SableClient/sable/sable" ];
      };
  };
}
