{
  delib,
  ...
}:
delib.rice {
  name = "cyberdream-dark";
  home.programs.nixvim.colorschemes.cyberdream = {
    enable = true;
    settings = {
      borderless_picker = true;
      cache = true;
      hide_fillchars = true;
      italic_comments = true;
      terminal_colors = true;
      transparent = true;
      variant = "default";
    };
  };
}
