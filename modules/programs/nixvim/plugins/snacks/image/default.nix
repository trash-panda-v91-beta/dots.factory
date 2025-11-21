{ delib, pkgs, ... }:
delib.module {
  name = "programs.nixvim.plugins.snacks.image";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    home.packages = with pkgs; [
      imagemagick
      ghostscript
      typst
      tectonic
    ];

    programs.nixvim.plugins.snacks.settings.image = {
      enabled = true;
      doc = {
        enabled = true;
        inline = true;
        float = true;
        max_width = 100;
        max_height = 50;
      };
    };
  };
}
