{
  description = "dot.factory";

  inputs = {
    codecompanion-gitcommit-nvim = {
      url = "github:jinzhongjia/codecompanion-gitcommit.nvim/0.0.14";
      flake = false;
    };
    denix = {
      url = "github:yunfachi/denix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.nix-darwin.follows = "nix-darwin";
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixvim.url = "github:nix-community/nixvim";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # vault.url = "git+ssh://git@github.com/trash-panda-v91-beta/dots.vault";
    vault.url = "github:trash-panda-v91-beta/dots.vault";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { denix, self, ... }@inputs:
    let
      mkConfigurations =
        moduleSystem:
        denix.lib.configurations {
          inherit moduleSystem;
          homeManagerUser = "trash-panda-v91-beta";

          paths = [
            ./modules
            ./overlays
            ./rices
          ]
          ++ {
            nixos = [ ./hosts/nixos ];
            darwin = [ ./hosts/darwin ];
            home = [ ./hosts ];
          }
          .${moduleSystem};

          extensions = with denix.lib.extensions; [
            args
            (base.withConfig {
              args.enable = true;
              hosts.features = {
                features = [
                  "coding"
                  "githubCopilot"
                  "kubernetes"
                ];
              };
            })
            (overlays.withConfig {
              defaultTargets = [
                # "nixos"
                "darwin"
              ];
            })
          ];

          specialArgs = {
            inherit inputs self moduleSystem;
          };
        };
    in
    {
      nixosConfigurations = mkConfigurations "nixos";
      homeConfigurations = mkConfigurations "home";
      darwinConfigurations = mkConfigurations "darwin";

      # Add default package for nix build
      packages.aarch64-darwin.default = inputs.nixpkgs.legacyPackages.aarch64-darwin.stdenv.mkDerivation {
        name = "dots-factory";
        version = "0.1.0";
        src = ./.;
        installPhase = ''
          mkdir -p "$out"/bin
          echo "echo 'dots.factory configuration system'" >"$out"/bin/dots-factory
          chmod +x "$out"/bin/dots-factory
        '';
        meta = {
          description = "dot.factory configuration system";
          mainProgram = "dots-factory";
        };
      };
    };
}
