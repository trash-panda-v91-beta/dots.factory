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
  };

  home.ifEnabled =
    { cfg, ... }:
    let
      envVars = lib.mapAttrsToList (name: value: "${name}: '${value}'") cfg.env;

      opencodeExe = lib.getExe pkgs.local.opencode;
      sidekickCommand =
        if envVars == [ ] then
          opencodeExe
        else
          let
            envRecord = lib.concatStringsSep ", " envVars;
            opExe = lib.getExe pkgs._1password-cli;
          in
          "with-env { ${envRecord} } { ${opExe} run --no-masking -- ${opencodeExe} }";
    in
    {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        package = pkgs.local.opencode;
        settings = {
          autoshare = false;
          autoupdate = false;
          default_agent = "architect";
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
      };

      xdg.configFile = lib.listToAttrs (
        lib.concatMap
          (
            skillName:
            let
              skillDir = ./skills + "/${skillName}";
              skillFile = "${skillDir}/SKILL.md";
            in
            if builtins.pathExists skillFile then
              [
                {
                  name = "opencode/skill/${skillName}/SKILL.md";
                  value.source = skillFile;
                }
              ]
            else
              [ ]
          )
          [
            "aws-development"
            "codebase-assessment"
            "data-and-sql"
            "delivery-and-infra"
            "frontend-delegation"
            "git-workflow"
            "nix-guidelines"
            "oracle-consultation"
            "parallel-exploration"
            "performance-engineering"
            "python-development"
            "quality-engineering"
            "review-architecture"
            "review-code-quality"
            "rust-development"
            "systematic-debugging"
            "test-driven-development"
            "verification-checklist"
          ]
      );

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
