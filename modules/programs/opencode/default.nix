{
  delib,
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
    { cfg, ... }:
    let
      sidekickCommand = "with-env { HASS_TOKEN: 'op://Private/HASS MCP/password'} {${pkgs.lib.getExe pkgs._1password-cli} run --no-masking -- ${pkgs.lib.getExe pkgs.local.opencode}}";
    in
    {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        package = pkgs.local.opencode;
        settings = {
          autoshare = false;
          autoupdate = false;
          keybinds = {
            # Navigation
            sidebar_toggle = "ctrl+b";
            session_list = "ctrl+l";
            session_new = "ctrl+n";
            session_timeline = "ctrl+g";
            session_child_cycle = "ctrl+right";
            session_child_cycle_reverse = "ctrl+left";

            # Messages
            messages_page_up = "pageup";
            messages_page_down = "pagedown";
            messages_half_page_up = "up";
            messages_half_page_down = "down";
            messages_copy = "ctrl+y";
            messages_undo = "ctrl+z";
            messages_redo = "ctrl+shift+z";
            messages_toggle_conceal = "ctrl+h";

            # Tools
            command_list = "ctrl+p";
            model_list = "ctrl+m";
            agent_list = "ctrl+a";
            editor_open = "ctrl+e";
            theme_list = "ctrl+t";

            # Session management
            session_compact = "ctrl+k";
            session_export = "ctrl+x";
            status_view = "ctrl+s";

            # History
            history_previous = "ctrl+up";
            history_next = "ctrl+down";
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
        bind -n M-i new-window opencode
      '';

      programs.sesh.settings.windows = [
        {
          name = cfg.alias;
          startup_script = cfg.alias;
        }
      ];
    };
}
