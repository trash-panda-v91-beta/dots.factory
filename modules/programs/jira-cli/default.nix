{
  delib,
  host,
  pkgs,
  ...
}:
delib.module {
  name = "programs.jira-cli";
  options.programs.jira-cli.enable = delib.boolOption host.codingFeatured;

  home.ifEnabled = {
    home.packages = [ pkgs.jira-cli-go ];
  };
}
