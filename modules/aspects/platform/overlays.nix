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

          # shortcut: pins 1Password at 8.12.44 while nixpkgs still ships
          # 8.12.42; the MAS 1Password for Safari extension (8.12.44) has
          # already migrated the shared data dir, so the frozen app refuses
          # to start. Remove once nixpkgs ships >= 8.12.44.
          _1password-gui = prev._1password-gui.overrideAttrs (old: {
            version = "8.12.44";
            src = prev.fetchurl {
              url = "https://downloads.1password.com/mac/1Password-8.12.44-aarch64.zip";
              hash = "sha256-mySxRkv0N4DwThr6+LB0LyFjypTbiwYgBZ56BaJJj6E=";
            };
          });

          local = {
            herdr-ext = prev.callPackage "${pkgsDir}/herdr" { };
            misdr-ext = prev.callPackage "${pkgsDir}/misdr" { };
            aws-ext = prev.callPackage "${pkgsDir}/aws-ext" { };
            koda-nvim = prev.callPackage "${pkgsDir}/koda-nvim" { inherit inputs; };
            pi-nvim = inputs.pi-nvim;
            context7-pi = prev.callPackage "${pkgsDir}/context7-pi" { inherit inputs; };
            obsidian-minimal-settings-plugin =
              prev.callPackage "${pkgsDir}/obsidian-minimal-settings-plugin"
                { };
            obsidian-minimal-theme = prev.callPackage "${pkgsDir}/obsidian-minimal-theme" { inherit inputs; };
            obsidian-tasknotes-plugin = prev.callPackage "${pkgsDir}/obsidian-tasknotes-plugin" { };
            cfn-lsp = prev.callPackage "${pkgsDir}/cfn-lsp" { };
            pi-lsp = prev.callPackage "${pkgsDir}/pi-lsp" { inherit inputs; };
            ponytail-pi = prev.callPackage "${pkgsDir}/ponytail-pi" { inherit inputs; };
            pi-web-access = prev.callPackage "${pkgsDir}/pi-web-access" { inherit inputs; };
            tiny-code-action-nvim = prev.callPackage "${pkgsDir}/tiny-code-action-nvim" { inherit inputs; };
            vault-workspace = prev.callPackage "${pkgsDir}/vault-workspace" { };
            vault-nvim = prev.callPackage "${pkgsDir}/vault-nvim" { };
            vault-obsidian = prev.callPackage "${pkgsDir}/vault-obsidian" {
              vault-workspace = prev.callPackage "${pkgsDir}/vault-workspace" { };
            };
          };
        })
      ];
    };
  };
}
