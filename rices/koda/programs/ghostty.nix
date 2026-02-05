{
  delib,
  pkgs,
  ...
}:
delib.rice {
  name = "koda";
  home.packages = with pkgs; [
    _0xproto
  ];
  home.programs.ghostty = {
    settings = {
      font-family = "0xProto";
      theme = "koda";
    };
    themes = {
      koda = {
        palette = [
          "0=#101010"
          "1=#ff7676"
          "2=#a3d6a3"
          "3=#ffffff"
          "4=#b3b3b3"
          "5=#f4b8e4"
          "6=#fafafa"
          "7=#b0b0b0"
          "8=#666666"
          "9=#ff5733"
          "10=#86cd82"
          "11=#d9ba73"
          "12=#ffffff"
          "13=#f2a4db"
          "14=#5abfb5"
          "15=#b5bfe2"
        ];
        background = "#101010";
        foreground = "#ffffff";
        cursor-color = "#b0b0b0";
        cursor-text = "#101010";
        selection-background = "#272727";
        selection-foreground = "#b0b0b0";
        bold-is-bright = true;
      };
    };
  };
}
