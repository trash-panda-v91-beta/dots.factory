{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.attic-client";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    home.packages = [ pkgs.attic-client ];
  };
}
