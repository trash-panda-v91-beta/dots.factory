{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.yazi";

  # This module provides additional configuration
  # The fileManager module handles enabling it
  options = delib.singleEnableOption false;

  home.ifEnabled.programs.nixvim.plugins.yazi = {
    # Additional yazi-specific configuration
    settings = {
      # Add any yazi-specific settings here
    };
  };
}
