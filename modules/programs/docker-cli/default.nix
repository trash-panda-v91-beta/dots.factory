{
  delib,
  host,
  ...
}:
delib.module {
  name = "programs.docker-cli";

  options = {
    programs.docker-cli = with delib; {
      enable = boolOption host.codingFeatured;
    };
  };

  home.ifEnabled = {
    programs.docker-cli = {
      enable = true;
    };
  };
}
