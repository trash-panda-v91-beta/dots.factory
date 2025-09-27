{
  delib,
  ...
}:
delib.module {
  name = "programs.opencode";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.opencode = {
      enable = true;
    };
  };
}
