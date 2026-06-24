# Homelab bundle - Kubernetes ops capability
{ __findFile, ... }:
{
  dots.bundle._.homelab = {
    description = "Homelab ops: kubectl + k9s + fluxcd + talosctl";
    includes = [ <dots/tool/k8s> ];

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
