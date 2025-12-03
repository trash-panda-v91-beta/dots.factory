# TODO: Switch to upstream Home Manager module when PR #7913 is merged
# https://github.com/nix-community/home-manager/pull/7913
{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.colima";

  options.programs.colima = with delib; {
    enable = boolOption false;

    profiles = lib.mkOption {
      default = {
        default = {
          isActive = true;
          isService = true;
        };
      };
      description = ''
        Profiles allow multiple colima configurations. The default profile is active by default.
        If you have used colima before, you may need to delete existing configuration using `colima delete` or use a different profile.

        Note that removing a configured profile will not delete the corresponding Colima instance.
        You will need to manually run `colima delete <profile-name>` to remove the instance and release resources.
      '';
      example = lib.literalExpression ''
        {
          default = {
            isActive = true;
            isService = true;
          };
          rosetta = {
            isService = true;
            settings.rosetta = true;
          };
          powerful = {
            settings.cpu = 8;
          };
        }
      '';
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                default = name;
                readOnly = true;
                description = "The profile's name.";
              };

              isService = lib.mkOption {
                type = lib.types.bool;
                default = false;
                example = true;
                description = ''
                  Whether this profile will run as a service.
                '';
              };

              isActive = lib.mkOption {
                type = lib.types.bool;
                default = false;
                example = true;
                description = ''
                  Whether to set this profile as:
                  - active docker context
                  - active kubernetes context
                  - active incus remote
                  Exactly one or zero profiles should have this option set.
                '';
              };

              logFile = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
                description = "Combined stdout and stderr log file for the Colima service. Defaults to /tmp/colima-\${name}.log";
              };

              settings = lib.mkOption {
                type = lib.types.attrs;
                default = { };
                description = "Colima configuration settings, see <https://github.com/abiosoft/colima/blob/main/embedded/defaults/colima.yaml> or run `colima template`.";
                example = lib.literalExpression ''
                  {
                    cpu = 2;
                    disk = 100;
                    memory = 2;
                    arch = "host";
                    runtime = "docker";
                  }
                '';
              };
            };
          }
        )
      );
    };
  };

  home.ifEnabled =
    { cfg, ... }:
    let
      yamlFormat = pkgs.formats.yaml { };
      colimaPackage = pkgs.colima;
      dockerPackage = pkgs.docker;
      perlPackage = pkgs.perl;
      sshPackage = pkgs.openssh;
      coreutilsPackage = pkgs.coreutils;
      curlPackage = pkgs.curl;
      bashPackage = pkgs.bashInteractive;

      activeProfile = lib.findFirst (p: p.isActive) null (lib.attrValues cfg.profiles);

      # Process profiles to add default logFile paths
      processedProfiles = lib.mapAttrs (
        name: profile:
        profile
        // {
          logFile = if profile.logFile != null then profile.logFile else "/tmp/colima-${name}.log";
        }
      ) cfg.profiles;
    in
    {
      home.packages = [
        colimaPackage
        dockerPackage # Docker CLI client for colima
      ];

      assertions = [
        {
          assertion = (lib.count (p: p.isActive) (lib.attrValues cfg.profiles)) <= 1;
          message = "Only one Colima profile can be active at a time.";
        }
      ];

      home.file = lib.mkMerge (
        lib.mapAttrsToList (profileName: profile: {
          ".colima/${profileName}/colima.yaml" = lib.mkIf (profile.settings != { }) {
            source = yamlFormat.generate "colima.yaml" profile.settings;
          };
        }) processedProfiles
      );

      programs.docker-cli.settings.currentContext = lib.mkIf (activeProfile != null) (
        if activeProfile.name != "default" then "colima-${activeProfile.name}" else "colima"
      );

      launchd.agents = lib.mkIf pkgs.stdenv.isDarwin (
        lib.mapAttrs' (
          name: profile:
          lib.nameValuePair "colima-${name}" {
            enable = true;
            config = {
              ProgramArguments = [
                "${lib.getExe colimaPackage}"
                "start"
                name
                "-f"
                "--activate=${if profile.isActive then "true" else "false"}"
                "--save-config=false"
              ];
              KeepAlive = true;
              RunAtLoad = true;
              EnvironmentVariables.PATH = lib.makeBinPath [
                colimaPackage
                perlPackage
                dockerPackage
                sshPackage
                coreutilsPackage
                curlPackage
                bashPackage
                pkgs.darwin.DarwinTools
              ];
              StandardOutPath = profile.logFile;
              StandardErrorPath = profile.logFile;
            };
          }
        ) (lib.filterAttrs (_: p: p.isService) processedProfiles)
      );

      systemd.user.services = lib.mkIf pkgs.stdenv.isLinux (
        lib.mapAttrs' (
          name: profile:
          lib.nameValuePair "colima-${name}" {
            Unit = {
              Description = "Colima container runtime (${name} profile)";
              After = [ "network-online.target" ];
              Wants = [ "network-online.target" ];
            };
            Service = {
              ExecStart = ''
                ${lib.getExe colimaPackage} start ${name} \
                  -f \
                  --activate=${if profile.isActive then "true" else "false"} \
                  --save-config=false
              '';
              Restart = "always";
              RestartSec = 2;
              Environment = [
                "PATH=${
                  lib.makeBinPath [
                    colimaPackage
                    perlPackage
                    dockerPackage
                    sshPackage
                    coreutilsPackage
                    curlPackage
                    bashPackage
                  ]
                }"
              ];
              StandardOutput = "append:${profile.logFile}";
              StandardError = "append:${profile.logFile}";
            };
            Install = {
              WantedBy = [ "default.target" ];
            };
          }
        ) (lib.filterAttrs (_: p: p.isService) processedProfiles)
      );
    };
}
