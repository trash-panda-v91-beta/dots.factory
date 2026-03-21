{
  delib,
  ...
}:
delib.module {
  name = "ai.skills.quality-engineering";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    xdg.configFile."opencode/skills/quality-engineering/SKILL.md".source = ./SKILL.md;
    programs.claude-code.skills.quality-engineering = ./SKILL.md;
  };
}
