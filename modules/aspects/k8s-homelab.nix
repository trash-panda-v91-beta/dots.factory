# Homelab cluster tools: flux, talosctl
{ __findFile, ... }:
{
  dots.k8s-homelab = {
    description = "Homelab cluster tools: flux, talosctl";

    includes = [ <dots/k8s> ];

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          fluxcd
          talosctl
        ];
      };
  };
}
