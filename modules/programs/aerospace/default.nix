{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.aerospace";

  options.programs.aerospace = with delib; {
    enable = boolOption true;
  };

  home.ifEnabled =
    { ... }:
    let
      aerospace = pkgs.lib.getExe pkgs.aerospace;
      tmux = pkgs.lib.getExe pkgs.tmux;
      notesScript = pkgs.writeShellScript "aerospace-notes" ''
        count=$(${aerospace} list-windows --workspace y --app-bundle-id com.mitchellh.ghostty --count)
        if [ "$count" = "0" ]; then
          /usr/bin/osascript -e "
            tell application \"Ghostty\"
              set cfg to new surface configuration
              set command of cfg to \"${tmux} new-session -As notes\"
              set title of cfg to \"notes\"
              new window with configuration cfg
            end tell"
        fi
      '';
    in
    {
      programs.aerospace = {
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
            ctrl-alt-cmd-shift-o = "workspace o";
            ctrl-alt-cmd-shift-y = [
              "exec-and-forget ${notesScript}"
              "workspace y"
            ];
            ctrl-alt-cmd-shift-g = "workspace-back-and-forth";
          };
          on-window-detected = [
            {
              "if" = {
                app-id = "com.mitchellh.ghostty";
                window-title-regex-substring = "notes";
              };
              run = [
                "move-node-to-workspace y"
              ];
            }
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
            {
              "if" = {
                app-id = "md.obsidian";
              };
              run = [
                "move-node-to-workspace o"
              ];
            }
          ];
        };
      };
    };
}
