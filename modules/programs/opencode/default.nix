{
  delib,
  lib,
  pkgs,
  inputs,
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
      opencodeWrapper = pkgs.callPackage ../../../packages/opencode-wrapped {
        inherit inputs;
        envVars = cfg.env;
      };

      superpowers = pkgs.local.superpowers;
    in
    {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        package = pkgs.local.opencode;
        settings =
          lib.recursiveUpdate
            {
              autoshare = false;
              autoupdate = false;
              keybinds = {
                session_new = "ctrl+n";
                session_timeline = "ctrl+g";
                messages_half_page_up = "up";
                messages_half_page_down = "down";
                messages_copy = "ctrl+y";
                messages_undo = "ctrl+z";

                command_list = "ctrl+p";
                agent_list = "ctrl+a";
                editor_open = "ctrl+e";

                status_view = "ctrl+s";

                history_previous = "pageup";
                history_next = "pagedown";
              };
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

      home.packages = lib.optional (cfg.env != { }) opencodeWrapper;
    };
}
