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

  home.always =
    { cfg, ... }:
    let
      username = cfg.name;
    in
    {
      home = {
        inherit username;
        homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
      };
    };

  home.ifEnabled =
    { cfg, myconfig, ... }:
    {
      home.file.sshPublicKey = {
        text = inputs.vault.constants.users.${cfg.name}.ssh.publicKey;
        target = ".ssh/${cfg.name}.pub";
      };
      programs.ssh = lib.mkIf (myconfig.programs._1password.enable && myconfig.programs.git.enable) {
        matchBlocks."github.com" = {
          user = "git";
          identityFile = "${homeconfig.home.homeDirectory}/${homeconfig.home.file.sshPublicKey.target}";
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
