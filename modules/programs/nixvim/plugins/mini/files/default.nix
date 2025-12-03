{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.mini.files";

  # This module now only provides additional configuration
  # The fileManager module handles enabling it
  options = delib.singleEnableOption false;

  home.ifEnabled.programs.nixvim.plugins.mini.modules.files = {
    # Additional user-configurable options can go here
    # The fileManager module sets the defaults
  };
}
