{
  delib,
  ...
}:
delib.module {
  name = "programs.aerospace";

  options.programs.aerospace = with delib; {
    enable = boolOption true;
  };

  home.ifEnabled.programs.aerospace = {
    enable = true;
    launchd.enable = true;
    settings = {
      gaps = {
        outer.left = 20;
        outer.bottom = 20;
        outer.top = 20;
        outer.right = 20;
      };
      mode.main.binding = {
        ctrl-alt-cmd-shift-t = "workspace t";
        ctrl-alt-cmd-shift-b = "workspace b";
        ctrl-alt-cmd-shift-g = "workspace-back-and-forth";
      };
      on-window-detected = [
        {
          "if" = {
            app-id = "com.mitchellh.ghostty";
          };
          run = [
            "move-node-to-workspace t"
          ];
        }
        {
          "if" = {
            app-id = "com.apple.Safari";
          };
          run = [
            "move-node-to-workspace b"
          ];
        }
      ];
    };
  };
}
