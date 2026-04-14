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
    { user, ... }:
    {
      description = "AI coding assistants: Claude Code, OpenCode, MCP, skills, copilot-lua";
      includes = [ (den._.unfree [ "claude-code" ]) ];

      homeManager =
        { pkgs, ... }:
        let
          superpowers = pkgs.local.superpowers;
        in
        {
          home.sessionVariables.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = 1;
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

          programs.mcp = {
            enable = true;
            servers.context7.command = lib.getExe pkgs.context7-mcp;
          };
        };
    };
}
