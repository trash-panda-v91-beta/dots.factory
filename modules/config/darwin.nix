{
  delib,
  inputs,
  ...
}:

delib.module {
  name = "homebrew";

  options.homebrew = with delib.options; {
    enable = boolOption true;
    brews = listOfOption str [ ];
    casks = listOfOption str [ ];
    masApps = attrsOfOption int { };
    taps = listOfOption str [ ];
  };

  darwin.always.imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
  ];

  darwin.ifEnabled =
    {
      cfg,
      myconfig,
      ...
    }:
    let
      nixHomebrewTaps = {
        "homebrew/homebrew-core" = inputs.homebrew-core;
        "homebrew/homebrew-cask" = inputs.homebrew-cask;
      };
    in
    {
      nix-homebrew = {
        enable = true;
        mutableTaps = false;
        user = myconfig.user.name;
        taps = nixHomebrewTaps;
      };
      homebrew = {
        enable = true;
        inherit (cfg)
          brews
          casks
          masApps
          ;
        onActivation = {
          cleanup = "zap";
          autoUpdate = false;
          upgrade = true;
        };
        taps = cfg.taps ++ (builtins.attrNames nixHomebrewTaps);
      };
      system = {
        defaults = {
          dock = {
            autohide = true;
            orientation = "bottom";
            showhidden = true;
            tilesize = 50;
          };
          NSGlobalDomain = {
            InitialKeyRepeat = 20;
            KeyRepeat = 1;
          };
        };
        primaryUser = myconfig.user.name;
      };
      security.pam.services.sudo_local = {
        enable = true;
        reattach = true;
        touchIdAuth = true;
        watchIdAuth = true;
      };

    };
}
