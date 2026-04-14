{ inputs, ... }:
let
  pkgsDir = ../../../packages;
in
{
  dots.overlays = {
    description = "Local pkgs.local.* overlay";

    darwin = {
      home-manager.useGlobalPkgs = true;

      nixpkgs.overlays = [
        (final: prev: {
          # duckdb 1.5.1 test suite crashes on macOS (SIGTRAP/BPT trap) — skip tests
          duckdb = prev.duckdb.overrideAttrs (_: { doCheck = false; });
          local = {
            koda-nvim = prev.callPackage "${pkgsDir}/koda-nvim" { inherit inputs; };
            obsidian-bases-nvim = prev.callPackage "${pkgsDir}/obsidian-bases-nvim" { inherit inputs; };
            obsidian-minimal-settings-plugin = prev.callPackage "${pkgsDir}/obsidian-minimal-settings-plugin" {
              inherit inputs;
            };
            obsidian-minimal-theme = prev.callPackage "${pkgsDir}/obsidian-minimal-theme" { inherit inputs; };
            obsidian-tasknotes-plugin = prev.callPackage "${pkgsDir}/obsidian-tasknotes-plugin" {
              inherit inputs;
            };
            opencode-nvim = prev.callPackage "${pkgsDir}/opencode-nvim" { inherit inputs; };
            superpowers = prev.callPackage "${pkgsDir}/superpowers" { inherit inputs; };
            tmux-pane-toggler = prev.callPackage "${pkgsDir}/tmux-pane-toggler" { inherit inputs; };
          };
        })
      ];
    };
  };
}
