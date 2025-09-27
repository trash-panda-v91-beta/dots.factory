{ delib, ... }:
delib.module {
  name = "constants";

  options =
    { myconfig, ... }:
    {
      constants = with delib; {
        path = listOfOption str [
          "/run/current-system/sw/bin"
          "/opt/homebrew/bin"
          "/opt/homebrew/sbin"
          "/Users/${myconfig.user.name}/.nix-profile/bin"
          "/run/current-system/sw/bin"
          "/nix/var/nix/profiles/default/bin"
          "/usr/local/bin"
          "/usr/bin"
          "/bin"
          "/usr/sbin"
          "/sbin"
          "/etc/profiles/per-user/${myconfig.user.name}/bin"
        ];
      };
    };
}
