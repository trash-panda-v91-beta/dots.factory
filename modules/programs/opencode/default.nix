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
    alias = delib.strOption "sidekick";
  };

  home.ifEnabled =
    { cfg, myconfig, ... }:
    let
      mcpConfig = myconfig.programs.mcp or { };

      serverEnabled = serverName: !(mcpConfig.servers.${serverName}.disabled or true);

      actualEnabled = serverEnabled "actualBudget";
      homeAssistantEnabled = serverEnabled "home-assistant";
      perplexityEnabled = serverEnabled "perplexity";
      tavilyEnabled = serverEnabled "tavily";

      # Build environment variables list based on enabled servers
      envVars = [
      ]
      ++ lib.optionals homeAssistantEnabled [
        "HASS_TOKEN: 'op://Private/HASS MCP/password'"
      ]
      ++ lib.optionals actualEnabled [
        "ACTUAL_PASSWORD: 'op://NebularGrid/Actual/password'"
        "ACTUAL_BUDGET_SYNC_ID: 'op://NebularGrid/Actual/sync id'"
      ]
      ++ lib.optionals tavilyEnabled [
        "TAVILY_TOKEN: 'op://Private/op4p2ok4buizqra3jssnnoet3u/credential'"
      ]
      ++ lib.optionals perplexityEnabled [
        "PERPLEXITY_API_KEY: 'op://Private/perplexity-api-key'"
      ];

      opencodeExe = lib.getExe pkgs.local.opencode;
      sidekickCommand =
        if envVars == [ ] then
          opencodeExe
        else
          let
            envRecord = lib.concatStringsSep ", " envVars;
            opExe = lib.getExe pkgs._1password-cli;
          in
          ''with-env { ${envRecord} } { ${opExe} run --no-masking -- ${opencodeExe} }'';
    in
    {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        package = pkgs.local.opencode;
        settings = {
          autoshare = false;
          autoupdate = false;
          instructions = [ ./rules/nushell.md ];
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
        };
        agents = {
          agent-organizer = ./agents/agent-organizer.md;
          architect-review = ./agents/architect-review.md;
          backend-architect = ./agents/backend-architect.md;
          cloud-architect = ./agents/cloud-architect.md;
          code-reviewer = ./agents/code-reviewer.md;
          data-scientist = ./agents/data-scientist.md;
          database-optimizer = ./agents/database-optimizer.md;
          debugger = ./agents/debugger.md;
          deployment-engineer = ./agents/deployment-engineer.md;
          nix-expert = ./agents/nix-expert.md;
          performance-engineer = ./agents/performance-engineer.md;
          python-dev = ./agents/python-dev.md;
          qa-expert = ./agents/qa-expert.md;
          security-auditor = ./agents/security-auditor.md;
          test-automator = ./agents/test-automator.md;
        };
      };

      programs.nushell.shellAliases = {
        ${cfg.alias} = sidekickCommand;
      };
      programs.tmux.extraConfig = ''
        bind -n M-i new-window -n "opencode" "${lib.getExe pkgs.nushell} -l -c '${cfg.alias}'"
      '';

      programs.sesh.settings.windows = [
        {
          name = cfg.alias;
          startup_script = cfg.alias;
        }
      ];
    };
}
