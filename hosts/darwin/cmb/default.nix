{
  delib,
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
        nushell.enable = true;
      };
    };
}
