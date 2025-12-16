{
  delib,
  homeconfig,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.mcp";

  options.programs.mcp = with delib; {
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
          disabled = true;
          url = "https://mcp.context7.com/mcp";
          headers = {
            CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
          };
        };

        tavily = {
          disabled = true;
          url = "https://mcp.tavily.com/mcp";
          headers = {
            Authorization = "Bearer {env:TAVILY_TOKEN}";
          };
        };

        sequential-thinking = {
          disabled = true;
          command = "${pkgs.docker}/bin/docker";
          args = [
            "run"
            "-i"
            "--rm"
            "mcp/sequentialthinking"
          ];
        };

        filesystem = {
          disabled = true;
          command = "${pkgs.docker}/bin/docker";
          args = [
            "run"
            "-i"
            "--rm"
            "-v"
            "${homeconfig.home.homeDirectory}/repos:/workspace"
            "-e"
            "ALLOWED_DIRECTORIES=/workspace"
            "mcp/filesystem"
          ];
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
