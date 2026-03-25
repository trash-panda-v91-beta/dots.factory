{
  delib,
  homeconfig,
  ...
}:
delib.module {
  name = "programs.fnox";

  options.programs.fnox = with delib; {
    enable = boolOption true;
  };

  home.ifEnabled =
    { myconfig, ... }:
    let
      sshPrivateKey = "${homeconfig.home.homeDirectory}/.ssh/${myconfig.user.name}";
    in
    {
      home.sessionVariables = {
        FNOX_AGE_KEY_FILE = sshPrivateKey;
      };
    };
}
