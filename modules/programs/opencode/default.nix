{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.opencode";

  options.programs.opencode = {
    enable = delib.boolOption true;

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Environment variables to pass to OpenCode (typically 1Password references)";
      example = lib.literalExpression ''
        {
          HASS_TOKEN = "op://Private/HASS MCP/password";
          ACTUAL_PASSWORD = "op://NebularGrid/Actual/password";
          TAVILY_TOKEN = "op://Private/Tavily/credential";
        }
      '';
    };

    providerSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional provider settings to merge into opencode.json";
      example = lib.literalExpression ''
        {
          anthropic.options.baseURL = "http://localhost:6655/anthropic/v1";
          openai.options.baseURL = "http://localhost:6655/openai/v1";
          google.options.baseURL = "http://localhost:6655/gemini";
        }
      '';
    };
  };

  home.ifEnabled =
    { cfg, ... }:
    let
      superpowers = pkgs.local.superpowers;
    in
    {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        settings =
          lib.recursiveUpdate
            {
              autoshare = false;
              autoupdate = false;
              share = "disabled";
            }
            (
              lib.optionalAttrs (cfg.providerSettings != { }) {
                provider = cfg.providerSettings;
              }
            );
      };

      xdg.configFile = {
        "opencode/plugins/superpowers.js".source = "${superpowers}/.opencode/plugins/superpowers.js";
        "opencode/skills/superpowers".source = "${superpowers}/skills";
      };

    };
}
