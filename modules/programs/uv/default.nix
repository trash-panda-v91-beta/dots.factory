{
  delib,
  ...
}:
delib.module {
  name = "programs.uv";

  options = delib.singleEnableOption false;

  home.ifEnabled = {
    programs.uv = {
      enable = true;
    };
  };
}
