{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs._1password";

  options.programs._1password = with delib; {
    enable = boolOption true;
    agentSocket = strOption "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  };

  myconfig.ifEnabled.unfreePackages.allow = [
    "1password"
    "1password-cli"
  ];

  darwin.ifEnabled = {
    homebrew = {
      masApps = {
        "1Password For Safari" = 1569813296;
      };
    };
    # INFO: Using Darwin package because 1Password GUI from Home Manager is not in /Applications
    programs._1password-gui = {
      enable = true;
    };
  };

  home.ifEnabled = {
    home.packages = [
      pkgs._1password-cli
    ];
  };
}
