{
  delib,
  host,
  pkgs,
  ...
}:
delib.module {
  name = "programs.talosctl";

  options = delib.singleEnableOption host.kubernetesFeatured;

  home.ifEnabled = {
    home.packages = [ pkgs.talosctl ];
  };
}
