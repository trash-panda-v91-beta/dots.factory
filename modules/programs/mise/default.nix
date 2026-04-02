{
  delib,
  host,
  ...
}:
delib.module {
  name = "programs.mise";

  options = delib.singleEnableOption host.codingFeatured;

  home.ifEnabled = {
    programs.mise = {
      enable = true;
      enableNushellIntegration = true;
      globalConfig = {
        env_cache = true;
        env_cache_ttl = "8h";
      };
    };
  };
}
