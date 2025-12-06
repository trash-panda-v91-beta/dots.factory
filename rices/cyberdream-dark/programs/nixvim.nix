{
  delib,
  ...
}:
delib.rice {
  name = "cyberdream-dark";
  home.programs.nixvim = {
    colorschemes.cyberdream = {
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

    highlight = {
      WhichKey = {
        fg = "#5ef1ff";
      };
      WhichKeyBorder = {
        fg = "#7b8496";
      };
      WhichKeyDesc = {
        fg = "#ffffff";
      };
      WhichKeyGroup = {
        fg = "#ff5ef1";
      };
      WhichKeyIcon = {
        fg = "#5ea1ff";
      };
      WhichKeyIconAzure = {
        fg = "#5ea1ff";
      };
      WhichKeyIconBlue = {
        fg = "#5ea1ff";
      };
      WhichKeyIconCyan = {
        fg = "#5ef1ff";
      };
      WhichKeyIconGreen = {
        fg = "#5eff6c";
      };
      WhichKeyIconGrey = {
        fg = "#7b8496";
      };
      WhichKeyIconOrange = {
        fg = "#ffbd5e";
      };
      WhichKeyIconPurple = {
        fg = "#bd5eff";
      };
      WhichKeyIconRed = {
        fg = "#ff6e5e";
      };
      WhichKeyIconYellow = {
        fg = "#f1ff5e";
      };
      WhichKeyNormal = {
        fg = "#ffffff";
        bg = "none";
      };
      WhichKeySeparator = {
        fg = "#7b8496";
      };
      WhichKeyTitle = {
        fg = "#5ef1ff";
        bold = true;
      };
      WhichKeyValue = {
        fg = "#7b8496";
      };
    };
  };
}
