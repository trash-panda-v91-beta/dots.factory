{
  delib,
  host,
  pkgs,
  ...
}:
delib.module {
  name = "programs.just";

  options = delib.singleEnableOption host.codingFeatured;

  home.ifEnabled = {
    home.packages = with pkgs; [ just ];
  };
}
