{
  delib,
  lib,
  ...
}:
delib.module {
  name = "programs.claude-code";

  options.programs.claude-code = with delib; {
    enable = boolOption true;

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra environment variables to set via home.sessionVariables when claude-code is enabled.";
    };
  };

  myconfig.ifEnabled.unfreePackages.allow = [
    "claude-code"
  ];

  home.ifEnabled =
    { cfg, ... }:
    {
      home.sessionVariables = {
        CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1;
      }
      // cfg.env;
      programs.claude-code = {
        enable = true;
        enableMcpIntegration = true;

        settings = {
          alwaysThinkingEnabled = false;
          gitAttribution = false;
          includeCoAuthoredBy = false;
          theme = "dark";
        };
      };
    };
}
