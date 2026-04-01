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
      allSessions = defaultSessions ++ cfg.sessions;
      notesSession = lib.findFirst (s: s.name == "notes") null allSessions;
    in
    {
      home.sessionVariables = lib.mkIf (notesSession != null) {
        NOTES_PATH = notesSession.path;
      };
      programs = {
        ghostty.settings.command = "env PATH=\"${lib.concatStringsSep ":" myconfig.constants.path}:$PATH\" ${pkgs.lib.getExe pkgs.sesh} connect hack";
        sesh = {
          enable = true;

          enableAlias = false;
          enableTmuxIntegration = false;
          package = pkgs.sesh;
          settings = {
            cache = true;
            tmux_command = pkgs.lib.getExe pkgs.tmux;
            session = defaultSessions ++ cfg.sessions;
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
