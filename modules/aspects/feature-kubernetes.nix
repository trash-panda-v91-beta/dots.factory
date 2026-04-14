{ dots, ... }:
{
  dots.feature-kubernetes = {
    description = "Kubernetes tools";
    includes = [ dots.k8s ];
  };
}
