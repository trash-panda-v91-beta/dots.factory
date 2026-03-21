{
  delib,
  ...
}:
delib.module {
  name = "ai.skills.python-development";

  options = delib.singleEnableOption true;

  home.ifEnabled = {
    xdg.configFile."opencode/skills/python-development/SKILL.md".source = ./SKILL.md;
    programs.claude-code.skills.python-development = ./SKILL.md;
  };
}
