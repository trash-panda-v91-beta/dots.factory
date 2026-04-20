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
          # duckdb 1.5.1 install-check phase crashes on macOS (SIGTRAP/BPT trap: 5)
          # Tests run via doInstallCheck, not doCheck — must disable both
          duckdb = prev.duckdb.overrideAttrs (_: { doCheck = false; doInstallCheck = false; });
          # TODO: remove once nixpkgs-unstable has nushell >= 0.112.2 (0.112.1 aarch64-darwin failed
          # on Hydra due to env_shlvl tests requiring exec(2) which is blocked by Nix sandbox on macOS
          # — no binary cache hit exists, forces local compile with tests disabled)
          nushell = prev.nushell.overrideAttrs (_: { doCheck = false; });
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
