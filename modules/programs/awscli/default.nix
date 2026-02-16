{
  delib,
  host,
  ...
}:
delib.module {
  name = "programs.awscli";

  options = delib.singleEnableOption host.awsFeatured;

  home.ifEnabled = {
    programs.awscli.enable = true;
  };
}
