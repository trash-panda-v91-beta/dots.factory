# Kanata nix-darwin module — defines services.kanata options and activation.
# Imported by the keyboard aspect via includes; underscore-prefixed so import-tree ignores it.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.kanata;

  upstreamDoc =
    "See [the upstream documentation](https://github.com/jtroo/kanata/blob/main/docs/config.adoc)"
    + " and [example config files](https://github.com/jtroo/kanata/tree/main/cfg_samples) for more information.";

  parentAppDir = "/Applications/.Nix-Karabiner";

  keyboard =
    { name, config, ... }:
    {
      options = {
        devices = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Keyboard device names. Empty = auto-detect all.";
        };
        config = lib.mkOption {
          type = lib.types.lines;
          description = "Kanata config (everything except defcfg). ${upstreamDoc}";
        };
        extraDefCfg = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = "Extra defcfg options. ${upstreamDoc}";
        };
        configFile = lib.mkOption {
          type = lib.types.path;
          default = mkConfig name config;
          description = "Override config file path.";
        };
        extraArgs = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Extra kanata CLI args.";
        };
        port = lib.mkOption {
          type = lib.types.nullOr lib.types.port;
          default = null;
          description = "TCP server port. null = disabled.";
        };
      };
    };

  mkName = name: "kanata-${name}";

  mkDevices =
    devices:
    let
      devicesString = lib.pipe devices [
        (map (device: "\"" + device + "\""))
        (lib.concatStringsSep " ")
      ];
    in
    lib.optionalString ((lib.length devices) > 0) "macos-dev-names-include (${devicesString})";

  mkConfig =
    name: keyboard:
    pkgs.writeTextFile {
      name = "${mkName name}-config.kdb";
      text = ''
        (defcfg
          ${keyboard.extraDefCfg}
          ${mkDevices keyboard.devices})

        ${keyboard.config}
      '';
      checkPhase = ''
        ${lib.getExe cfg.package} --cfg "$target" --check --debug
      '';
    };

  mkService =
    name: keyboard:
    lib.nameValuePair (mkName name) {
      command =
        "/Applications/kanata --cfg ${keyboard.configFile}"
        + lib.optionalString (keyboard.port != null) " --port ${toString keyboard.port}"
        + lib.optionalString (keyboard.extraArgs != [ ]) " ${lib.concatStringsSep " " keyboard.extraArgs}";
      serviceConfig = {
        ProcessType = "Interactive";
        Label = "org.nixos.${mkName name}";
        KeepAlive = true;
        RunAtLoad = true;
        StandardErrorPath = "/var/log/${mkName name}.err.log";
        StandardOutPath = "/var/log/${mkName name}.out.log";
      };
    };

  driverKitPkg = cfg.karabinerDriverKitPackage;
  driverDaemonPath = "${driverKitPkg}/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";
in
{
  options.services.kanata = {
    enable = lib.mkEnableOption "kanata keyboard remapper";
    package = lib.mkPackageOption pkgs "kanata" { };
    karabinerDriverKitPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.karabiner-dk;
      description = "Karabiner-DriverKit-VirtualHIDDevice package.";
    };
    keyboards = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule keyboard);
      default = { };
      description = "Keyboard configurations.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    system.activationScripts.preActivation.text = ''
      rm -rf ${parentAppDir}
      mkdir -p ${parentAppDir}
      cp -r ${driverKitPkg}/Applications/.Karabiner-VirtualHIDDevice-Manager.app ${parentAppDir}
    '';

    system.activationScripts.postActivation.text = ''
      echo "Validating kanata configuration files..."
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: kb: ''
          echo "  Checking ${name}..."
          if ${lib.getExe cfg.package} --check --cfg ${toString kb.configFile} 2>&1; then
            echo "  ${name} configuration valid"
          else
            echo "  ${name} configuration invalid" >&2
            exit 1
          fi
        '') cfg.keyboards
      )}
      echo "All kanata configurations valid"

      if [ -e "${parentAppDir}/.Karabiner-VirtualHIDDevice-Manager.app" ]; then
        echo "Activating Karabiner-VirtualHIDDevice driver..."
        ${parentAppDir}/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager activate 2>/dev/null || true
      fi

      echo "Creating kanata symlink in /Applications..."
      ln -sf ${cfg.package}/bin/kanata /Applications/kanata

      echo "Starting kanata services..."
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: _kb: ''
          /bin/launchctl bootstrap system /Library/LaunchDaemons/org.nixos.${mkName name}.plist 2>/dev/null || true
        '') cfg.keyboards
      )}

      sleep 1

      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (name: _kb: ''
          /bin/launchctl kickstart -k system/org.nixos.${mkName name} 2>/dev/null || true
        '') cfg.keyboards
      )}
    '';

    launchd.daemons = {
      activate-karabiner-driverkit = {
        command = "${parentAppDir}/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager activate";
        serviceConfig = {
          Label = "org.nixos.activate-karabiner-driverkit";
          RunAtLoad = true;
        };
      };
      Karabiner-DriverKit-VirtualHIDDevice-Daemon = {
        command = "\"${driverDaemonPath}\"";
        serviceConfig = {
          ProcessType = "Interactive";
          Label = "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice-Daemon";
          KeepAlive = true;
          RunAtLoad = true;
        };
      };
    }
    // lib.mapAttrs' mkService cfg.keyboards;
  };
}
