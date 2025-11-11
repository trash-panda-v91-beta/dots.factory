{ delib, host, ... }:
delib.module {
  name = "programs.git";
  options =
    { myconfig, ... }:
    {
      programs.git = with delib; {
        enable = boolOption host.codingFeatured;
        enableLFS = boolOption true;
        username = strOption myconfig.user.name;
        userEmail = strOption myconfig.user.email;
        userSigningKey = allowNull (strOption null);
      };
    };

  home.ifEnabled =
    { cfg, ... }:
    {
      programs.delta.enable = true;
      programs.git = {
        enable = cfg.enable;
        ignores = [
          ".DS_Store"
          ".venv"
          "Thumbs.db"
        ];
        lfs.enable = cfg.enableLFS;
        settings = {
          core.autocrlf = "input";
          core.editor = "nvim";
          diff.algorithm = "histogram";
          fetch.prune = true;
          help.autocorrect = 10;
          init.defaultBranch = "main";
          merge.conflictStyle = "zdiff3";
          pull.rebase = true;
          push.autoSetupRemote = true;
          rebase.autoStash = true;
          user = {
            name = cfg.username;
            email = cfg.userEmail;
          };
        };
        signing.key = cfg.userSigningKey;
      };
    };
}
