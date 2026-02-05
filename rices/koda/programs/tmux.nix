{
  delib,
  pkgs,
  ...
}:
delib.rice {
  name = "koda";
  home.programs.tmux.plugins = with pkgs.tmuxPlugins; [
    {
      plugin = catppuccin;
      extraConfig = ''
        set -g @catppuccin_flavor 'cyberdream'
        set -g @catppuccin_status_background "none"
        set -g @catppuccin_window_status_style "none"
        set -g @catppuccin_pane_status_enabled "off"
        set -g @catppuccin_pane_border_status "off"
      '';
    }
  ];

  home.programs.tmux.extraConfig = ''
    # Cyberdream colors (defined explicitly for immediate availability)
    set -g @cyberdream_cyan "#5ef1ff"
    set -g @cyberdream_red "#ff6e5e"
    set -g @cyberdream_yellow "#f1ff5e"
    set -g @cyberdream_green "#5eff6c"
    set -g @cyberdream_grey "#7b8496"
    set -g @cyberdream_overlay "#3c4048"
    set -g @cyberdream_bg "#16181a"
    set -g @cyberdream_peach "#ffbd5e"

    # Status bar configuration
    set -g status-position top
    set -g status-style "bg=default"
    set -g status-justify "absolute-centre"

    # Status left: mode symbol + session + directory (always show) + zoom indicator
    set -g status-left-length 100
    set -g status-left ""
    # Mode symbol (priority: prefix > copy mode > normal)
    set -ga status-left "#{?client_prefix,#[fg=#{@cyberdream_red}]#[bold]○ #[nobold],#{?pane_in_mode,#[fg=#{@cyberdream_yellow}]#[bold]▼ #[nobold],#[fg=#{@cyberdream_cyan}]#[bold]◎ #[nobold]}}"
    # Session name (yellow)
    set -ga status-left "#[fg=#{@cyberdream_yellow}]#[bold]#S#[nobold]"
    # Directory - always show if different from session
    set -ga status-left "#{?#{!=:#{b:pane_current_path},#S}, #[fg=#{@cyberdream_overlay}]│ #[fg=#{@cyberdream_grey}]#{b:pane_current_path},}"
    # Zoom indicator (conditional, after directory)
    set -ga status-left "#[fg=#{@cyberdream_red}]#{?window_zoomed_flag,  ▪,}"

    # Status right: conditional windows (only show if more than one)
    set -g status-right-length 60
    set -g status-right "#{?#{>:#{session_windows},1},#W,}"

    # Pane borders
    setw -g pane-border-format ""
    setw -g pane-active-border-style "bg=#{@cyberdream_bg},fg=#{@cyberdream_overlay}"
    setw -g pane-border-style "bg=#{@cyberdream_bg},fg=#{@cyberdream_overlay}"
    setw -g pane-border-lines single

    # Window status - minimal style with no backgrounds (only shown when multiple windows)
    set -g window-status-format "#{?#{>:#{session_windows},1},#I,}"
    set -g window-status-style "fg=#{@cyberdream_grey}"
    set -g window-status-last-style "fg=#{@cyberdream_grey}"
    set -g window-status-activity-style "fg=#{@cyberdream_red}"
    set -g window-status-bell-style "fg=#{@cyberdream_red}"
    set -g window-status-separator " #[fg=#{@cyberdream_overlay}]│ "
    set -g window-status-current-format "#{?#{>:#{session_windows},1},#I,}"
    set -g window-status-current-style "fg=#{@cyberdream_cyan}"
  '';

}
