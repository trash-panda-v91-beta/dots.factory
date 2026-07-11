{ ... }:
{
  dots.tool._.window-manager = {
    description = "AeroSpace tiling window manager with workspace routing";

    homeManager =
      { pkgs, ... }:
      let
        # Shared launcher (pkgs.local.vault-workspace): opens Obsidian + a
        # herdr terminal accordion-tiled in the given aerospace workspace.
        # dots.corpo reuses the same binary for the nil vault.
        vaultWorkspace = "${pkgs.local.vault-workspace}/bin/vault-workspace";
        mistWorkspace = "${vaultWorkspace} mist m";
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
              ctrl-alt-cmd-shift-m = [
                "exec-and-forget ${mistWorkspace}"
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
              m = [
                "exec-and-forget ${mistWorkspace}"
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
