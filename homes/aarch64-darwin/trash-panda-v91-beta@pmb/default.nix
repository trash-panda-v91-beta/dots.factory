{
  config,
  inputs,
  namespace,
  pkgs,
  ...
}:
{
  home.stateVersion = "25.05";
  ${namespace} = {
    user = {
      enable = true;
      icon = pkgs.${namespace}.trash-panda-icon;
      inherit (config.snowfallorg.user) name;
    };
    programs = {
      raycast.enable = true;
    };
    suites.kubernetes = {
      enable = true;
      kubeSecretFile = inputs.constansts.kubeconfig;
    };
  };
}
