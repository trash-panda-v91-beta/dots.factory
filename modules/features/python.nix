{
  delib,
  host,
  ...
}:
delib.module {
  name = "features.python";

  options = delib.singleEnableOption host.pythonFeatured;

  myconfig.ifEnabled = {
    programs.uv.enable = true;
  };
}
