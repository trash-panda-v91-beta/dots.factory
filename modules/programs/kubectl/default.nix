{
  delib,
  host,
  pkgs,
  ...
}:
delib.module {
  name = "programs.kubectl";

  options = delib.singleEnableOption host.kubernetesFeatured;

  home.ifEnabled = {
    home.packages = [ pkgs.kubectl ];
  };
}
