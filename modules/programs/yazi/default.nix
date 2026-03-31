{
  delib,
  ...
}:
delib.module {
  name = "programs.yazi";

  options.programs.yazi = with delib; {
    enable = boolOption false;
  };

  home.ifEnabled = {
    programs.yazi = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };
  };
}
