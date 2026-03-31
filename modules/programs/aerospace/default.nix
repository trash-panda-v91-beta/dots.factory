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
          before=$(${aerospace} list-windows --workspace t --app-bundle-id com.mitchellh.ghostty --json \
            | /usr/bin/jq -r '.[]["window-id"]')
          /usr/bin/osascript -e "
            tell application \"Ghostty\"
              set cfg to new surface configuration
              set command of cfg to \"${tmux} new-session -As notes\"
              new window with configuration cfg
            end tell"
          for i in $(seq 1 20); do
            sleep 0.2
            after=$(${aerospace} list-windows --workspace t --app-bundle-id com.mitchellh.ghostty --json \
              | /usr/bin/jq -r '.[]["window-id"]')
            new_id=$(comm -13 <(echo "$before" | sort) <(echo "$after" | sort) | head -1)
            if [ -n "$new_id" ]; then
              focused=$(${aerospace} list-workspaces --focused)
              if [ "$focused" = "y" ]; then
                ${aerospace} move-node-to-workspace --window-id "$new_id" y
              fi
              break
            fi
          done
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
            ctrl-alt-cmd-shift-o = [
              "exec-and-forget /usr/bin/open -a Obsidian"
              "workspace o"
            ];
            ctrl-alt-cmd-shift-y = [
              "exec-and-forget ${notesScript}"
              "workspace y"
            ];
            ctrl-alt-cmd-shift-g = "workspace-back-and-forth";
            ctrl-alt-cmd-shift-p = "mode launcher";
          };
          mode.launcher.binding = {
            t = [
              "workspace t"
              "mode main"
            ];
            b = [
              "workspace b"
              "mode main"
            ];
            o = [
              "exec-and-forget /usr/bin/open -a Obsidian"
              "workspace o"
              "mode main"
            ];
            y = [
              "exec-and-forget ${notesScript}"
              "workspace y"
              "mode main"
            ];
            m = [
              "exec-and-forget /usr/bin/open -a Mail"
              "workspace m"
              "mode main"
            ];
            f = [
              "exec-and-forget /usr/bin/open -a \"Actual Budget\""
              "workspace f"
              "mode main"
            ];
            e = [
              "exec-and-forget /usr/bin/open -a Finder"
              "workspace e"
              "mode main"
            ];
            h = [
              "workspace h"
              "mode main"
            ];
            esc = "mode main";
            ctrl-alt-cmd-shift-p = "mode main";
          };
          on-window-detected = [
            {
              "if" = {
                app-id = "com.mitchellh.ghostty";
                workspace = "y";
              };
              run = [ ];
            }
            {
              "if" = {
                app-id = "com.mitchellh.ghostty";
              };
              run = [ "move-node-to-workspace t" ];
            }
            {
              "if" = {
                app-id = "com.apple.Safari";
              };
              run = [ "move-node-to-workspace b" ];
            }
            {
              "if" = {
                app-id = "md.obsidian";
              };
              run = [ "move-node-to-workspace o" ];
            }
            {
              "if" = {
                app-id = "com.apple.mail";
              };
              run = [ "move-node-to-workspace m" ];
            }
            {
              "if" = {
                app-id = "com.apple.finder";
              };
              run = [ "move-node-to-workspace e" ];
            }
            {
              "if" = { };
              run = [ "move-node-to-workspace h" ];
            }
          ];
        };
      };
    };
}
