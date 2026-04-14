{ den, ... }:
{
  dots.security = {
    description = "1Password GUI, CLI, and SSH agent";
    includes = [ (den._.unfree [ "1password" "1password-cli" ]) ];

    darwin = {
      homebrew.masApps."1Password For Safari" = 1569813296;
      programs._1password-gui.enable = true;
    };

    homeManager =
      { pkgs, config, ... }:
      {
        home.packages = [ pkgs._1password-cli ];

        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks."github.com" = {
            user = "git";
            identityFile = "${config.home.homeDirectory}/.ssh/${config.home.username}.pub";
            identitiesOnly = true;
            extraOptions.IdentityAgent = "'~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock'";
          };
        };
      };
  };
}
