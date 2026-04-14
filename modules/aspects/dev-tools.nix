{ lib, ... }:
{
  dots.dev-tools =
    { user, ... }:
    {
      description = "Development workflow: direnv, mise, docker, colima, nh";

      homeManager =
        { pkgs, ... }:
        {
          programs.direnv = {
            enable = true;
            enableNushellIntegration = true;
            nix-direnv.enable = true;
          };

          programs.mise = {
            enable = true;
            enableNushellIntegration = true;
            globalConfig.settings = {
              env_cache = true;
              env_cache_ttl = "8h";
            };
          };

          programs.docker-cli.enable = true;

          home.packages = with pkgs; [
            attic-client
            colima
            docker
          ];
          launchd.agents.colima-default = lib.mkIf pkgs.stdenv.isDarwin {
            enable = true;
            config = {
              ProgramArguments = [
                "${lib.getExe pkgs.colima}"
                "start"
                "default"
                "-f"
                "--activate=true"
                "--save-config=false"
              ];
              KeepAlive = true;
              RunAtLoad = true;
              EnvironmentVariables.PATH = lib.makeBinPath [
                pkgs.colima
                pkgs.perl
                pkgs.docker
                pkgs.openssh
                pkgs.coreutils
                pkgs.curl
                pkgs.bashInteractive
                pkgs.darwin.DarwinTools
              ];
              StandardOutPath = "/tmp/colima-default.log";
              StandardErrorPath = "/tmp/colima-default.log";
            };
          };

          programs.nh = {
            enable = true;
            clean = {
              enable = true;
              extraArgs = "--keep-since 4d --keep 3";
            };
          };
        };
    };
}
