# TODO: switch to upstream once https://github.com/nix-darwin/nix-darwin/pull/1595 is merged
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.karabiner-dk;

  parentAppDir = "/Applications/Nix Apps";
in
{
  meta.maintainers = [ lib.maintainers.auscyber or "auscyber" ];
  options.services.karabiner-dk = {
    enable = mkEnableOption "Karabiner-DK";
    package = mkPackageOption pkgs "karabiner-dk" { };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];
    launchd.daemons.Karabiner-DriverKit-VirtualHIDDevice-Daemon = {
      serviceConfig.ProgramArguments = [
        "/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon"
      ];
      serviceConfig.ProcessType = "Interactive";
      serviceConfig.Label = "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice-Daemon";
      serviceConfig.RunAtLoad = true;
      serviceConfig.KeepAlive = true;
    };
    launchd.daemons.start-karabiner-dk = {
      script = ''
        "${parentAppDir}/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate
      '';
      serviceConfig.Label = "org.nixos.start-karabiner-dk";
      serviceConfig.RunAtLoad = true;
    };
    launchd.user.agents.activate_karabiner_system_ext = {
      serviceConfig.ProgramArguments = [
        "${parentAppDir}/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager"
        "activate"
      ];
      serviceConfig.RunAtLoad = true;
      managedBy = "auscybernix.keybinds.karabiner-driver-kit.enable";
    };
    system.activationScripts.postActivation.text = ''
      		launchctl kickstart -k system/org.pqrs.Karabiner-DriverKit-VirtualHIDDevice-Daemon
      	'';
  };
}
