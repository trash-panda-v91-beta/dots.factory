{ inputs, ... }:
{
  dots.platform._.darwin-system = {
    description = "macOS system-wide defaults (dock, keyboard, Touch ID)";

    darwin = {
      system.defaults = {
        CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys = {
          # Disable Cmd+Space (Spotlight search) - freed for Vicinae
          "64".enabled = false;
          # Disable Cmd+Alt+Space (Finder search window)
          "65".enabled = false;
        };
        dock = {
          autohide = true;
          orientation = "bottom";
          showhidden = true;
          tilesize = 50;
        };
        NSGlobalDomain = {
          InitialKeyRepeat = 20;
          KeyRepeat = 1;
        };
      };
      security.pam.services.sudo_local = {
        enable = true;
        reattach = true;
        touchIdAuth = true;
        watchIdAuth = true;
      };
    };
  };
}
