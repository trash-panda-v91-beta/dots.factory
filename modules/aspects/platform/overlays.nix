{ inputs, lib, ... }:
let
  pkgsDir = ../../../packages;
in
{
  dots.platform._.overlays = {
    description = "Local pkgs.local.* overlay";

    darwin = {
      home-manager.useGlobalPkgs = true;

      nixpkgs.config.allowUnfreePredicate =
        pkg:
        builtins.elem (lib.getName pkg) [
          "1password"
          "1password-cli"
          "claude-code"
          "obsidian"
        ];

      nixpkgs.overlays = [
        (_final: prev: {
          herdr-splits = prev.callPackage "${pkgsDir}/herdr-splits" { };

          obsidian = prev.obsidian.overrideAttrs (old: {
            # 1.13.x DMG nests the app under a versioned prefix directory.
            # Nixpkgs' installPhase then does `cp -R Obsidian.app $out/...`,
            # so sourceRoot must be the prefix directory, not the .app.
            sourceRoot = "Obsidian ${old.version}-universal";
          });

          local = {
            herdr-ext = prev.callPackage "${pkgsDir}/herdr" { };
            misdr-ext = prev.callPackage "${pkgsDir}/misdr" { };
            aws-ext = prev.callPackage "${pkgsDir}/aws-ext" { };
            koda-nvim = prev.callPackage "${pkgsDir}/koda-nvim" { inherit inputs; };
            pi-nvim = inputs.pi-nvim;
            context7-pi = prev.callPackage "${pkgsDir}/context7-pi" { inherit inputs; };
            obsidian-minimal-settings-plugin = prev.callPackage "${pkgsDir}/obsidian-minimal-settings-plugin" {
              inherit inputs;
            };
            obsidian-minimal-theme = prev.callPackage "${pkgsDir}/obsidian-minimal-theme" { inherit inputs; };
            obsidian-tasknotes-plugin = prev.callPackage "${pkgsDir}/obsidian-tasknotes-plugin" {
              inherit inputs;
            };
            cfn-lsp = prev.callPackage "${pkgsDir}/cfn-lsp" { };
            pi-lsp = prev.callPackage "${pkgsDir}/pi-lsp" { inherit inputs; };
            ponytail-pi = prev.callPackage "${pkgsDir}/ponytail-pi" { inherit inputs; };
            pi-mcp-adapter = prev.callPackage "${pkgsDir}/pi-mcp-adapter" { inherit inputs; };
            pi-web-access = prev.callPackage "${pkgsDir}/pi-web-access" { inherit inputs; };
            pi-neuralwatt = prev.callPackage "${pkgsDir}/pi-neuralwatt" { inherit inputs; };
            tiny-code-action-nvim = prev.callPackage "${pkgsDir}/tiny-code-action-nvim" { inherit inputs; };
            vault-workspace = prev.callPackage "${pkgsDir}/vault-workspace" { };
          };
        })
      ];
    };
  };
}
