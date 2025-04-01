{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.shell.tmux;
  toggleTmuxPane = pkgs.writeShellApplication {
    name = "toggle-tmux-pane";
    bashOptions = [ ];
    runtimeInputs = with pkgs; [
      tmux
    ];
    text = builtins.readFile ./toggle-tmux-pane.sh;
  };
in
{
  options.modules.shell.tmux = {
    enable = lib.mkEnableOption "tmux";
    package = lib.mkPackageOption pkgs "tmux" { };
  };
  config = lib.mkIf cfg.enable {
    programs.tmux = {
      baseIndex = 1;
      enable = true;
      inherit (cfg) package;
      mouse = true;
      keyMode = "vi";
      sensibleOnTop = false;
      shell = "${pkgs.fish}/bin/fish";
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = resurrect;
          extraConfig = ''
            # Save and restore session
            set -g @resurrect-save 'S'
            set -g @resurrect-restore 'R'

            set -g @resurrect-strategy-nvim 'session'
          '';
        }
        vim-tmux-navigator
        continuum
      ];
      extraConfig = ''
        # Set terminal colors
        set -g default-terminal "tmux-256color"
        set -as terminal-overrides ',xterm*:sitm=\E[3m'

        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on
        set -sg escape-time 0

        # kill pane
        bind-key x kill-pane

        # Pane resizing
        bind -n M-h resize-pane -L
        bind -n M-l resize-pane -R
        bind -n M-k resize-pane -U
        bind -n M-j resize-pane -D

        # Use visual selection mode as vi
        bind-key -T copy-mode-vi v send-keys -X begin-selection
        bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        bind-key -n M-t run-shell "${toggleTmuxPane}/bin/toggle-tmux-pane"
        bind-key -T copy-mode M-t run-shell "${toggleTmuxPane}/bin/toggle-tmux-pane"
        bind-key -T copy-mode-vi M-t run-shell "${toggleTmuxPane}/bin/toggle-tmux-pane"
        bind-key -T copy-mode Escape send-keys -X cancel
        bind-key -T copy-mode-vi Escape send-keys -X cancel

        set-option -g focus-events on

        set -gu default-command
        set -g default-shell "$SHELL"
      '';
    };
  };
}
