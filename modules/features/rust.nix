{
  delib,
  host,
  ...
}:
delib.module {
  name = "features.rust";

  options = delib.singleEnableOption host.rustFeatured;

  myconfig.ifEnabled = {
    programs.cargo.enable = true;
  };
}
