# trash-panda-v91-beta — personal user on PMB
{
  pkgs,
  __findFile,
  ...
}:
{
  den.aspects.trash-panda-v91-beta = {
    description = "Personal user on PMB";

    includes = [
      <den/primary-user>
      # Rice
      <dots/rice-cyberdream-dark>
      # Concern aspects
      <dots/terminal>
      <dots/nixvim>
      <dots/ai>
      <dots/dev-tools>
      <dots/security>
      <dots/window-manager>
      <dots/zen-browser>
      <dots/obsidian>
      <dots/git>
      <dots/runtimes>
      <dots/k8s>
    ];

    homeManager = {
      home.file.".ssh/trash-panda-v91-beta.pub".text =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8dDAhRO1eLXGEVLQYi/btYHQtrfWkemcJRIXYEhv/o";
      programs.git.settings.user.email = "42897550+trash-panda-v91-beta@users.noreply.github.com";
    };

    # den._.user-shell doesn't support nushell on darwin (no programs.nushell option),
    # so we set the login shell manually via mutual provider.
    provides.pmb =
      { pkgs, ... }:
      {
        darwin.users.users.trash-panda-v91-beta.shell = pkgs.nushell;
      };
  };
}
