{
  delib,
  host,
  ...
}:
delib.module {
  name = "programs.direnv";

  options = delib.singleEnableOption host.codingFeatured;

  home.ifEnabled = {
    programs.direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
    programs.git.ignores = [
      ".direnv"
      ".envrc"
    ];
  };
}
