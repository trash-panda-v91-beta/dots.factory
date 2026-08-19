{ ... }:
{
  dots.tool._.window-manager = {
    description = "AeroSpace tiling window manager with workspace routing";

    homeManager =
      { pkgs, config, lib, ... }:
      let
        # vault-workspace is in home.packages so ~/.nix-profile/bin/vault-workspace
        # is a stable path. Embedding the store path directly causes the toml to
        # change on every build, triggering reload-config and reshuffling windows.
        vaultWorkspace = "${config.home.homeDirectory}/.nix-profile/bin/vault-workspace";
      in
      {
        home.packages = [ pkgs.local.vault-workspace ];

        # Re-apply workspace routing after every activation. Obsidian reloads its
        # plugins whenever the home-manager-files derivation changes (any input bump
        # re-symlinks .obsidian/*.json), which opens new windows in the current
        # workspace instead of their assigned one. run-callback corrects this.
        home.activation.aerospaceRouteWindows = lib.hm.dag.entryAfter [ "onFilesChange" ] ''
          if $DRY_RUN_CMD ${lib.getExe config.programs.aerospace.package} \
              list-modes --current >/dev/null 2>&1; then
            $DRY_RUN_CMD ${lib.getExe config.programs.aerospace.package} \
              run-callback --for-every-window on-window-detected 2>/dev/null || true
          fi
        '';

        programs.aerospace = {
          enable = true;
          launchd.enable = true;
          settings = {
            config-version = 2;

            persistent-workspaces = [ "t" "b" "m" "c" "w" "h" ];

            enable-normalization-flatten-containers = true;
            enable-normalization-opposite-orientation-for-nested-containers = true;
            automatically-unhide-macos-hidden-apps = true;
            on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

            gaps = {
              inner.horizontal = 8;
              inner.vertical = 8;
              outer = { left = 20; right = 20; top = 20; bottom = 20; };
            };

            mode.main.binding = {
              ctrl-alt-cmd-shift-t   = "workspace t";
              ctrl-alt-cmd-shift-b   = [ "exec-and-forget /usr/bin/open -a \"Zen Browser\"" "workspace b" ];
              ctrl-alt-cmd-shift-m   = [ "exec-and-forget ${vaultWorkspace} mist m" "workspace m" ];
              ctrl-alt-cmd-shift-c   = [ "exec-and-forget /usr/bin/open -a Slack" "workspace c" ];
              ctrl-alt-cmd-shift-w   = [ "exec-and-forget /usr/bin/open -a \"Microsoft Teams\"" "workspace w" ];
              ctrl-alt-cmd-shift-tab = "focus-back-and-forth";
              ctrl-alt-cmd-shift-i   = "focus dfs-next --wrap-around";
              ctrl-alt-cmd-shift-g   = "workspace-back-and-forth";
              ctrl-alt-cmd-shift-p   = "mode launcher";
              ctrl-alt-cmd-shift-s   = "mode service";
            };

            mode.service.binding = {
              esc       = [ "reload-config" "mode main" ];
              r         = [ "flatten-workspace-tree" "mode main" ];
              f         = [ "layout floating tiling" "mode main" ];
              backspace = [ "close-all-windows-but-current" "mode main" ];
              alt-shift-h = [ "join-with left"  "mode main" ];
              alt-shift-j = [ "join-with down"  "mode main" ];
              alt-shift-k = [ "join-with up"    "mode main" ];
              alt-shift-l = [ "join-with right" "mode main" ];
            };

            mode.launcher.binding = {
              t   = [ "workspace t" "mode main" ];
              b   = [ "exec-and-forget /usr/bin/open -a \"Zen Browser\"" "workspace b" "mode main" ];
              m   = [ "exec-and-forget ${vaultWorkspace} mist m" "workspace m" "mode main" ];
              c   = [ "exec-and-forget /usr/bin/open -a Slack" "workspace c" "mode main" ];
              w   = [ "exec-and-forget /usr/bin/open -a \"Microsoft Teams\"" "workspace w" "mode main" ];
              h   = [ "workspace h" "mode main" ];
              esc = "mode main";
              ctrl-alt-cmd-shift-p = "mode main";
            };

            # INFO: "if" must be a string (test expression), not an attrset.
            # The home-manager TOML serializer renders attrset "if" as a subtable
            # header [on-window-detected.if], which breaks the array-of-tables
            # structure (run ends up nested inside if). String values are safe.
            on-window-detected = [
              {
                "if" = "test %{app-bundle-id} = com.1password.1password";
                run = [ "layout floating" ];
              }
              {
                "if" = "test %{app-bundle-id} = com.okta.mobile";
                run = [ "layout floating" ];
              }
              {
                "if" = "test %{app-bundle-id} = md.obsidian";
                run = [ "move-node-to-workspace m" ];
              }
              {
                # Guard: ghostty opened by vault-workspace in m stays in m.
                "if" = "test %{app-bundle-id} = com.mitchellh.ghostty && test %{workspace} = m";
                run = [ ];
              }
              {
                "if" = "test %{app-bundle-id} = com.mitchellh.ghostty";
                run = [ "move-node-to-workspace t" ];
              }
              {
                "if" = "test %{app-bundle-id} = app.zen-browser.zen";
                run = [ "move-node-to-workspace b" ];
              }
              {
                "if" = "test %{app-bundle-id} = com.apple.Safari";
                run = [ "move-node-to-workspace b" ];
              }
              {
                "if" = "test %{app-bundle-id} = com.tinyspeck.slackmacgap";
                run = [ "move-node-to-workspace c" ];
              }
              {
                "if" = "test %{app-bundle-id} = com.microsoft.teams2";
                run = [ "move-node-to-workspace w" ];
              }
            ];
          };
        };
      };
  };
}
