{ delib, ... }:
delib.module {
  name = "programs.nixvim.plugins.obsidian";

  options.programs.nixvim.plugins.obsidian = with delib; {
    enable = boolOption true;
    workspaces = listOfOption attrs [ ];
  };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.nixvim = {
        plugins.obsidian = {
          enable = true;
          settings = {
            legacy_commands = false;
            workspaces = cfg.workspaces;
            ui.enable = false;
          };
        };
      };
    };
}
