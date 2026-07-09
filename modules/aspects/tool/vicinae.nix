{ inputs, ... }:
{
  dots.tool._.vicinae = {
    description = "Vicinae launcher";

    includes = [ { homeManager.imports = [ inputs.vicinae.homeManagerModules.default ]; } ];

    homeManager =
      { config, pkgs, ... }:
      {
        programs.vicinae = {
          enable = true;
          package = inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };

        launchd.agents.vicinae = {
          enable = true;
          config = {
            ProgramArguments = [ "${inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/vicinae" ];
            RunAtLoad = true;
            KeepAlive = true;
            StandardOutPath = "${config.home.homeDirectory}/Library/Logs/vicinae/vicinae.log";
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/vicinae/vicinae.log";
          };
        };
      };
  };
}
