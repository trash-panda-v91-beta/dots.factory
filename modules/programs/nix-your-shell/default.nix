{
  delib,
  ...
}:
delib.module {
  name = "programs.nix-your-shell";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.nix-your-shell = {
      enable = true;
      enableNushellIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
  };
}
