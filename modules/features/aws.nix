{
  delib,
  host,
  ...
}:
delib.module {
  name = "features.aws";

  options = delib.singleEnableOption host.awsFeatured;

  myconfig.ifEnabled = {
    programs.awscli.enable = true;
  };
}
