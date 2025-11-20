{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.tmux";
  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.tmux = {
      enable = true;
      baseIndex = 1;
      mouse = true;
      keyMode = "vi";
      sensibleOnTop = false;
      shell = pkgs.lib.getExe pkgs.nushell;
      plugins = with pkgs.tmuxPlugins; [
        continuum
      ];
      extraConfig = ''
        # Set terminal colors
        set -g default-terminal "tmux-256color"
        set -as terminal-overrides ',xterm*:sitm=\E[3m'

        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on
        set -sg escape-time 0

        bind -n M-x kill-pane

        # Pane resizing
        bind -n M-h resize-pane -L
        bind -n M-l resize-pane -R
        bind -n M-k resize-pane -U
        bind -n M-j resize-pane -D

        # Enter copy mode
        bind -n M-v copy-mode 

        # Use visual selection mode as vi
        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

        bind -n M-t run-shell "${pkgs.lib.getExe pkgs.local.tmux-pane-toggler}"
        bind -T copy-mode M-t run-shell "${pkgs.lib.getExe pkgs.local.tmux-pane-toggler}"
        bind -T copy-mode-vi M-t run-shell "${pkgs.lib.getExe pkgs.local.tmux-pane-toggler}"
        bind -T copy-mode-vi M-t run-shell "${pkgs.lib.getExe pkgs.local.tmux-pane-toggler}"
        bind -T copy-mode Escape send-keys -X cancel
        bind -T copy-mode-vi Escape send-keys -X cancel

        bind -n M-w last-window

        set-option -g focus-events on
        set -gu default-command
      '';
    };
  };

}
