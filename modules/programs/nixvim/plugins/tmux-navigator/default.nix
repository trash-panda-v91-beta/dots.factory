{ delib, pkgs, ... }:
delib.module {
  name = "programs.nixvim.plugins.tmux-navigator";

  options =
    { myconfig, ... }:
    {
      programs.nixvim.plugins.tmux-navigator = with delib; {
        enable = boolOption myconfig.programs.tmux.enable;
      };
    };
  home.ifEnabled.programs = {
    tmux.plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
    ];
    nixvim.plugins.tmux-navigator = {
      enable = true;
    };
  };
}
