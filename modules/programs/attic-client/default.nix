{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.attic-client";

  options = delib.singleEnableOption false;

  home.ifEnabled = {
    home.packages = [ pkgs.attic-client ];
  };
}
