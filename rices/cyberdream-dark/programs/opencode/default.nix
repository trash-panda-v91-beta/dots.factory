{ delib, ... }:
delib.rice {
  name = "cyberdream-dark";
  home = {
    programs.opencode = {
      themes = {
        cyberdream = ./cyberdream.json;
      };
      settings.theme = "cyberdream";
    };
  };
}
