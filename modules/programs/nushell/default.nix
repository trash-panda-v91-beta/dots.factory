{
  delib,
  ...
}:
delib.module {
  name = "programs.nushell";
  options.programs.nushell = with delib; {
    enable = boolOption true;
  };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.nushell = {
        enable = cfg.enable;
        settings = {
          show_banner = false;
        };
        shellAliases = {
          nu-open = "open";
          open = "^open";
        };

        # TODO: replace with home.sessionPath once available
        # https://github.com/nix-community/home-manager/pull/6941
        extraLogin = ''
          use std/util "path add"
          path add "/run/current-system/sw/bin"
          path add "/opt/homebrew/bin"
          path add $"/etc/profiles/per-user/($env.USER)/bin"
        '';
      };
    };
}
