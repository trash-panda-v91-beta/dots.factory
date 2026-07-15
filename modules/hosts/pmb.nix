# PMB - personal MacBook (aarch64-darwin)
#
# Host aspect = platform-level only. Everything else is enabled per-capability
# from the user aspect (modules/users/trash-panda-v91-beta.nix).
{ __findFile, ... }:
{
  den.aspects.pmb = {
    description = "Personal MacBook - darwin host aspect";

    includes = [ <dots/bundle/platform> ];

    darwin.nixpkgs.hostPlatform = "aarch64-darwin";

    # Per-host user customisation (mutual provider routes this to the user's HM).
    # The outer `provides.<user>` is STATIC (no function wrapping); class
    # modules below take their own args. Wrapping the outer block with
    # `{ pkgs, ... }:` makes it parametric-dispatched on a non-entity arg
    # and silently skips the whole block.
    provides.trash-panda-v91-beta = {
      darwin =
        { pkgs, ... }:
        {
          users.users.trash-panda-v91-beta.shell = pkgs.nushell;
        };

      homeManager =
        { config, ... }:
        {
          programs.bun.enable = false;

          programs.ssh.settings."asc.internal" = {
            header = "Host asc.internal";
            User = "trash-panda-v91-beta";
            IdentityFile = "~/.ssh/trash-panda-v91-beta.pub";
            IdentitiesOnly = true;
            IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
          };

          home.sessionVariables.VAULTS_DIR = "${config.home.homeDirectory}/vaults";

          programs.obsidian.vaults.mist.target = "vaults/mist";

          programs.nixvim.plugins.obsidian.settings.workspaces = [
            {
              name = "mist";
              path = "~/vaults/mist";
            }
          ];
        };
    };
  };
}
