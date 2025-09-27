{
  delib,
  lib,
  ...
}:
delib.module {
  name = "programs.nushell";
  options.programs.nushell = with delib; {
    enable = boolOption true;
  };

  home.ifEnabled =
    { cfg, myconfig, ... }:
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
          ${lib.concatMapStringsSep "\n" (p: "path add \"${p}\"") myconfig.constants.path}
        '';
      };
    };
}
