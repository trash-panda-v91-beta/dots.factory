{
  delib,
  moduleSystem,
  ...
}:
delib.module {
  name = "services.raycast";

  options = delib.singleEnableOption (moduleSystem == "darwin");

  myconfig.ifEnabled.programs.raycast.enable = true;

  darwin.ifEnabled = {
    launchd.user.agents.raycast = {
      command = ''"/Applications/Nix Apps/Raycast.app/Contents/MacOS/Raycast"'';
      serviceConfig.RunAtLoad = true;
    };
  };
}
