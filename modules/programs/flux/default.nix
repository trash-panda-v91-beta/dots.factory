{
  delib,
  host,
  pkgs,
  ...
}:
delib.module {
  name = "programs.flux";

  options = delib.singleEnableOption host.kubernetesFeatured;

  home.ifEnabled = {
    home.packages = [ pkgs.fluxcd ];
  };
}
