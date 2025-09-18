{
  delib,
  host,
  ...
}:
delib.module {
  name = "programs.direnv";

  options = delib.singleEnableOption host.codingFeatured;

  home.ifEnabled = {
    programs.direnv = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
