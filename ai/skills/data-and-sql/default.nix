{
  delib,
  ...
}:
delib.module {
  name = "ai.skills.data-and-sql";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    xdg.configFile."opencode/skills/data-and-sql/SKILL.md".source = ./SKILL.md;
    programs.claude-code.skills.data-and-sql = ./SKILL.md;
  };
}
