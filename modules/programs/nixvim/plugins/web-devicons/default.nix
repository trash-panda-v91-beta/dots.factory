{
  delib,
  host,
  ...
}:
delib.module {
  name = "programs.nixvim.plugins.web-devicons";
  options = delib.singleEnableOption host.codingFeatured;

  home.ifEnabled = {
    programs.nixvim.plugins.web-devicons = {
      enable = true;
    };
  };
}
