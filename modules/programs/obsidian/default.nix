{
  delib,
  lib,
  ...
}:
delib.module {
  name = "programs.obsidian";

  options.programs.obsidian = with delib; {
    enable = boolOption false;
    vaults = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              target = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Path to the vault relative to the user's HOME directory.";
              };
            };
          }
        )
      );
      default = { };
      description = "Obsidian vaults to configure, keyed by vault name.";
    };
  };

  myconfig.ifEnabled.unfreePackages.allow = [
    "obsidian"
  ];

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.obsidian = {
        enable = true;
        vaults = cfg.vaults;
      };
    };
}
