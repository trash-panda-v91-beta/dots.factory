{ inputs, ... }:
{
  dots.tool._.sops = {
    description = "sops-nix secrets management (home-manager)";

    includes = [ { homeManager.imports = [ inputs.sops-nix.homeManagerModules.sops ]; } ];

    homeManager =
      { pkgs, config, ... }:
      let
        sshPrivateKey = "${config.home.homeDirectory}/.ssh/${config.home.username}";
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
