{
  inputs,
  pkgs,
  lib,
  config,
  hostname,
  ...
}:
let
  ifGroupsExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
  ];

  config = {
    networking = {
      hostName = hostname;
      hostId = "a4d308c1";
      useDHCP = true;
      firewall.enable = false;
    };

    users.users.c4300n = {
      uid = 1000;
      name = "c4300n";
      home = "/home/c4300n";
      group = "c4300n";
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = lib.strings.splitString "\n" (
        builtins.readFile inputs.secrets.ssh_pub_key
      );
      hashedPasswordFile = config.sops.secrets."users/c4300n/password".path;
      isNormalUser = true;
      extraGroups =
        [
          "wheel"
          "users"
        ]
        ++ ifGroupsExist [
          "network"
          "samba-users"
        ];
    };
    users.groups.c4300n = {
      gid = 1000;
    };

    system.activationScripts.postActivation.text = ''
      # Must match what is in /etc/shells
      chsh -s /run/current-system/sw/bin/fish c4300n
    '';

    modules = {
      filesystems.zfs = {
        enable = true;
        mountPoolsAtBoot = [ "tank" ];
      };

      services = {
        chrony = {
          enable = true;
          servers = [
            "0.${inputs.secrets.country}.pool.ntp.org"
            "1.${inputs.secrets.country}.pool.ntp.org"
            "2.${inputs.secrets.country}.pool.ntp.org"
            "3.${inputs.secrets.country}.pool.ntp.org"
          ];
        };

        nginx = {
          enableAcme = true;
          acmeCloudflareAuthFile = config.sops.secrets."networking/cloudflare/auth".path;
        };

        minio = {
          enable = true;
          package = pkgs.unstable.minio;
          rootCredentialsFile = config.sops.secrets."storage/minio/root-credentials".path;
          dataDir = "/tank/apps/minio";
          enableReverseProxy = true;
          minioConsoleURL = "minio.${inputs.secrets.domain}}";
          minioS3URL = "s3.${inputs.secrets.domain}}";
        };

        nfs.enable = true;

        node-exporter.enable = true;

        openssh.enable = true;

        samba = {
          enable = true;
          shares = {
            Backup = {
              path = "/tank/backup";
              "read only" = "no";
            };
            Docs = {
              path = "/tank/docs";
              "read only" = "no";
            };
            Media = {
              path = "/tank/media";
              "read only" = "no";
            };
            Paperless = {
              path = "/tank/apps/paperless/incoming";
              "read only" = "no";
            };
            Software = {
              path = "/tank/software";
              "read only" = "no";
            };
            TimeMachineBackup = {
              path = "/tank/backup/TimeMachine";
              "read only" = "no";
              "fruit:aapl" = "yes";
              "fruit:time machine" = "yes";
            };
            Void = {
              path = "/tank/void";
              "read only" = "no";
            };
          };
        };

        smartd.enable = true;
        smartctl-exporter.enable = true;
      };

      users = {
        additionalUsers = {
          an37 = {
            isNormalUser = true;
            extraGroups = ifGroupsExist [ "samba-users" ];
          };
        };
        groups = {
          external-services = {
            gid = 65542;
          };
          admins = {
            gid = 991;
            members = [ "c4300n" ];
          };
        };
      };
    };

    # Use the systemd-boot EFI boot loader.
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
