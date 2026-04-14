{ inputs, ... }:
{
  dots.darwin-system = {
    description = "macOS system-wide defaults (dock, keyboard, Touch ID)";

    darwin = {
      system.defaults = {
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
