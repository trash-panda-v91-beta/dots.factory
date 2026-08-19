# AWS capability bundle - vicinae extension + tooling
# Enabled on CMB via dots.corpo; not included in the personal PMB user manifest.
{ __findFile, ... }:
{
  dots.bundle._.aws = {
    description = "AWS: vicinae extension, aws-vault";
    includes = [ <dots/tool/vicinae> ];

    homeManager =
      { pkgs, ... }:
      let
        awsExt = pkgs.buildNpmPackage {
          name = "aws";
          src = pkgs.fetchFromGitHub {
            owner = "raycast";
            repo = "extensions";
            rev = "a03e4c58dd53593042397b412413afda7117790e";
            hash = "sha256-q7SM0M0cxTJqqWDkuZo4ay34G5Umv0QIxbvmcT1QJiY=";
            sparseCheckout = [ "/extensions/amazon-aws" ];
          } + "/extensions/amazon-aws";
          inherit (pkgs.importNpmLock) npmConfigHook;
          npmDeps = pkgs.importNpmLock {
            npmRoot = ./aws-ext;
          };
          npmFlags = [ "--ignore-scripts" ];
          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -r "$HOME/.config/raycast/extensions"/*/. $out/
            runHook postInstall
          '';
        };
      in
      {
        xdg.dataFile."vicinae/extensions/store.raycast.aws".source = awsExt;
        programs.vicinae.settings.providers."@Falcon/store.raycast.aws".preferences.useAWSVault = false;
      };
  };
}
