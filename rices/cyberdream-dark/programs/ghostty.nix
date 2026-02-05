{
  delib,
  pkgs,
  ...
}:
delib.rice {
  name = "cyberdream-dark";
  home.home.packages = with pkgs; [
    victor-mono
  ];
  home.programs.ghostty = {
    settings = {
      background-opacity = 0.95;
      background-blur-radius = 30;
      font-family = "Victor Mono";
      theme = "cyberdream-dark";
    };
    themes = {
      "cyberdream-dark" = {
        palette = [
          "0=#16181a"
          "1=#ff6e5e"
          "2=#5eff6c"
          "3=#f1ff5e"
          "4=#5ea1ff"
          "5=#bd5eff"
          "6=#5ef1ff"
          "7=#ffffff"
          "8=#3c4048"
          "9=#ff6e5e"
          "10=#5eff6c"
          "11=#f1ff5e"
          "12=#5ea1ff"
          "13=#bd5eff"
          "14=#5ef1ff"
          "15=#ffffff"
        ];
        background = "#16181a";
        foreground = "#ffffff";
        cursor-color = "#ffffff";
        selection-background = "#3c4048";
        selection-foreground = "#ffffff";
      };
    };
  };
}
