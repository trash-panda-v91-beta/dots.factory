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
    {
      sops = {
        age.sshKeyPaths = [
          "${homeconfig.home.homeDirectory}/.ssh/${myconfig.user.name}"
        ];
        defaultSopsFile = inputs.vault.secrets;
        gnupg.sshKeyPaths = [ ];
      };
      home.packages = [
        pkgs.age
        pkgs.sops
      ];
    };
}
