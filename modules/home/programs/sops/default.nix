{
  config,
  inputs,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (lib.${namespace}) mkOpt;

  cfg = config.${namespace}.programs.sops;
in
{
  options.${namespace}.programs.sops = with types; {
    enable = lib.mkEnableOption "sops";
    defaultSopsFile = mkOpt path inputs.secrets.file "Default sops file.";
    sshKeyPaths = mkOpt (listOf path) [ ] "SSH Key paths to use.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      age
      sops
      ssh-to-age
    ];

    sops = {
      inherit (cfg) defaultSopsFile;
      defaultSopsFormat = "yaml";

      age = {
        generateKey = true;
        keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
        sshKeyPaths = [ "${config.xdg.configHome}/.ssh/id_ed25519" ] ++ cfg.sshKeyPaths;
      };
      secrets = {
        nix = {
          sopsFile = lib.snowfall.fs.get-file "secrets/khaneliman/default.yaml";
          path = "${config.xdg.configHome}/.config/nix/nix.conf";
        };
      };
    };
  };
}
