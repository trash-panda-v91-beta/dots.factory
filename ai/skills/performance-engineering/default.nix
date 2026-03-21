{
  delib,
  ...
}:
delib.module {
  name = "ai.skills.performance-engineering";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    xdg.configFile."opencode/skills/performance-engineering/SKILL.md".source = ./SKILL.md;
    programs.claude-code.skills.performance-engineering = ./SKILL.md;
  };
}
