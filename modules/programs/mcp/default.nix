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
          url = "https://mcp.context7.com/mcp";
          headers = {
            CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
          };
        };

        sequential-thinking = {
          command = "${pkgs.docker}/bin/docker";
          args = [
            "run"
            "-i"
            "--rm"
            "mcp/sequentialthinking"
          ];
        };

        filesystem = {
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

        github = {
          command = "${pkgs.lib.getExe pkgs.github-mcp-server}";
          args = [
            "--read-only"
            "stdio"
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
