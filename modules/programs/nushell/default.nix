{
  delib,
  homeconfig,
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
          edit_mode = "vi";
          cursor_shape = {
            vi_insert = "line";
            vi_normal = "block";
          };
        };
        shellAliases = {
          nu-open = "open";
          open = "^open";
        };

        environmentVariables = homeconfig.home.sessionVariables // {
          PROMPT_INDICATOR_VI_INSERT = lib.mkForce "";
          PROMPT_INDICATOR_VI_NORMAL = lib.mkForce "";
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
