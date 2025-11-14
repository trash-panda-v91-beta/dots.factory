{ delib, host, ... }:
delib.module {
  name = "programs.gh";
  options.programs.gh = with delib; {
    enable = boolOption host.codingFeatured;
    extensions = listOption [ ];
  };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.gh = {
        enable = cfg.enable;
        extensions = cfg.extensions;
      };
    };
}
