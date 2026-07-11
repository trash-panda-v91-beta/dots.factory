{ lib, ... }:
{
  dots.tool._.window-manager = {
    description = "AeroSpace tiling window manager with workspace routing";

    homeManager =
      { pkgs, ... }:
      let
        aerospace = lib.getExe pkgs.aerospace;
        herdr = lib.getExe pkgs.herdr;
        # Real macOS $HOME is resolved at runtime: the HM username is a public
        # pseudonym, so config.home.homeDirectory points at the wrong path.
        vaultsSubdir = "SAPDevelop/vaults";

        # Attaches to the vault's herdr session, ensuring it has a workspace
        # rooted at the vault dir first (herdr attach ignores process cwd, so
        # the workspace must be created explicitly).
        mkHerdrLauncher =
          session:
          pkgs.writeShellScript "herdr-vault-${session}" ''
            vault="$HOME/${vaultsSubdir}/${session}"
            # workspace list only exposes id + label (no cwd), so match on the
            # label we set to avoid piling up duplicate workspaces per launch.
            if ! ${herdr} --session ${session} workspace list 2>/dev/null \
                 | /usr/bin/jq -e '.result.workspaces[] | select(.label == "${session}")' >/dev/null 2>&1; then
              ${herdr} --session ${session} workspace create --cwd "$vault" --label ${session} --no-focus >/dev/null 2>&1 || true
            fi
            exec ${herdr} --session ${session}
          '';

        # Opens a vault workspace with two accordion-tiled windows: Obsidian
        # pointed at the vault, and a Ghostty running herdr in the vault dir.
        # Obsidian is routed by title (the vault name is stable in its title);
        # Ghostty is routed by captured window-id (its title is just the cwd,
        # so title matching is not reliable for it).
        mkNotesScript =
          session: workspace:
          pkgs.writeShellScript "aerospace-notes-${session}" ''
            export PATH="${pkgs.herdr}/bin:$PATH"

            ghostty_ids() {
              ${aerospace} list-windows --monitor all --app-bundle-id com.mitchellh.ghostty --json \
                | /usr/bin/jq -r '.[]["window-id"]'
            }

            move_obsidian_by_title() {
              ${aerospace} list-windows --monitor all --app-bundle-id md.obsidian --json \
                | /usr/bin/jq -r --arg m "- ${session} - Obsidian" '.[] | select(.["window-title"] | contains($m)) | .["window-id"]' \
                | while read -r wid; do
                    [ -n "$wid" ] && ${aerospace} move-node-to-workspace --window-id "$wid" ${workspace}
                  done
            }

            # Obsidian: open the vault if it isn't already placed, then route by title.
            if [ "$(${aerospace} list-windows --workspace ${workspace} --app-bundle-id md.obsidian --count)" = "0" ]; then
              /usr/bin/open "obsidian://open?vault=${session}"
              for _ in $(seq 1 25); do
                sleep 0.2
                move_obsidian_by_title
                [ "$(${aerospace} list-windows --workspace ${workspace} --app-bundle-id md.obsidian --count)" != "0" ] && break
              done
            fi

            # Ghostty: spawn a new window and place it by captured window-id.
            if [ "$(${aerospace} list-windows --workspace ${workspace} --app-bundle-id com.mitchellh.ghostty --count)" = "0" ]; then
              before=$(ghostty_ids)
              /usr/bin/osascript -e "
                tell application \"Ghostty\"
                  set cfg to new surface configuration
                  set command of cfg to \"${mkHerdrLauncher session}\"
                  new window with configuration cfg
                end tell"
              for _ in $(seq 1 25); do
                sleep 0.2
                new_id=$(comm -13 <(echo "$before" | sort) <(ghostty_ids | sort) | head -1)
                if [ -n "$new_id" ]; then
                  ${aerospace} move-node-to-workspace --window-id "$new_id" ${workspace}
                  break
                fi
              done
            fi

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
                  app-id = "md.obsidian";
                  window-title-regex-substring = "- mist - Obsidian";
                };
                run = [ "move-node-to-workspace m" ];
              }
              {
                "if" = {
                  app-id = "md.obsidian";
                  window-title-regex-substring = "- nil - Obsidian";
                };
                run = [ "move-node-to-workspace n" ];
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
