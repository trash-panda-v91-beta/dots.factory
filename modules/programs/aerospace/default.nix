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
    { myconfig, ... }:
    let
      aerospace = "/etc/profiles/per-user/${myconfig.user.name}/bin/aerospace";
      sesh = "/etc/profiles/per-user/${myconfig.user.name}/bin/sesh";
      notesScript = pkgs.writeShellScript "aerospace-notes" ''
        count=$(${aerospace} list-windows --workspace y --app-bundle-id com.mitchellh.ghostty --count)
        if [ "$count" = "0" ]; then
          /usr/bin/open -na Ghostty.app --args -e ${sesh} connect notes
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
