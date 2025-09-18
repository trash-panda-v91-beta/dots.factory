{
  inputs,
  ...
}:
{
  config = {
    sops = {
      defaultSopsFile = inputs.secrets.file;
      age.sshKeyPaths = [
        "/etc/ssh/id_ed25519"
      ];
    };
  };
}
