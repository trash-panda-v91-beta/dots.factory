{ delib, host, ... }:
delib.module {
  name = "programs.k9s";
  options.programs.k9s = with delib; {
    enable = boolOption host.kubernetesFeatured;
  };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.k9s = {
        enable = cfg.enable;
      };
    };
}
