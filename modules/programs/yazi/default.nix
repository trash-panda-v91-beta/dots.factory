{
  delib,
  pkgs,
  lib,
  ...
}:
delib.module {
  name = "programs.yazi";

  options.programs.yazi = with delib; {
    enable = boolOption true;

    plugins = attrsOption { };
    extraPackages = listOfOption package [ ];
    extraInitLua = strOption "";
  };

  home.ifEnabled =
    { cfg, ... }:
    let
      # Read Lua from separate file and append user customizations
      initLua = builtins.readFile ./init.lua + cfg.extraInitLua;
    in
    {
      programs.yazi = {
        enable = true;

        # Enable shell integrations
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        enableZshIntegration = true;

        package = pkgs.yazi.override {
          extraPackages = cfg.extraPackages ++ [
            pkgs.jq
            pkgs._7zz
            pkgs.fd
            pkgs.ripgrep
            pkgs.fzf
            pkgs.zoxide
          ];
        };

        # Plugins - configured on Linux only
        plugins =
          cfg.plugins
          // (lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
            inherit (pkgs.yaziPlugins)
              chmod
              full-border
              git
              jump-to-char
              smart-enter
              smart-filter
              ;
          });

        # Use separate Lua file
        inherit initLua;
      };
    };
}
