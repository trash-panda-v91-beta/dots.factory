{ delib, ... }:
delib.module {
  name = "programs.opencode";

  rice.ifEnabled = {
    home.programs.opencode.settings.theme = ./cyberdream.json;
  };
}

