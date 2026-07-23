{ inputs, lib, ... }:
let
  pkgsDir = ../../../packages;
in
{
  dots.platform._.overlays = {
    description = "Local pkgs.local.* overlay";

    darwin = {
      home-manager.useGlobalPkgs = true;

      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "1password"
        "1password-cli"
        "claude-code"
        "obsidian"
      ];

      nixpkgs.overlays = [
        (final: prev: {
          # herdr's source build vendors libghostty-vt which needs xcrun; use
          # upstream release binary on darwin.
          herdr-splits = prev.callPackage "${pkgsDir}/herdr-splits" { };
          # herdr source tree (integration assets, etc.) - kept separate from the
          # binary-fetch herdr derivation below which has no src attribute.
          herdr-src = prev.herdr.src;

          herdr = prev.stdenv.mkDerivation {
            pname = "herdr";
            version = "0.7.1";
            src = prev.fetchurl {
              url = "https://github.com/ogulcancelik/herdr/releases/download/v0.7.1/herdr-macos-aarch64";
              hash = "sha256-FvRlPwSR6h59K0a1sCVC8Y4bguiNqvnikAVy5btjTfg=";
            };
            dontUnpack = true;
            installPhase = ''
              install -Dm755 $src $out/bin/herdr
            '';
            meta = {
              description = "Terminal workspace manager for AI coding agents";
              homepage = "https://herdr.dev";
              license = lib.licenses.agpl3Plus;
              mainProgram = "herdr";
              platforms = [ "aarch64-darwin" ];
              sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
            };
          };

          local = {
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
pi-lsp = prev.callPackage "${pkgsDir}/pi-lsp" { inherit inputs; };
            ponytail-pi = prev.callPackage "${pkgsDir}/ponytail-pi" { inherit inputs; };
            pi-mcp-adapter = prev.callPackage "${pkgsDir}/pi-mcp-adapter" { inherit inputs; };
            pi-web-access = prev.callPackage "${pkgsDir}/pi-web-access" { inherit inputs; };
            pi-neuralwatt = prev.callPackage "${pkgsDir}/pi-neuralwatt" { inherit inputs; };
            vault-workspace = prev.callPackage "${pkgsDir}/vault-workspace" { };
          };
        })
      ];
    };
  };
}
