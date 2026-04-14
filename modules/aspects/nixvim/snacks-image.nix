{ dots, ... }:
{
  dots.nixvim.includes = [ dots.nixvim._."snacks-image" ];
  dots.nixvim._."snacks-image".homeManager = { pkgs, ... }: {
  programs.nixvim = {
    extraPackages = with pkgs; [
      imagemagick
      ghostscript
      typst
      tectonic
    ];

    plugins.snacks.settings.image = {
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
  };
}
