{
  delib,
  ...
}:
delib.module {
  name = "programs.ssh";
  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
    };
  };
}
