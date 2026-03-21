{
  delib,
  ...
}:
delib.module {
  name = "ai.skills.aws-development";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    xdg.configFile."opencode/skills/aws-development/SKILL.md".source = ./SKILL.md;
    programs.claude-code.skills.aws-development = ./SKILL.md;
  };
}
