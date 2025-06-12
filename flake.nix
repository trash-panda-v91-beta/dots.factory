{
  description = "dot.factory";

  inputs = {
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    editor.url = "github:aka-raccoon/dot.editor";

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";

    talhelper = {
      url = "github:budimanjojo/talhelper";
    };

    secrets = {
      url = "git+ssh://git@github.com/trash-panda-v91-beta/dots.factory.constants";
    };

  };

  outputs =
    { flake-parts, ... }@inputs:
    let
      mkPkgsWithSystem =
        system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues (import ./overlays { inherit inputs; });
          config.allowUnfree = true;
        };
      mkSystemLib = import ./lib/mkSystem.nix { inherit inputs mkPkgsWithSystem; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      perSystem =
        {
          system,
          inputs,
          pkgs,
          ...
        }:
        {
          _module.args.pkgs = mkPkgsWithSystem system;
          packages = import ./pkgs { inherit pkgs inputs; };
        };

      imports = [ ];

      flake = {
        nixosConfigurations = {
          ley = mkSystemLib.mkNixosSystem "x86_64-linux" "ley" [ "c4300n" ];
        };
        darwinConfigurations = {
          amb = mkSystemLib.mkDarwinSystem "aarch64-darwin" "amb" [ "c4300n" ];
          cmb = mkSystemLib.mkDarwinSystem "aarch64-darwin" "cmb" [ "I572068" ];
          pmb = mkSystemLib.mkDarwinSystem "aarch64-darwin" "pmb" [ "trash-panda-v91-beta" ];
        };

        ciSystems =
          let
            nixos = inputs.nixpkgs.lib.genAttrs (builtins.attrNames inputs.self.nixosConfigurations) (
              attr: inputs.self.nixosConfigurations.${attr}.config.system.build.toplevel
            );
            darwin = inputs.nixpkgs.lib.genAttrs (builtins.attrNames inputs.self.darwinConfigurations) (
              attr: inputs.self.darwinConfigurations.${attr}.system
            );
          in
          nixos // darwin;

      };
    };

}
