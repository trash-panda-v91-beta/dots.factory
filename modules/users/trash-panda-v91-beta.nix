# trash-panda-v91-beta - personal user on PMB
#
# This file is a manifest of capabilities. To add software:
#   - new program        -> aspects/tool/<name>.nix, include here or in a bundle
#   - new workflow/stack -> aspects/bundle/<name>.nix, include here
#   - new theme          -> aspects/rice/<name>.nix, include here
{ __findFile, ... }:
{
  den.aspects.trash-panda-v91-beta = {
    description = "Personal user on PMB";

    includes = [
      <den/primary-user>

      # Look
      <dots/rice/cyberdream-dark>

      # Capability bundles
      <dots/bundle/dev>
      <dots/bundle/homelab>
      <dots/bundle/notes>
      <dots/bundle/desktop>
      <dots/bundle/security>
      <dots/bundle/browse>
    ];

    homeManager = {
      home.file.".ssh/trash-panda-v91-beta.pub".text =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8dDAhRO1eLXGEVLQYi/btYHQtrfWkemcJRIXYEhv/o";
      programs.git.settings.user.email = "42897550+trash-panda-v91-beta@users.noreply.github.com";
    };
  };
}
