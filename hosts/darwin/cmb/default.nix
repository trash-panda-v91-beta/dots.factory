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

  homeManagerUser = "CORPORATE_USER";

  myconfig =
    {
      myconfig,
      ...
    }:
    {
      user.name = "CORPORATE_USER";
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
        nixvim.plugins.neogit.gitService = inputs.vault.constants.corporate.gitService;
        nushell.enable = true;
      };
    };
}
