{ lib, ... }:
{
  dots.tool._.window-manager = {
    description = "AeroSpace tiling window manager with workspace routing";

    homeManager =
      { pkgs, ... }:
      let
        aerospace = lib.getExe pkgs.aerospace;
        herdr = lib.getExe pkgs.herdr;

        # Opens a vault workspace with two accordion-tiled windows: Obsidian
        # pointed at the vault, and a Ghostty running herdr in the vault dir.
        # Each app is placed by captured window-id (Obsidian sets its title
        # after the window appears, so title-based routing races - id is exact).
        mkNotesScript =
          session: workspace:
          pkgs.writeShellScript "aerospace-notes-${session}" ''
            export PATH="${pkgs.herdr}/bin:$PATH"

            place_new_window() {
              # $1 = app-bundle-id, $2 = command that spawns the window
              local bid="$1" spawn="$2" before after new_id
              if [ "$(${aerospace} list-windows --workspace ${workspace} --app-bundle-id "$bid" --count)" != "0" ]; then
                return
              fi
              before=$(${aerospace} list-windows --all --app-bundle-id "$bid" --json | /usr/bin/jq -r '.[]["window-id"]')
              eval "$spawn"
              for _ in $(seq 1 25); do
                sleep 0.2
                after=$(${aerospace} list-windows --all --app-bundle-id "$bid" --json | /usr/bin/jq -r '.[]["window-id"]')
                new_id=$(comm -13 <(echo "$before" | sort) <(echo "$after" | sort) | head -1)
                if [ -n "$new_id" ]; then
                  ${aerospace} move-node-to-workspace --window-id "$new_id" ${workspace}
                  break
                fi
              done
            }

            place_new_window md.obsidian \
              "/usr/bin/open 'obsidian://open?vault=${session}'"

            place_new_window com.mitchellh.ghostty \
              "/usr/bin/osascript -e 'tell application \"Ghostty\" to (new window with configuration (new surface configuration with properties {command:\"sh -c '\"'\"'cd ~/vaults/${session} 2>/dev/null; exec ${herdr} --session ${session}'\"'\"'\"}))'"

            ${aerospace} layout --workspace ${workspace} accordion 2>/dev/null || true
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
              ctrl-alt-cmd-shift-n = [
                "exec-and-forget ${nilScript}"
                "workspace n"
              ];
              ctrl-alt-cmd-shift-m = [
                "exec-and-forget ${mistScript}"
                "workspace m"
              ];
              ctrl-alt-cmd-shift-c = [
                "exec-and-forget /usr/bin/open -a Slack"
                "workspace c"
              ];
              ctrl-alt-cmd-shift-w = [
                "exec-and-forget /usr/bin/open -a \"Microsoft Teams\""
                "workspace w"
              ];
              ctrl-alt-cmd-shift-tab = "focus-back-and-forth";
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
              w = [
                "exec-and-forget /usr/bin/open -a \"Microsoft Teams\""
                "workspace w"
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
                "if".app-id = "com.tinyspeck.slackmacgap";
                run = [ "move-node-to-workspace c" ];
              }
              {
                "if".app-id = "com.microsoft.teams2";
                run = [ "move-node-to-workspace w" ];
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
