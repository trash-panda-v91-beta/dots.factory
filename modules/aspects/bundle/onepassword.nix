{ __findFile, ... }:
{
  dots.bundle._.onepassword = {
    description = "1Password + sops-nix";
    includes = [
      <dots/tool/security>
      <dots/tool/sops>
    ];
  };
}
