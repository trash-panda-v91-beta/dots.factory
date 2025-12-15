{
  delib,
  ...
}:
delib.module {
  name = "programs.bun";

  options = delib.singleEnableOption false;

  home.ifEnabled = {
    programs.bun = {
      enable = true;
      enableGitIntegration = true;
      settings = {
        # You can add bunfig.toml settings here
        # See: https://bun.sh/docs/runtime/bunfig
      };
    };
  };
}
