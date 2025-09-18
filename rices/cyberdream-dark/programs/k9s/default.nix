{
  delib,
  ...
}:
delib.rice {
  name = "cyberdream-dark";
  home.programs.k9s = {
    skins = {
      cyberdream = ./skin.yaml;
    };
    settings = {
      k9s = {
        skin = "cyberdream";

      };
    };
  };

}
