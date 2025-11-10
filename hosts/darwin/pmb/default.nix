{
  delib,
  ...
}:
delib.host {
  name = "pmb";

  features = [
    "coding"
    "githubCopilot"
    "kubernetes"
    "python"
  ];
  rice = "cyberdream-dark";
  type = "desktop";

  myconfig = {
    user = {
      name = "trash-panda-v91-beta";
      ssh.matchBlocks = [
        {
          name = "asc.internal";
          user = "trash-panda-v91-beta";
        }
      ];
    };

    programs = {
      git.userEmail = "42897550+trash-panda-v91-beta@users.noreply.github.com";
      nushell.enable = true;
    };
  };
}
