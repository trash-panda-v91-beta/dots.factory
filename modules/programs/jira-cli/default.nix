{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.jira-cli";
  options.programs.jira-cli.enable = delib.boolOption false;

  home.ifEnabled = {
    home.packages = [ pkgs.jira-cli-go ];
  };
}
