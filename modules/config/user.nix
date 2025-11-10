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
    ssh.matchBlocks = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "The name of the SSH match block";
            };
            user = lib.mkOption {
              type = lib.types.str;
              description = "The user for the SSH match block";
            };
          };
        }
      );
      default = [ ];
      description = "List of SSH match blocks to configure";
    };
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
        matchBlocks = lib.mkMerge [
          {
            "github.com" = {
              user = "git";
              identityFile = "${homeconfig.home.homeDirectory}/${homeconfig.home.file.sshPublicKey.target}";
              identitiesOnly = true;
              extraOptions = {
                identityAgent = "'${myconfig.programs._1password.agentSocket}'";
              };
            };
          }
          (lib.mkMerge (
            map (block: {
              ${block.name} = {
                user = block.user;
                identityFile = "${homeconfig.home.homeDirectory}/${homeconfig.home.file.sshPublicKey.target}";
                identitiesOnly = true;
                extraOptions = {
                  IdentityAgent = "'${myconfig.programs._1password.agentSocket}'";
                };
              };
            }) cfg.ssh.matchBlocks
          ))
        ];
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
