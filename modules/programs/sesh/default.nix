{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.sesh";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs = {
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
          ];
        };
      };
      tmux.extraConfig = ''
        bind-key "w" run-shell "${pkgs.lib.getExe pkgs.sesh} connect \"$(
          ${pkgs.lib.getExe pkgs.sesh} list --icons --hide-duplicates | fzf-tmux -p 80%,50% --no-border \
            --ansi \
            --list-border \
            --no-sort --prompt '⚡  ' \
            --color 'list-border:6,input-border:3,preview-border:4,header-bg:-1,header-border:6' \
            --input-border \
            --header-border \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-b:abort' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(${pkgs.lib.getExe pkgs.sesh} list --icons)' \
            --bind 'ctrl-t:change-prompt(  )+reload(${pkgs.lib.getExe pkgs.sesh} list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(${pkgs.lib.getExe pkgs.sesh} list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(${pkgs.lib.getExe pkgs.sesh} list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(${pkgs.lib.getExe pkgs.sesh} list --icons)' \
            --preview-window 'right:70%' \
            --preview '${pkgs.lib.getExe pkgs.sesh} preview {}' \
        )\""

        set -g detach-on-destroy off

        bind -N "last-session (via sesh) " n run-shell "sesh last"
        bind -N "switch to root session (via sesh) " 9 run-shell "sesh connect --root \'$(pwd)\'"
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
