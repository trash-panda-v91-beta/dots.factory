{
  delib,
  pkgs,
  ...
}:
delib.module {
  name = "programs.opencode";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        autoshare = false;
        autoupdate = false;
        keybinds = {
          sidebar_toggle = "ctrl+b";
          session_list = "ctrl+s";
          history_previous = "pageup";
          history_next = "pagedown";
          messages_half_page_up = "up";
          messages_half_page_down = "down";
        };
      };

      # Agent configurations
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
      opencode = "with-env { HASS_TOKEN: 'op://Private/HASS MCP/password'} {${pkgs.lib.getExe pkgs._1password-cli} run --no-masking -- ${pkgs.lib.getExe pkgs.opencode}}";
    };
    programs.tmux.extraConfig = ''
      bind -n M-i new-window "${pkgs.lib.getExe pkgs.opencode}"
    '';
  };
}
