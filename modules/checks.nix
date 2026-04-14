# Eval-based checks — run via `nix flake check` (or `mise run check`)
{ inputs, lib, ... }:
let
  system = "aarch64-darwin";
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  mkAssertCheck = name: assertions:
    pkgs.runCommand "check-${name}" { } (
      lib.concatMapStringsSep "\n"
        ({ cond, msg }:
          if cond then "" else ''echo "FAIL [${name}]: ${lib.escape [ "\"" "$" ] msg}" && exit 1'')
        assertions
      + "\necho 'OK: ${name}' && touch $out"
    );

  pmb = inputs.self.darwinConfigurations.pmb;
  hm = pmb.config.home-manager.users.trash-panda-v91-beta;

  assertions = [
    { cond = pmb.config.networking.hostName == "pmb";               msg = "networking.hostName should be 'pmb'"; }
    { cond = pmb.config.system.stateVersion == 6;                   msg = "system.stateVersion should be 6"; }
    { cond = builtins.elem "trash-panda-v91-beta"
        (builtins.attrNames pmb.config.home-manager.users);         msg = "home-manager user 'trash-panda-v91-beta' should exist"; }
    { cond = hm.home.homeDirectory == "/Users/trash-panda-v91-beta"; msg = "home.homeDirectory should be '/Users/trash-panda-v91-beta'"; }
    { cond = hm.programs.nushell.enable;                            msg = "programs.nushell should be enabled"; }
    { cond = hm.programs.tmux.enable;                               msg = "programs.tmux should be enabled"; }
    { cond = hm.programs.nixvim.enable;                             msg = "programs.nixvim should be enabled"; }
    { cond = pmb.config.homebrew.enable;                            msg = "homebrew should be enabled"; }
  ];
in
{
  flake.checks."${system}".pmb-config = mkAssertCheck "pmb-config" assertions;
}
