{ delib, ... }:
delib.rice {
  name = "cyberdream-dark";
  home = {
    programs.opencode.settings.theme = "cyberdream";
    xdg.configFile."opencode/themes/cyberdream.json".source = ./cyberdream.json;
  };
}
