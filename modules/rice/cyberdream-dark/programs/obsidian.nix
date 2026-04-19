{ ... }:
let
  riceDir = ./.;
in
{
  dots.rice-cyberdream-dark.homeManager = {
    programs.obsidian.defaultSettings = {
      appearance = {
        cssTheme = "Minimal";
        theme = "obsidian";
        accentColor = "#5ea1ff";
      };
      cssSnippets = [ (riceDir + "/obsidian-cyberdream.css") ];
    };
  };
}
