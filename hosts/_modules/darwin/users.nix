{
  lib,
  pkgs,
  users,
  ...
}:
{
  users.users = lib.foldl' (
    acc: user:
    acc
    // {
      "${user}" = {
        name = user;
        home = "/Users/${user}";
        shell = pkgs.fish;
      };
    }
  ) { } users;
  system.activationScripts.postActivation.text = ''
    # Must match what is in /etc/shells
    ${lib.concatStringsSep "\n" (
      map (user: ''
        sudo chsh -s /run/current-system/sw/bin/fish ${user}
      '') users
    )}
  '';
}
