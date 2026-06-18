{ den, lib, ... }:
let
  skillsDir = ./skills;
  skillFiles = builtins.attrNames (
    lib.filterAttrs (_: type: type == "regular") (builtins.readDir skillsDir)
  );
  skillNames = map (f: lib.removeSuffix ".md" f) skillFiles;
in
{
  dots.ai =
    { ... }:
    {
      description = "AI coding assistants";
      includes = [ (den._.unfree [ "claude-code" ]) ];

      homeManager =
        { config, pkgs, ... }:
        let
          superpowers = pkgs.local.superpowers;
          piWebAccess = pkgs.local.pi-web-access;
          piMcpAdapter = pkgs.local.pi-mcp-adapter;
          context7Pi = pkgs.local.context7-pi;
        in
        {
          home.sessionVariables.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1;
          home.sessionVariables.PI_SKIP_VERSION_CHECK = 1;
          programs.claude-code = {
            enable = true;
            enableMcpIntegration = true;
            settings = {
              alwaysThinkingEnabled = false;
              gitAttribution = false;
              includeCoAuthoredBy = false;
              theme = "dark";
            };
            skills = lib.genAttrs skillNames (name: skillsDir + "/${name}.md");
          };

          programs.opencode = {
            enable = true;
            enableMcpIntegration = true;
            settings = {
              autoshare = false;
              autoupdate = false;
              share = "disabled";
            };
          };
          xdg.configFile = {
            "opencode/plugins/superpowers.js".source = "${superpowers}/.opencode/plugins/superpowers.js";
            "opencode/skills/superpowers".source = "${superpowers}/skills";
          }
          // lib.genAttrs (map (name: "opencode/skills/${name}/SKILL.md") skillNames) (
            key:
            let
              name = lib.removeSuffix "/SKILL.md" (lib.removePrefix "opencode/skills/" key);
            in
            {
              source = skillsDir + "/${name}.md";
            }
          );

          programs.pi-coding-agent = {
            enable = true;
            context = ./pi/AGENTS.md;
            settings = {
              theme = "dark";
              enableInstallTelemetry = false;
              enableAnalytics = false;
              defaultProvider = lib.mkDefault "anthropic";
              extensions = [ "${piWebAccess}/index.js" "${context7Pi}/context7.js" "${piMcpAdapter}/index.js" ];
              skills = [ "${piWebAccess}/skills" "${context7Pi}/skills" ]
                ++ map (name: toString (skillsDir + "/${name}.md")) skillNames;
            };
          };

          programs.mcp = {
            enable = true;
            servers.context7.command = lib.getExe pkgs.context7-mcp;
          };

          home.file."${config.programs.pi-coding-agent.configDir}/APPEND_SYSTEM.md".source = ./pi/APPEND_SYSTEM.md;
        };
    };
}
