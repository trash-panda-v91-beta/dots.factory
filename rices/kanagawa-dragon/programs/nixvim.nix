{
  delib,
  ...
}:
delib.rice {
  name = "kanagawa-dragon";
  home.programs.nixvim = {
    colorschemes.kanagawa = {
      enable = true;
      settings = {
        theme = "dragon";
        background = {
          dark = "dragon";
        };
      };
    };
  };
}
