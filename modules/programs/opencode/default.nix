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

      superpowers = pkgs.local.superpowers;

      # Personal skills (domain-specific, not covered by superpowers)
      personalSkills = [
        "aws-development"
        "data-and-sql"
        "delivery-and-infra"
        "nix-guidelines"
        "performance-engineering"
        "python-development"
        "quality-engineering"
        "release-please-pr"
        "rust-development"
      ];

      personalSkillFiles = lib.listToAttrs (
        lib.concatMap (
          skillName:
          let
            skillFile = ./skills + "/${skillName}/SKILL.md";
          in
          if builtins.pathExists skillFile then
            [
              {
                name = "opencode/skills/${skillName}/SKILL.md";
                value.source = skillFile;
              }
            ]
          else
            [ ]
        ) personalSkills
      );
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

      # Superpowers plugin and skills + personal skills
      xdg.configFile = {
        # Symlink the plugin
        "opencode/plugins/superpowers.js".source = "${superpowers}/.opencode/plugins/superpowers.js";
        # Symlink the superpowers skills directory
        "opencode/skills/superpowers".source = "${superpowers}/skills";
      }
      // personalSkillFiles;

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
