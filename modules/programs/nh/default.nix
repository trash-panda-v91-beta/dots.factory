{
  delib,
  ...
}:
delib.module {
  name = "programs.nh";

  options.programs.nh = with delib; {
    enable = boolOption true;
    clean = {
      enable = boolOption true;
      extraArgs = strOption "--keep-since 4d --keep 3";
    };
  };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.nh = {
        enable = cfg.enable;
        clean = {
          inherit (cfg.clean) enable extraArgs;
        };
      };
    };
}
