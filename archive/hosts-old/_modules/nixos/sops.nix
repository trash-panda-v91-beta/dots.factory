{
  pkgs,
  ...
}:
{
  config = {
    environment.systemPackages = [
      pkgs.sops
      pkgs.age
    ];

    sops = {
      age.sshKeyPaths = [
        "/etc/ssh/id_ed25519"
      ];
    };
  };
}
