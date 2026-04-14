{ inputs, ... }:
{
  dots.sops = {
    description = "sops-nix secrets management (home-manager)";

    includes = [ { homeManager.imports = [ inputs.sops-nix.homeManagerModules.sops ]; } ];

    homeManager =
      { pkgs, home, ... }:
      let
        sshPrivateKey = "${home.homeDirectory}/.ssh/${home.username}";
      in
      {
        sops = {
          age.sshKeyPaths = [ sshPrivateKey ];
          gnupg.sshKeyPaths = [ ];
          environment.SOPS_AGE_SSH_PRIVATE_KEY_FILE = sshPrivateKey;
        };
        home.packages = [
          pkgs.age
          pkgs.sops
        ];
      };
  };
}
