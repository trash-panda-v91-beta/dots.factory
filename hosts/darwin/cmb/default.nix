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

  homeManagerUser = "I572068";

  myconfig =
    {
      myconfig,
      ...
    }:
    {
      user.name = "I572068";
      programs = {
        git.userEmail = myconfig.user.email;
        nixvim.plugins.neogit.gitService = inputs.vault.constants.corporate.gitService;
        nushell.enable = true;
      };
    };
}
