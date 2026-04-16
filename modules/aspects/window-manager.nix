{ lib, ... }:
{
  dots.window-manager =
    { user, ... }:
    {
      description = "AeroSpace tiling window manager with workspace routing";

      homeManager =
        { pkgs, ... }:
        let
          aerospace = lib.getExe pkgs.aerospace;
          sesh = lib.getExe pkgs.sesh;
          mkNotesScript =
            session: workspace:
            pkgs.writeShellScript "aerospace-notes-${session}" ''
              export PATH="${pkgs.tmux}/bin:${pkgs.sesh}/bin:$PATH"
              count=$(${aerospace} list-windows --workspace ${workspace} --app-bundle-id com.mitchellh.ghostty --count)
              if [ "$count" = "0" ]; then
                before=$(${aerospace} list-windows --all --app-bundle-id com.mitchellh.ghostty --json \
                  | /usr/bin/jq -r '.[]["window-id"]')
                /usr/bin/osascript -e "
                  tell application \"Ghostty\"
                    set cfg to new surface configuration
                    set command of cfg to \"env PATH=${pkgs.tmux}/bin:${pkgs.sesh}/bin:\$PATH ${sesh} connect ${session}\"
                    new window with configuration cfg
                  end tell"
                for i in $(seq 1 20); do
                  sleep 0.2
                  after=$(${aerospace} list-windows --all --app-bundle-id com.mitchellh.ghostty --json \
                    | /usr/bin/jq -r '.[]["window-id"]')
                  new_id=$(comm -13 <(echo "$before" | sort) <(echo "$after" | sort) | head -1)
                  if [ -n "$new_id" ]; then
                    focused=$(${aerospace} list-workspaces --focused)
                    if [ "$focused" = "${workspace}" ]; then
                      ${aerospace} move-node-to-workspace --window-id "$new_id" ${workspace}
                    fi
                    break
                  fi
                done
              else
                ${sesh} connect ${session}
              fi
            '';
          nilScript = mkNotesScript "nil" "n";
          mistScript = mkNotesScript "mist" "m";
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
                ctrl-alt-cmd-shift-b = [
                  "exec-and-forget /usr/bin/open -a \"Zen Browser\""
                  "workspace b"
                ];
                ctrl-alt-cmd-shift-o = [
                  "exec-and-forget /usr/bin/open -a Obsidian"
                  "workspace o"
                ];
                ctrl-alt-cmd-shift-n = [
                  "exec-and-forget ${nilScript}"
                  "workspace n"
                ];
                ctrl-alt-cmd-shift-m = [
                  "exec-and-forget ${mistScript}"
                  "workspace m"
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
                  "exec-and-forget /usr/bin/open -a \"Zen Browser\""
                  "workspace b"
                  "mode main"
                ];
                o = [
                  "exec-and-forget /usr/bin/open -a Obsidian"
                  "workspace o"
                  "mode main"
                ];
                n = [
                  "exec-and-forget ${nilScript}"
                  "workspace n"
                  "mode main"
                ];
                m = [
                  "exec-and-forget ${mistScript}"
                  "workspace m"
                  "mode main"
                ];
                c = [
                  "exec-and-forget /usr/bin/open -a Slack"
                  "workspace c"
                  "mode main"
                ];
                i = [
                  "exec-and-forget /usr/bin/open -a Mail"
                  "workspace i"
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
                  "if".app-id = "com.1password.1password";
                  run = [ "layout floating" ];
                }
                {
                  "if".app-id = "com.okta.mobile";
                  run = [ "layout floating" ];
                }
                {
                  "if" = {
                    app-id = "com.mitchellh.ghostty";
                    workspace = "n";
                  };
                  run = [ ];
                }
                {
                  "if" = {
                    app-id = "com.mitchellh.ghostty";
                    workspace = "m";
                  };
                  run = [ ];
                }
                {
                  "if".app-id = "com.mitchellh.ghostty";
                  run = [ "move-node-to-workspace t" ];
                }
                {
                  "if".app-id = "app.zen-browser.zen";
                  run = [ "move-node-to-workspace b" ];
                }
                {
                  "if".app-id = "com.apple.Safari";
                  run = [ "move-node-to-workspace b" ];
                }
                {
                  "if".app-id = "md.obsidian";
                  run = [ "move-node-to-workspace o" ];
                }
                {
                  "if".app-id = "com.tinyspeck.slackmacgap";
                  run = [ "move-node-to-workspace c" ];
                }
                {
                  "if".app-id = "com.microsoft.teams2";
                  run = [ "move-node-to-workspace c" ];
                }
                {
                  "if".app-id = "com.apple.mail";
                  run = [ "move-node-to-workspace i" ];
                }
                {
                  "if".app-id = "com.apple.finder";
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
    };
}
