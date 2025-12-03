{
  delib,
  ...
}:
delib.module {
  name = "programs.cargo";

  options = delib.singleEnableOption false;

  home.ifEnabled = {
    programs.cargo = {
      enable = true;
    };
  };
}
