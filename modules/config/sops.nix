{
  delib,
  homeconfig,
  inputs,
  pkgs,
  ...
}:
delib.module {
  name = "sops";
  options = delib.singleEnableOption true;

  home.always.imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.ifEnabled =
    { myconfig, ... }:
    let
      sshPrivateKey = "${homeconfig.home.homeDirectory}/.ssh/${myconfig.user.name}";
    in
    {
      sops = {
        age.sshKeyPaths = [
          sshPrivateKey
        ];
        defaultSopsFile = inputs.vault.secrets;
        environment.SOPS_AGE_SSH_PRIVATE_KEY_FILE = sshPrivateKey;
        gnupg.sshKeyPaths = [ ];
      };
      home.packages = [
        pkgs.age
        pkgs.sops
      ];
    };
}
