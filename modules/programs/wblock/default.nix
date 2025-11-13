{
  delib,
  ...
}:
delib.module {
  name = "programs.wblock";

  options.programs.wblock = with delib; {
    enable = boolOption true;
  };

  darwin.ifEnabled = {
    homebrew = {
      masApps = {
        "wBlock" = 6746388723;
      };
    };
  };
}
