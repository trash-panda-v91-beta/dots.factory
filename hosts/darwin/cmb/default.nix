{
  delib,
  inputs,
  ...
}:
delib.host {
  name = "cmb";

  features = [
    "coding"
    "githubCopilot"
    "python"
  ];
  rice = "cyberdream-dark";
  type = "desktop";

  homeManagerUser = inputs.vault.constants.profiles.corporate;

  myconfig =
    {
      myconfig,
      ...
    }:
    {
      user.name = inputs.vault.constants.profiles.corporate;
      programs = {
        colima.enable = true;
        git.userEmail = myconfig.user.email;
        nixvim.plugins.obsidian = {
          enable = true;
          workspaces = [
            {
              name = "notes";
              path = "~/notes";
            }
          ];
        };
        nixvim.plugins.neogit.gitService = inputs.vault.constants.services.git.corporate;
        nushell.enable = true;
      };
    };
}
