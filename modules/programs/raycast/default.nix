{
  delib,
  moduleSystem,
  pkgs,
  ...
}:
delib.module {
  name = "programs.raycast";

  options = delib.singleEnableOption (moduleSystem == "darwin");

  myconfig.ifEnabled.unfreePackages.allow = [ "raycast" ];

  home.ifEnabled =
    let
      scriptsFolder = "raycast/scripts";
    in
    {
      xdg.configFile = {
        "${scriptsFolder}/dismiss-notifications.js".source = scripts/dismiss-notifications.js;
        # "open-notifications.js".source = scripts/open-notifications.js;
        # "update-dots-factory.sh".source = scripts/update-dots-factory.sh;
      };
      home.packages = [ pkgs.raycast ];
    };
}
