{
  delib,
  ...
}:
delib.module {
  name = "ai.skills.jira-cli";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    xdg.configFile."opencode/skills/jira-cli/SKILL.md".source = ./SKILL.md;
    programs.claude-code.skills.jira-cli = ./SKILL.md;
  };
}
