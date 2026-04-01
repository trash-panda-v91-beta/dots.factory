{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "ai.mcp";

  options.ai.mcp = with delib; {
    enable = boolOption true;
    servers = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = { };
      description = "Additional MCP servers to configure";
      example = lib.literalExpression ''
        {
          hass = {
            url = "https://hass.example.com/api/mcp";
            headers = {
              Authorization = "Bearer {env:HASS_TOKEN}";
            };
          };
        }
      '';
    };
  };

  home.ifEnabled =
    { cfg, ... }:
    let
      builtinServers = {
        context7 = {
          command = lib.getExe pkgs.context7-mcp;
        };
      };
    in
    {
      programs.mcp = {
        enable = true;
        servers = builtinServers // cfg.servers;
      };
    };
}
