{
  delib,
  homeconfig,
  host,
  ...
}:
delib.module {
  name = "features.kubernetes";

  options = delib.singleEnableOption host.kubernetesFeatured;

  home.ifEnabled = {
    sops.secrets.kubeconfig = {
      mode = "0400";
      path = homeconfig.home.homeDirectory + "/.kube/config";
    };
  };
}
