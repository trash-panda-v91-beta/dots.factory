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
    nixvim = {
      plugins.tmux-navigator = {
        enable = true;
        settings.no_mappings = 1;
        keymaps = [
          {
            key = "<M-h>";
            action = "left";
          }
          {
            key = "<M-j>";
            action = "down";
          }
          {
            key = "<M-k>";
            action = "up";
          }
          {
            key = "<M-l>";
            action = "right";
          }
        ];
      };
    };
  };
}
