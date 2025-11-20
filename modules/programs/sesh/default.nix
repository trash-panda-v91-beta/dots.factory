{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.sesh";

  options.programs.sesh = with delib; {
    enable = boolOption true;

    sessions = listOfOption attrs [ ];
    windows = listOfOption attrs [ ];
  };

  home.ifEnabled =
    {
      cfg,
      myconfig,
      ...
    }:
    let
      defaultSessions = [
        {
          name = "hack";
          path = "~";
        }
      ];
      defaultWindows = [
        {
          name = "sidekick";
          startup_script = "opencode";
        }
      ];
    in
    {
      programs = {
        ghostty.settings.command = "env PATH=\"${lib.concatStringsSep ":" myconfig.constants.path}:$PATH\" ${pkgs.lib.getExe pkgs.sesh} connect hack";
        sesh = {
          enable = true;

          enableAlias = false;
          enableTmuxIntegration = false;
          settings = {
            session = defaultSessions ++ cfg.sessions;
            window = defaultWindows ++ cfg.windows;
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
