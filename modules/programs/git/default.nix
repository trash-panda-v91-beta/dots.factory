{
  delib,
  host,
  ...
}:
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

      programs.git = {
        enable = cfg.enable;
        delta.enable = true;
        extraConfig = {
          commit.verbose = true;
          core.autocrlf = "input";
          diff.algorithm = "histogram";
          fetch.prune = true;
          help.autocorrect = 10;
          init.defaultBranch = "main";
          merge.conflictStyle = "zdiff3";
          pull.rebase = true;
          push.autoSetupRemote = true;
          rebase.autoStash = true;
        };
        ignores = [
          ".DS_Store"
          ".venv"
          "Thumbs.db"
        ];
        lfs.enable = cfg.enableLFS;
        userName = cfg.username;
        userEmail = cfg.userEmail;
        signing.key = cfg.userSigningKey;
      };
    };
}
