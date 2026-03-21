{
  delib,
  lib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.claude-code";

  options.programs.claude-code = {
    enable = true;

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Environment variables to pass to Claude Code (typically 1Password references)";
      example = lib.literalExpression ''
        {
          ANTHROPIC_API_KEY = "op://Private/Anthropic/credential";
        }
      '';
    };
  };

  myconfig.ifEnabled.unfreePackages.allow = [
    "claude-code"
  ];

  home.ifEnabled =
    { cfg, ... }:
    let
      claudeCodeWrapper = pkgs.callPackage ../../../packages/claude-code-wrapped {
        envVars = cfg.env;
      };
    in
    {
      programs.claude-code = {
        enable = true;
        enableMcpIntegration = true;

        settings = {
          theme = "dark";
          includeCoAuthoredBy = false;
          alwaysThinkingEnabled = false;
          gitAttribution = false;
        };

        memory = {
          text = ''
            # Agent Guidelines

            - Default shell is Nushell (nu), not bash
            - For POSIX shell compatibility, use: `bash -c "command"`
          '';
        };
      };

      home.packages = lib.optional (cfg.env != { }) claudeCodeWrapper;
    };
}
