{ delib, ... }:
delib.module {
  name = "programs.sol";

  options = delib.singleEnableOption false;

  darwin.ifEnabled.homebrew.casks = [ "sol" ];
}
