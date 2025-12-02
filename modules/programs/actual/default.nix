{ delib, ... }:
delib.module {
  name = "programs.actual";

  options = delib.singleEnableOption false;

  darwin.ifEnabled.homebrew.casks = [ "actual" ];
}
