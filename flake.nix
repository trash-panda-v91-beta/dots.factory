{
  description = "dot.factory";

  inputs = {
    codecompanion-gitcommit-nvim = {
      url = "github:jinzhongjia/codecompanion-gitcommit.nvim";
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
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixvim.url = "github:nix-community/nixvim";
    opencode = {
      url = "github:sst/opencode/dev";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tiny-diagnostics-nvim = {
      url = "github:rachartier/tiny-diagnostics.nvim";
      flake = false;
    };
    vault.url = "github:trash-panda-v91-beta/dots.vault";
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
                  "python"
                  "rust"
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
      darwinConfigurations = mkConfigurations "darwin";
      homeConfigurations = mkConfigurations "home";
      nixosConfigurations = mkConfigurations "nixos";

      templates = {
        rust = {
          path = ./templates/rust;
          description = "Rust development environment with rust-overlay";
        };
      };

      formatter = {
        aarch64-darwin = inputs.nixpkgs.legacyPackages.aarch64-darwin.nixfmt-tree;
        x86_64-linux = inputs.nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
        aarch64-linux = inputs.nixpkgs.legacyPackages.aarch64-linux.nixfmt-tree;
        x86_64-darwin = inputs.nixpkgs.legacyPackages.x86_64-darwin.nixfmt-tree;
      };
    };
}
