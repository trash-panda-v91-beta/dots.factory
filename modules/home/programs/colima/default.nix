{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

with lib;
let
  cfg = config.${namespace}.programs.colima;
in
{
  options.${namespace}.programs.colima = {
    enable = lib.mkEnableOption "colima";
    startService = lib.mkEnableOption "colima service";
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.startService) {
      launchd.agents.colima = {
        enable = true;
        config = {
          EnvironmentVariables = {
            PATH = "/Users/${config.home.username}/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin";
          };
          ProgramArguments = mkMerge [
            [
              "${pkgs.unstable.colima}/bin/colima"
              "start"
              "--foreground"
            ]

            (mkIf (pkgs.system == "aarch64-darwin") [
              "--arch" "aarch64"
              "--vm-type" "vz"
              "--vz-rosetta"
            ])
          ];
          KeepAlive = {
            Crashed = true;
            SuccessfulExit = false;
          };
          ProcessType = "Interactive";
        };
      };
    })

    (mkIf cfg.enable {
      home.packages = [
        pkgs.unstable.colima
      ];

      programs.ssh = {
        includes = [
          "/Users/${config.home.username}/.colima/ssh_config"
        ];
      };
    })
  ];
}