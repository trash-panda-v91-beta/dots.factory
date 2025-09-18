{
  delib,
  homeconfig,
  inputs,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "user";

  options.user = with delib; {
    enable = boolOption true;
    name = strOption "trash-panda-v91-beta";
    email = noDefault (strOption null);
    ssh.publicKey = noDefault (strOption null);
  };

  home.ifEnabled =
    { cfg, myconfig, ... }:
    let
      sshPublicKeyPath = "${homeconfig.home.homeDirectory}/.ssh/${cfg.name}.pub";
    in
    {
      home.file.sshPublicKey = {
        text = inputs.vault.constants.users.${cfg.name}.ssh.publicKey;
        target = ".ssh/${cfg.name}";
      };
      programs.ssh = lib.mkIf (myconfig.programs._1password.enable && myconfig.programs.git.enable) {
        matchBlocks."github.com" = {
          user = "git";
          identityFile = sshPublicKeyPath;
          identitiesOnly = true;
          extraOptions = {
            identityAgent = "'${myconfig.programs._1password.agentSocket}'";
          };
        };
      };
    };

  nixos.always =
    { cfg, ... }:
    {
      users = {
        groups.${cfg.name} = { };
        users.${cfg.name} = {
          isNormalUser = true;
          extraGroups = [ "wheel" ];
        };
      };
    };

  darwin.always =
    { cfg, ... }:
    {
      myconfig.user.email = inputs.vault.constants.users.${cfg.name}.email;
      users.users.${cfg.name} = {
        name = cfg.name;
        home = "/Users/${cfg.name}";
        shell = pkgs.nushell;
      };
    };
}
