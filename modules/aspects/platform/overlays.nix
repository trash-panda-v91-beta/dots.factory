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
        "copilot-language-server"
        "obsidian"
        "raycast"
      ];

      nixpkgs.overlays = [
        (final: prev: {
          # herdr's source build vendors libghostty-vt which needs xcrun; use
          # upstream release binary on darwin.
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

          # TODO: remove once nixpkgs-unstable has nushell >= 0.112.2 (0.112.1 aarch64-darwin failed
          # on Hydra due to env_shlvl tests requiring exec(2) which is blocked by Nix sandbox on macOS
          # — no binary cache hit exists, forces local compile with tests disabled)
          nushell = prev.nushell.overrideAttrs (_: {
            doCheck = false;
          });
          # luajit_2_0 source in nixpkgs c6d65881 incorrectly omits aarch64-darwin from meta.platforms,
          # causing ha-mcp → fastmcp → lupa → luajit_2_0 to fail on Apple Silicon (nixpkgs bug)
          luajit_2_0 = prev.luajit_2_0.overrideAttrs (old: {
            meta = (old.meta or { }) // {
              platforms = old.meta.platforms ++ [ "aarch64-darwin" ];
            };
          });
          local = {
            koda-nvim = prev.callPackage "${pkgsDir}/koda-nvim" { inherit inputs; };
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
            superpowers = prev.callPackage "${pkgsDir}/superpowers" { inherit inputs; };
          };
        })
      ];
    };
  };
}
