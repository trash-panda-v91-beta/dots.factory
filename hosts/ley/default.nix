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
      hostId = "c4406010";
      useDHCP = lib.mkForce true;
      firewall.enable = false;
      networkmanager = {
        enable = true;
      };
    };
    users.users.c4300n = {
      uid = 1000;
      name = "c4300n";
      home = "/home/c4300n";
      group = "c4300n";
      shell = pkgs.fish;
      # TODO: move to secrets
      openssh.authorizedKeys.keys = lib.strings.splitString "\n" (
        builtins.readFile inputs.secrets.ssh_pub_key
      );
      hashedPasswordFile = config.sops.secrets."users/c4300n/password".path;
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "users"
      ] ++ ifGroupsExist [ "network" ];
    };
    users.groups.c4300n = {
      gid = 1000;
    };
    system.activationScripts.postActivation.text = ''
      # Must match what is in /etc/shells
      chsh -s /run/current-system/sw/bin/fish c4300n
    '';

    modules = {
      apps.op.enable = true;
      services = {
        node-exporter.enable = true;

        openssh.enable = true;
      };
      users = {
        groups = {
          admins = {
            gid = 991;
            members = [ "c4300n" ];
          };
        };
      };
    };

    programs.hyprland.enable = true;
    xdg.portal.enable = true;
    xdg.portal.extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-gtk
    ];
    xdg.portal.configPackages = [ pkgs.hyprland ];

    # Use the systemd-boot EFI boot loader.
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };
}
