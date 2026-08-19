# AWS capability bundle - vicinae extension + tooling
# Enabled on CMB via dots.corpo; not included in the personal PMB user manifest.
{ __findFile, ... }:
{
  dots.bundle._.aws = {
    description = "AWS: vicinae extension, aws-vault";
    includes = [ <dots/tool/vicinae> ];

    homeManager =
      { pkgs, ... }:
      {
        xdg.dataFile."vicinae/extensions/store.raycast.aws".source = pkgs.local.aws-ext;
        programs.vicinae.settings.providers."@Falcon/store.raycast.aws".preferences.useAWSVault = false;
      };
  };
}
