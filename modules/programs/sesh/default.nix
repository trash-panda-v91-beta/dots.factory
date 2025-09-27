{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.sesh";

  options = delib.singleEnableOption true;

  home.ifEnabled =
    { myconfig, ... }:
    {
      programs = {
        ghostty.settings.command = "env PATH=\"${lib.concatStringsSep ":" myconfig.constants.path}:$PATH\" ${pkgs.lib.getExe pkgs.sesh} connect hack";
        sesh = {
          enable = true;

          enableAlias = false;
          enableTmuxIntegration = false;
          settings = {
            default_session = {
              preview_command = "";
            };
            session = [
              {
                name = "k9s";
                path = "~";
                startup_command = "k9s";
              }
              {
                name = "hack";
                path = "~";
              }
              {
                name = "dots";
                path = "~/repos/personal/dots.factory/";
                startup_command = "nvim";
              }
            ];
          };
        };
        tmux.extraConfig = ''
          bind -n M-p run-shell "sesh last"
          bind -n M-s run-shell "sesh connect $(sesh list -i | fzf --ansi --tmux bottom,20%,30% --style minimal)"

          set -g detach-on-destroy off
        '';
        fzf = {
          tmux.enableShellIntegration = true;
          enable = true;
        };
        zoxide = {
          enable = true;
          enableNushellIntegration = true;
        };
      };
    };

}
