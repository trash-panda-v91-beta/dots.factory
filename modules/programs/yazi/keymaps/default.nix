{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.yazi.keymaps";

  options.programs.yazi.keymaps = with delib; {
    base = listOfOption attrs [ ];
    custom = listOfOption attrs [ ];
  };

  home.always =
    { myconfig, ... }:
    let
      cfg = myconfig.programs.yazi;

      # Calculate final plugins (same as main module)
      finalPlugins =
        cfg.plugins
        // (lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          inherit (pkgs.yaziPlugins)
            chmod
            full-border
            git
            jump-to-char
            smart-enter
            smart-filter
            ;
        });

      # Helper to create keymaps that depend on plugins
      pluginKeymap = plugin: keymaps: lib.optionals (lib.hasAttr plugin finalPlugins) keymaps;

      # Base keymaps (always included)
      baseKeymaps = [
        {
          on = [ "<Esc>" ];
          run = "close";
          desc = "Close the current tab; if it's the last tab, exit the process instead.";
        }
        {
          on = [ "<C-n>" ];
          run = "tab_create --current";
          desc = "Create a new tab with CWD.";
        }
      ];

      # Plugin-conditional keymaps
      smartEnterKeymaps = pluginKeymap "smart-enter" [
        {
          on = [ "l" ];
          run = "plugin smart-enter";
          desc = "Enter the child directory, or open the file";
        }
        {
          on = [ "<Right>" ];
          run = "plugin smart-enter";
          desc = "Enter the child directory, or open the file";
        }
      ];

      chmodKeymaps = pluginKeymap "chmod" [
        {
          on = [
            "c"
            "m"
          ];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
      ];

      jumpToCharKeymaps = pluginKeymap "jump-to-char" [
        {
          on = [ "f" ];
          run = "plugin jump-to-char";
          desc = "Jump to char";
        }
      ];

      smartFilterKeymaps = pluginKeymap "smart-filter" [
        {
          on = [ "F" ];
          run = "plugin smart-filter";
          desc = "Smart filter";
        }
      ];

      # Concatenate all keymaps
      defaultKeymaps =
        baseKeymaps ++ smartEnterKeymaps ++ chmodKeymaps ++ jumpToCharKeymaps ++ smartFilterKeymaps;
    in
    {
      programs.yazi.keymap.mgr.prepend_keymap = defaultKeymaps ++ cfg.keymaps.custom;
    };
}
