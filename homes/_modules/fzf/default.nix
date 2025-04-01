{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.fzf;
in
{
  options.modules.fzf = {
    enable = lib.mkEnableOption "fzf";
  };
  config = lib.mkIf cfg.enable {
    programs = {
      fzf.enable = true;
      tmux = {
        plugins = with pkgs.tmuxPlugins; [
          {
            plugin = tmux-fzf;
            extraConfig = ''
              TMUX_FZF_ORDER="session|window|pane|command|keybinding"
              TMUX_FZF_OPTIONS="-p -w 90% -h 70% -m"
              bind w run-shell -b "${pkgs.tmuxPlugins.tmux-fzf}/tmux-plugins/tmux-fzf/scripts/window.sh switch"
            '';
          }
        ];
      };
      fish = {
        plugins = [
          {
            name = "fzf-fish";
            inherit (pkgs.fishPlugins.fzf-fish) src;
          }
        ];
      };
    };
  };
}
