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
        set -as terminal-overrides ',*:RGB'  # RGB color support
        set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # Undercurl support for LSP
        set -as terminal-overrides ',*:Setulc=\E[58::2::::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # Underscore colors

        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on
        set-option -g detach-on-destroy off  # Switch to another session instead of detaching
        set -sg escape-time 0

        bind -n M-x kill-pane

        # Smart pane switching with awareness of Vim splits (Alt+hjkl)
        # See: https://github.com/christoomey/vim-tmux-navigator
        vim_pattern='(\\S+/)?g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?'
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +''${vim_pattern}$'"
        bind-key -n 'M-h' if-shell "$is_vim" 'send-keys M-h'  'select-pane -L'
        bind-key -n 'M-j' if-shell "$is_vim" 'send-keys M-j'  'select-pane -D'
        bind-key -n 'M-k' if-shell "$is_vim" 'send-keys M-k'  'select-pane -U'
        bind-key -n 'M-l' if-shell "$is_vim" 'send-keys M-l'  'select-pane -R'

        bind-key -T copy-mode-vi 'M-h' select-pane -L
        bind-key -T copy-mode-vi 'M-j' select-pane -D
        bind-key -T copy-mode-vi 'M-k' select-pane -U
        bind-key -T copy-mode-vi 'M-l' select-pane -R

        # Pane resizing (Alt+Arrow keys)
        bind -n M-Left resize-pane -L 5
        bind -n M-Right resize-pane -R 5
        bind -n M-Up resize-pane -U 5
        bind -n M-Down resize-pane -D 5

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
