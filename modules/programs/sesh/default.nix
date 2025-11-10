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
                name = "asc";
                path = "~";
                startup_command = "ssh asc.internal";
              }
              {
                name = "dots";
                path = "~/repos/personal/dots.factory";
                startup_command = "nvim";
              }
              {
                name = "dots (sidekick)";
                path = "~/repos/personal/dots.factory";
                startup_command = "opencode";
              }
              {
                name = "nebular grid";
                path = "~/repos/personal/nebular-grid";
                startup_command = "nvim";
              }
              {
                name = "nebular grid (sidekick)";
                path = "~/repos/personal/nebular-grid";
                startup_command = "opencode";
              }
              {
                name = "notes";
                path = "~/notes";
                startup_command = "nvim";
              }
              {
                name = "notes (sidekick)";
                path = "~/notes";
                startup_command = "sidekick";
              }
              {
                name = "hack";
                path = "~";
              }
              {
                name = "psb";
                path = "~/repos/personal/nebular-grid";
                startup_command = "k9s";
              }
              {
                name = "sidekick";
                path = "~";
                startup_command = "opencode";
              }
            ];
          };
        };
        tmux.extraConfig = ''
          bind -n M-p run-shell "sesh last"
          bind -n M-s run-shell "sesh connect $(sesh list -i | fzf --ansi --tmux bottom,70%,40% --style minimal)"

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
