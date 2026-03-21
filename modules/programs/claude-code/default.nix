{
  delib,
  host,
  lib,
  ...
}:
delib.module {
  name = "programs.claude-code";

  options.programs.claude-code = {
    enable = delib.boolOption host.codingFeatured;

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

  home.ifEnabled = {
    programs.claude-code = {
      enable = true;
      enableMcpIntegration = true;

      settings = {
        theme = "dark";
        includeCoAuthoredBy = false;
      };

      memory = {
        text = ''
          # Agent Guidelines

          - Default shell is Nushell (nu), not bash
          - For POSIX shell compatibility, use: `bash -c "command"`
        '';
      };
    };
  };
}
