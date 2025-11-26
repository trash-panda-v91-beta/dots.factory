{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.mcp";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.mcp = {
      enable = true;
      servers = {
        context7 = {
          url = "https://mcp.context7.com/mcp";
          headers = {
            CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
          };
        };
        github = {
          command = "${pkgs.lib.getExe pkgs.github-mcp-server}";
          args = [
            "--read-only"
            "stdio"
          ];
        };
        hass = {
          url = "https://hass.nebular-grid.space/api/mcp";
          headers = {
            Authorization = "Bearer {env:HASS_TOKEN}";
          };
        };
      };
    };
  };
}
