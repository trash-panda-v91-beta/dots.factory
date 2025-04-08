{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.terminals.ghostty;
in
{
  options.modules.terminals.ghostty = {
    enable = lib.mkEnableOption "ghostty";
  };

  config = lib.mkIf cfg.enable {

    home = {
      sessionVariables = {
        TERM = "xterm-ghostty";
      };
    };
    xdg.configFile."ghostty/config".text = ''
      # cyberdream theme for ghostty
      palette = 0=#16181a
      palette = 1=#ff6e5e
      palette = 2=#5eff6c
      palette = 3=#f1ff5e
      palette = 4=#5ea1ff
      palette = 5=#bd5eff
      palette = 6=#5ef1ff
      palette = 7=#ffffff
      palette = 8=#3c4048
      palette = 9=#ff6e5e
      palette = 10=#5eff6c
      palette = 11=#f1ff5e
      palette = 12=#5ea1ff
      palette = 13=#bd5eff
      palette = 14=#5ef1ff
      palette = 15=#ffffff
      background = #16181a
      foreground = #ffffff
      cursor-color = #ffffff
      selection-background = #3c4048
      selection-foreground = #ffffff

      custom-shader = ${./shader.glsl}

      background-opacity = 0.90
      background-blur-radius = 20

      adjust-cell-height = 30%
      command = ${pkgs.fish}/bin/fish -c "${pkgs.tmux}/bin/tmux new -A -s hack"
      copy-on-select = true
      cursor-style = block
      font-family = "JetBrains Mono"
      font-size = 15
      font-thicken = true
      mouse-hide-while-typing = true
      macos-non-native-fullscreen=false
      macos-option-as-alt = true
      macos-titlebar-proxy-icon = hidden
      title = " "
      shell-integration = fish
      shell-integration-features = no-title
      macos-titlebar-style = hidden
      window-padding-y = 0,0
      window-padding-x = 20
      window-padding-color = extend
      window-padding-balance = true
      window-save-state = always
      quit-after-last-window-closed = true

      # To delete from the current position to the start of the line
      keybind = super+backspace=esc:w

      # Go to the N window in tmux in tmux it is Ctrl+b+number
      keybind = super+one=text:\x02\x31
      keybind = super+two=text:\x02\x32
      keybind = super+three=text:\x02\x33
      keybind = super+four=text:\x02\x34
      keybind = super+five=text:\x02\x35
      keybind = super+six=text:\x02\x36
      keybind = super+seven=text:\x02\x37
      keybind = super+eight=text:\x02\x38
      keybind = super+nine=text:\x02\x39

      # Close tmux pane on Cmd+w in tmux it is Ctrl+b+x (it is using a custom keybind in tmux to kill the pane)
      keybind = super+w=text:\x02\x78

      # Switch a tmux session on Cmd+o in tmux it is Ctrl+b+w
      keybind = super+o=text:\x02\x77

      # Rename a tmux window on Cmd+r in tmux it is Ctrl+b+,
      keybind = super+r=text:\x02\x2c

      # Go to the previous tmux window on Cmd+h in tmux it is Ctrl+b+p
      keybind = super+h=text:\x02\x70

      # Go to the last tmux session on Cmd+l in tmux it is Ctrl+b+n
      keybind = super+l=text:\x02\x6e

      # Split the window horizontally on Cmd+minus in tmux it is Ctrl+b+" (For me it is horizontal split but in tmux it is considered vertical split)
      keybind = super+minus=text:\x02\x22

      # Split the window vertically on Cmd+backslash in tmux it is Ctrl+b+% (For me it is vertical split but in tmux it is considered horizontal split)
      keybind = super+backslash=text:\x02\x25

      # Toggle pane zoom on Cmd+z in tmux it is Ctrl+b+z
      keybind = super+z=text:\x02\x7a

      # Map super+c to alt+c
      keybind = super+c=text:\x1bc

      # Map super+i to alt+i
      keybind = super+i=text:\x1bi

      # Map super+s to alt+s
      keybind = super+s=text:\x1bs

      # Map super+t to alt+t
      keybind = super+t=text:\x1bt

      # Ignore new window shortcut
      keybind = super+n=ignore
    '';
  };
}
