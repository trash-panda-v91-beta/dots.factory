{
  delib,
  host,
  ...
}:
delib.module {
  name = "programs.lazygit";
  options.programs.lazygit = with delib; {
    enable = boolOption host.codingFeatured;
    services = attrsOption { };
  };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.lazygit = {
        enable = cfg.enable;
        settings = {
          customCommands = [
            {
              key = "o";
              command = "gh pr view {{.SelectedLocalBranch.Name}} --web || gh pr create {{.SelectedLocalBranch.Name}} --web";
              context = "remoteBranches";
            }
          ];
          gui = {
            border = "rounded";
            nerdFontsVersion = 3;
            showIcons = true;
          };
          keybinding = {
            commits = {
              moveDownCommit = "J";
              moveUpCommit = "K";
            };
          };
          services = cfg.services;
        };
      };
    };
}
