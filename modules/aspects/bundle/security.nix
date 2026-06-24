# Security bundle - credentials and secret management
{ __findFile, ... }:
{
  dots.bundle._.security = {
    description = "Auth and secrets: 1Password + sops-nix";
    includes = [
      <dots/tool/security>
      <dots/tool/sops>
    ];
  };
}
