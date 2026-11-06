{ den, ... }:
{
  dots.tool._.security = {
    description = "1Password GUI, CLI, and SSH agent";
    includes = [
      (den._.unfree [
        "1password"
        "1password-cli"
      ])
    ];

    darwin = {
      homebrew.masApps."1Password For Safari" = 1569813296;
      programs._1password-gui.enable = true;
    };

    homeManager =
      { pkgs, config, ... }:
      {
        # The MAS 1Password for Safari extension shares its data dir with the
        # nix-pinned main app; a self-updated extension migrates the data and
        # the frozen app refuses to start. This App Store toggle keeps the
        # extension at the version the app pin was bumped to.
        home.activation.freezeAppStoreAutoUpdate = "/usr/bin/defaults write com.apple.commerce AutoUpdate -bool NO";

        home.packages = [ pkgs._1password-cli ];

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings."github.com" = {
            header = "Host github.com";
            User = "git";
            IdentityFile = "${config.home.homeDirectory}/.ssh/${config.home.username}.pub";
            IdentitiesOnly = true;
            IdentityAgent = ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"'';
          };
        };
      };
  };
}
